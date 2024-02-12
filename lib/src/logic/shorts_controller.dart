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
        // We will not wait this

        final VideoData video = await previousVideo.future;
        unawaited(video.videoController.player.pause());

        onPrevVideoPause?.call(video, prevIndex, currentIndex);
      }
    }

    if (_settings.startWithAutoplay == false) return;

    final currentVideo = getVideoInIndex(currentIndex);
    if (currentVideo != null) {
      final VideoData video = await currentVideo.future;
      await video.videoController.player.play();
      onCurrentVideoPlay?.call(video, prevIndex, currentIndex);
    }
  }

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
        List<MapEntry<int, VideoDataCompleter?>>? ordoredList;
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
                item.key: VideoDataCompleter(),
              });

              value = currentState;
            } else {
              final newState = ShortsStateWithData(videos: {
                ...currentState.videos,
                item.key: VideoDataCompleter(),
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
            currentState.videos[item.key]?.complete((
              videoController: VideoController(
                player,
                configuration: _defaultVideoControllerConfiguration,
              ),
              videoData: video,
            ));
          }
        }

        // Remove from state the videos that are not in focus
        final focusedItemsIndexes = focusedItems.map((e) => e.key);

        final newMap = <int, VideoDataCompleter>{};
        currentState?.videos.forEach((key, value) async {
          if (focusedItemsIndexes.contains(key)) {
            newMap[key] = value;
          } else {
            final isKeyAlreadyInDisposeFunction = _disposeList.containsKey(key);
            if (isKeyAlreadyInDisposeFunction == false) {
              _disposeList[key] = () async {
                final res = await value.future;
                res.videoController.player.dispose();
                if (_disposeList.containsKey(key)) {
                  _disposeList.remove(key);
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

  VideoDataCompleter? getVideoInIndex(int index) {
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

  MapEntry<int, VideoDataCompleter?> _getMapEntryFromIndex(
    Map<int, VideoDataCompleter>? videos,
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
        final controller = await value.future;
        controller.videoController.player.dispose();
      } finally {}
    });
  }
}
