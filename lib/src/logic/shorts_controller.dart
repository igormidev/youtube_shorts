import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart' hide Video;
import 'package:youtube_shorts/src/logic/shorts_state.dart';
import 'package:youtube_shorts/src/logic/videos_source_controller.dart';

typedef VideoData = ({VideoController videoController, VideoInfo videoData});
typedef VideoDataCompleter = Completer<VideoData>;
typedef DisposeFunction = FutureOr<void> Function();

class ShortsController extends ValueNotifier<ShortsState> {
  final VideosSourceController _youtubeVideoInfoService;
  final VideoControllerConfiguration _defaultVideoControllerConfiguration;
  final bool _startWithAutoplay;

  /// * [youtubeVideoInfoService] controller can be one of two constructors:
  ///     1. [VideosSourceController.fromUrlList]
  ///     2. [VideosSourceController.fromYoutubeChannel]
  ///
  /// * If [_startWithAutoplay] is true, the current focused video
  /// will start playing right after is dependencies are ready.
  /// Will start paused otherwise.
  ///
  /// * [VideoControllerConfiguration] is the configuration of [VideoController]
  /// of [media_kit](https://pub.dev/packages/media_kit).
  ///
  /// * [initialIndex] can only be setted if [youtubeVideoInfoService]
  /// is [VideosSourceController.fromUrlList] constructor.
  /// Other constructors `do not` suport this option.
  ShortsController({
    required VideosSourceController youtubeVideoInfoService,
    bool startWithAutoplay = true,
    VideoControllerConfiguration defaultVideoControllerConfiguration =
        const VideoControllerConfiguration(),
    int initialIndex = 0,
  })  : _startWithAutoplay = startWithAutoplay,
        _defaultVideoControllerConfiguration =
            defaultVideoControllerConfiguration,
        _youtubeVideoInfoService = youtubeVideoInfoService,
        _currentIndex = initialIndex,
        super(const ShortsStateLoading()) {
    notifyCurrentIndex(0);
  }

  int _currentIndex;

  /// Will notify the controller that the current index has changed.
  /// This will trigger the preload of the previus 3 and next 3 videos.
  void notifyCurrentIndex(int index) {
    // Let's pause the last index
    unawaited(_pauseVideoAtIndex(_currentIndex));

    _currentIndex = index;
    _preloadVideos();
  }

  Future<void> _pauseVideoAtIndex(int index) async {
    final lastVideo = getVideoInIndex(index);
    if (lastVideo != null) {
      final video = await lastVideo.future;
      video.videoController.player.pause();
    }
  }

  Future<void> _playVideoAtIndex(int index) async {
    final lastVideo = getVideoInIndex(index);
    if (lastVideo != null) {
      final video = await lastVideo.future;
      video.videoController.player.play();
    }
  }

  /// Will load the previus 3 and next 3 videos.
  Future<void> _preloadVideos() async {
    ShortsStateWithData? currentState = _getCurrentState();
    final videos = currentState?.videos;

    final previus3Ids = [
      _getMapEntryFromIndex(videos, _currentIndex - 3),
      _getMapEntryFromIndex(videos, _currentIndex - 2),
      _getMapEntryFromIndex(videos, _currentIndex - 1),
    ];

    final next3Ids = [
      _getMapEntryFromIndex(videos, _currentIndex + 1),
      _getMapEntryFromIndex(videos, _currentIndex + 2),
      _getMapEntryFromIndex(videos, _currentIndex + 3),
    ];

    // Add in state the 3 previus videos and the 3 next videos
    final focusedItems = [
      ...previus3Ids,
      _getMapEntryFromIndex(videos, _currentIndex), // Current index
      ...next3Ids,
    ];

    // Load the videos that are not in state
    for (final item in focusedItems) {
      if (item.value == null) {
        final VideoInfo? video =
            await _youtubeVideoInfoService.getVideoByIndex(item.key);
        print('${item.key} is video null: ${video == null ? '❌' : '✅'}');
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
        final hostedVideoUrl = video.hostedVideoUrl;

        final willPlay = _startWithAutoplay && item.key == _currentIndex;

        await player.open(Media(hostedVideoUrl), play: willPlay);
        await player.setVolume(100);
        currentState.videos[item.key]?.complete((
          videoController: VideoController(
            player,
            configuration: _defaultVideoControllerConfiguration,
          ),
          videoData: video,
        ));
        print('✅ dependChanged: ${item.key} added');
      } else {
        final willPlay = _startWithAutoplay && item.key == _currentIndex;
        if (willPlay) {
          _playVideoAtIndex(item.key);
        }
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
              print('❌ dependChanged: $key removed');
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
  }

  final Map<int, DisposeFunction> _disposeList = {};

  VideoDataCompleter? getVideoInIndex(int index) {
    ShortsStateWithData? currentState = _getCurrentState();
    if (currentState == null) return null;

    return currentState.videos[index];
  }

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
