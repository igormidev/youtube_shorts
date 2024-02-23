import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart' hide Video;
import 'package:youtube_shorts/src/data/shorts_controller_settings.dart';
import 'package:youtube_shorts/src/data/type_defs.dart';
import 'package:youtube_shorts/src/logic/shorts_state.dart';
import 'package:synchronized/synchronized.dart';
import 'package:youtube_shorts/src/source/interface_videos_source_controller.dart';

part 'mixin_video_control_shortcut.dart';

class ShortsController extends ValueNotifier<ShortsState>
    with MixinVideoControlShortcut {
  final Lock _lock;
  final VideosSourceController _youtubeVideoInfoService;
  final VideoControllerConfiguration _defaultVideoControllerConfiguration;
  ShortsControllerSettings _settings;

  /// * [youtubeVideoSourceController] controller can be one of two constructors:
  ///     1. [VideosSourceController.fromUrlList]
  ///     2. [VideosSourceController.fromYoutubeChannelName]
  ///
  /// * If [startWithAutoplay] is true, the current focused video
  /// will start playing right after is dependencies are ready.
  /// Will start paused otherwise.
  ///
  /// * If [startWithAutoplay] is true, the videos will `repeat`
  /// from start when finalized. Will pause after done otherwise.
  ///
  /// * [VideoControllerConfiguration] is the configuration of [VideoController]
  /// of [media_kit](https://pub.dev/packages/media_kit).
  ShortsController({
    this.indexsWhereWillContainAds = const [],
    required VideosSourceController youtubeVideoSourceController,
    ShortsControllerSettings settings = const ShortsControllerSettings(),
    bool videosWillBeInLoop = true,
    bool startVideoMuted = false,
    VideoControllerConfiguration defaultVideoControllerConfiguration =
        const VideoControllerConfiguration(),
  })  : _settings = settings,
        _defaultVideoControllerConfiguration =
            defaultVideoControllerConfiguration,
        _youtubeVideoInfoService = youtubeVideoSourceController,
        _lock = Lock(),
        super(const ShortsStateLoading()) {
    notifyCurrentIndex(0);
  }

  final List<int> indexsWhereWillContainAds;

  int prevIndex = -1;

  @override
  int currentIndex = -1;

  /// Will not update the video that already are in state/loaded.
  ///
  /// Will only update the next videos that are not in
  /// state/loaded yet (that still will be fetched).
  void updateControllerSettings({
    required UpdateSettingsFunction updateFunction,
  }) {
    _settings = updateFunction(_settings);
  }

  /// Will notify the controller that the current index has changed.
  /// This will trigger the preload of the previus 3 and next 3 videos.
  void notifyCurrentIndex(
    int newIndex, {
    OnNotifyCallback? onPrevVideoPause,
    OnNotifyCallback? onCurrentVideoPlay,
  }) async {
    prevIndex = currentIndex;
    currentIndex = newIndex;
    unawaited(
      _playCurrentVideoAndPausePreviousVideo(
        prevIndex: prevIndex,
        currentIndex: currentIndex,
        onPrevVideoPause: onPrevVideoPause,
        onCurrentVideoPlay: onCurrentVideoPlay,
      ),
    );

    _preloadVideos();
  }

  Future<void> _playCurrentVideoAndPausePreviousVideo({
    required int prevIndex,
    required int currentIndex,
    required OnNotifyCallback? onPrevVideoPause,
    required OnNotifyCallback? onCurrentVideoPlay,
  }) async {
    if (prevIndex != -1) {
      final previousVideo = getVideoInIndex(prevIndex);
      if (previousVideo != null) {
        if (previousVideo is ShortsVideoData) {
          final VideoData video = await previousVideo.video.future;
          // We will not wait this
          unawaited(video.videoController.player.pause());
          onPrevVideoPause?.call(video, prevIndex, currentIndex);
        }
      }
    }

    if (_settings.startWithAutoplay == false) return;

    final currentVideo = getVideoInIndex(currentIndex);
    if (currentVideo != null) {
      if (currentVideo is ShortsVideoData) {
        final VideoData video = await currentVideo.video.future;
        await video.videoController.player.play();
        onCurrentVideoPlay?.call(video, prevIndex, currentIndex);
      }
    }
  }

  Map<int, int?> indexToSource = {
    1: 1,
    2: 2,
    3: null,
    4: 3,
  };

  /// Will load the previus 3 and next 3 videos.
  Future<void> _preloadVideos() async {
    try {
      return _lock.synchronized(() async {
        ShortsStateWithData? currentState = _getCurrentState();
        final videos = currentState?.videos;

        final previus3Ids = [
          _getMapEntryFromIndex(videos, currentIndex - 3),
          _getMapEntryFromIndex(videos, currentIndex - 2),
          _getMapEntryFromIndex(videos, currentIndex - 1),
        ];

        final next3Ids = [
          _getMapEntryFromIndex(videos, currentIndex + 1),
          _getMapEntryFromIndex(videos, currentIndex + 2),
          _getMapEntryFromIndex(videos, currentIndex + 3),
        ];

        // Add in state the 3 previus videos and the 3 next videos
        final focusedItems = [
          ...previus3Ids,
          _getMapEntryFromIndex(videos, currentIndex), // Current index
          ...next3Ids,
        ];

        // We are fetching one video at a time. So in order to
        // start fetching a video we need first to fisnish fetching
        // the current one.
        //
        // So what videos should we fetch first? Let's define a fetch order.
        //
        // The normal order of indexes of the list is:
        // [1, 2, 3, 4, 5, 6, 7]
        // If the current index is, for example, 4, the list will be:
        // We want to fetch first the fourth video because it is the
        // current selected one so it is prioritary.
        // Then, we will fetch the posterior videos because user tipically
        // scrolls more down then up. So let's fetch them first.
        // And only then, fetch the videos that are before the current index.
        // Now, the new list is: [4, 5, 6, 7, 1, 2, 3]
        final targetIndex =
            focusedItems.indexWhere((e) => e.key == currentIndex);

        List<MapEntry<int, ShortsData?>>? ordoredList;

        if (targetIndex != -1) {
          final prevCurrentIndex = focusedItems.sublist(0, targetIndex);
          final currentIndexAndPosItems = focusedItems.sublist(targetIndex);
          ordoredList = [
            ...currentIndexAndPosItems,
            ...prevCurrentIndex,
          ];
        }
        // Load the videos that are not in state
        for (final item in ordoredList ?? focusedItems) {
          if (item.key.isNegative) continue;

          if (item.value == null) {
            final VideoStats? video =
                await _youtubeVideoInfoService.getVideoByIndex(
              item.key,
            );

            if (video == null) continue;

            if (currentState == null) {
              currentState = ShortsStateWithData(videos: {
                item.key: ShortsVideoData(video: VideoDataCompleter()),
              });

              value = currentState;
            } else {
              final newState = ShortsStateWithData(videos: {
                ...currentState.videos,
                item.key: ShortsVideoData(video: VideoDataCompleter()),
              });
              currentState = newState;
              value = newState;
            }

            final player = Player();
            final hostedVideoUrl =
                Media.normalizeURI(video.hostedVideoInfo.url.toString());

            final willPlay =
                _settings.startWithAutoplay && item.key == currentIndex;

            await player.open(Media(hostedVideoUrl), play: willPlay);

            await player.setVolume(_settings.startVideoWithVolume);

            await player.setPlaylistMode(
              _settings.videosWillBeInLoop
                  ? PlaylistMode.loop
                  : PlaylistMode.none,
            );
            final state = currentState.videos[item.key];

            if (state is ShortsVideoData) {
              state.video.complete((
                videoController: VideoController(
                  player,
                  configuration: _defaultVideoControllerConfiguration,
                ),
                videoData: video,
              ));
            }
          }
        }

        // Remove from state the videos that are not in focus
        final focusedItemsIndexes = focusedItems.map((e) => e.key);

        final newMap = <int, ShortsData>{};
        currentState?.videos.forEach((key, value) async {
          if (focusedItemsIndexes.contains(key)) {
            newMap[key] = value;
          } else {
            final isKeyAlreadyInDisposeFunction = _disposeList.containsKey(key);
            if (isKeyAlreadyInDisposeFunction == false) {
              _disposeList[key] = () async {
                if (value is ShortsVideoData) {
                  final res = await value.video.future;
                  res.videoController.player.dispose();
                  if (_disposeList.containsKey(key)) {
                    _disposeList.remove(key);
                  }
                }
              };
            }
          }
        });

        value = ShortsStateWithData(
          videos: newMap,
        );

        _disposeList.forEach((key, value) {
          value();
        });
      });
    } catch (error, stackTrace) {
      value = ShortsStateError(
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  final Map<int, DisposeFunction> _disposeList = {};

  ShortsData? getVideoInIndex(int index) {
    ShortsStateWithData? currentState = _getCurrentState();
    if (currentState == null) return null;

    return currentState.videos[index];
  }

  @override
  ShortsStateWithData? _getCurrentState() {
    if (value is ShortsStateWithData) {
      final ShortsStateWithData currentValue = (value as ShortsStateWithData);
      return currentValue;
    } else {
      return null;
    }
  }

  MapEntry<int, ShortsData?> _getMapEntryFromIndex(
    Map<int, ShortsData>? videos,
    int index,
  ) {
    if (index < 0) return MapEntry(index, null);
    if (videos == null) return MapEntry(index, null);

    final targetController = videos[index];
    return MapEntry(index, targetController);
  }

  @override
  void dispose() {
    super.dispose();
    _youtubeVideoInfoService.dispose();

    ShortsStateWithData? currentState = _getCurrentState();
    final videos = currentState?.videos;
    videos?.forEach((key, value) async {
      try {
        if (value is ShortsVideoData) {
          final controller = await value.video.future;
          controller.videoController.player.dispose();
        }
      } finally {}
    });
  }
}



























/*
1 Role
quantityAds = 1 (for each 3)
adsIn: [3]
memory (0,1,2,3)
service(0,1,2)

2 Role
quantityAds = 1 (for each 3)
adsIn: [3]
memory (0,1,2,3,4)
service(0,1,2,3)

3 Role
quantityAds = 1 (for each 3)
adsIn: [3]
memory (0,1,2,3,4,5)
service(0,1,2,3,4)

4 Role
quantityAds = 1 (for each 3)
adsIn: [3]
memory (0,1,2,3,4,5,6)
service(0,1,2,3,4,5)

5 Role
quantityAds = 2 (for each 3)
adsIn: [3,7]
memory (1,2,3,4,5,6,7)
service(0,1,2,3,4,5)

6 Role
quantityAds = 2 (for each 3)
adsIn: [3,7]
memory (2,3,4,5,6,7,8)
service(0,1,2,3,4,5,6)

7 Role
quantityAds = 2 (for each 3)
adsIn: [3,7]
memory (3,4,5,6,7,8,9)
service(0,1,2,3,4,5,6,7)

8 Role
quantityAds = 2 (for each 3)
adsIn: [3,7]
memory (4,5,6,7,8,9,10)
service(0,1,2,3,4,5,6,7,8)

9 Role
quantityAds = 3 (for each 3)
adsIn: [3,7,11]
memory (5,6,7,8,9,10,11)
service(0,1,2,3,4,5,6,7,8)

10 Role
quantityAds = 3 (for each 3)
adsIn: [3,7,11]
memory (6,7,8,9,10,11,12)
service(0,1,2,3,4,5,6,7,8,9)

11 Role
quantityAds = 3 (for each 3)
adsIn: [3,7,11]
memory (7,8,9,10,11,12,13)
service(0,1,2,3,4,5,6,7,8,9,10)

12 Role
quantityAds = 3 (for each 3)
adsIn: [3,7,11]
memory (8,9,10,11,12,13,14)
service(0,1,2,3,4,5,6,7,8,9,10,11)

13 Role
quantityAds = 4 (for each 3)
adsIn: [3,7,11,15]
memory (9,10,11,12,13,14,15)
service(0,1,2,3,4,5,6,7,8,9,10,11)
*/