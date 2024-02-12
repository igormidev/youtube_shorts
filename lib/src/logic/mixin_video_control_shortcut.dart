part of 'shorts_controller.dart';

mixin MixinVideoControlShortcut {
  final Lock _videoControllerLock = Lock();
  ShortsStateWithData? _getCurrentState();
  int get currentIndex;

  /// ### Will pause current player.
  ///
  /// Will only work if state is [ShortsStateWithData].
  /// Will look for the VideoData of the [currentIndex] and pause it.
  /// If the video is not ready/loaded yet, will wait for it to be ready and then pause it.
  Future<void> pauseCurrentVideo() async {
    final currentState = _getCurrentState();
    if (currentState == null) return;

    final currentVideoFuture = currentState.videos[currentIndex];
    if (currentVideoFuture == null) return;

    return await _videoControllerLock.synchronized(() async {
      final currentVideo = await currentVideoFuture.future;
      currentVideo.videoController.player.pause();
    });
  }

  /// ### Will play current player.
  ///
  /// Will only work if state is [ShortsStateWithData].
  /// Will look for the VideoData of the [currentIndex] and play it.
  /// If the video is not ready/loaded yet, will wait for it to be ready and then play it.
  Future<void> playCurrentVideo() async {
    final currentState = _getCurrentState();
    if (currentState == null) return;

    final currentVideoFuture = currentState.videos[currentIndex];
    if (currentVideoFuture == null) return;

    return await _videoControllerLock.synchronized(() async {
      final currentVideo = await currentVideoFuture.future;
      currentVideo.videoController.player.play();
    });
  }

  /// ### Will mute current player.
  ///
  /// Will only work if state is [ShortsStateWithData].
  /// Will look for the VideoData of the [currentIndex] and mute it.
  /// If the video is not ready/loaded yet, will wait for it to be ready and then mute it.
  Future<void> muteCurrentVideo() async {
    final currentState = _getCurrentState();
    if (currentState == null) return;

    final currentVideoFuture = currentState.videos[currentIndex];
    if (currentVideoFuture == null) return;

    return await _videoControllerLock.synchronized(() async {
      final currentVideo = await currentVideoFuture.future;
      currentVideo.videoController.player.setVolume(0);
    });
  }

  /// ### Will mute current player.
  ///
  /// Will only work if state is [ShortsStateWithData].
  /// Will look for the VideoData of the [currentIndex] and mute it.
  /// If the video is not ready/loaded yet, will wait for it to be ready and then mute it.
  Future<void> muteVideoWithIndex(int index) async {
    final currentState = _getCurrentState();
    if (currentState == null) return;

    final videoFuture = currentState.videos[index];
    if (videoFuture == null) return;

    return await _videoControllerLock.synchronized(() async {
      final video = await videoFuture.future;
      video.videoController.player.setVolume(0);
    });
  }

  /// ### Will set the volume of the current player to the [volume] target.
  /// This [target] must be between 0 (muted) and 100.
  ///
  /// Will only work if state is [ShortsStateWithData].
  /// Will look for the VideoData of the [currentIndex] and set the volume to the [volume] target.
  /// If the video is not ready/loaded yet, will wait for it to be ready and then set the volume to the [volume] target.
  Future<void> setCurrentVideoVolume(double volume) async {
    final currentState = _getCurrentState();
    if (currentState == null) return;

    final currentVideoFuture = currentState.videos[currentIndex];
    if (currentVideoFuture == null) return;

    return _videoControllerLock.synchronized(() async {
      final currentVideo = await currentVideoFuture.future;
      currentVideo.videoController.player.setVolume(volume);
    });
  }

  /// ### Will set the volume of the current player to the [volume] target.
  /// This [target] must be between 0 (muted) and 100.
  ///
  /// Will only work if state is [ShortsStateWithData].
  /// Will look for the VideoData of the [index] and set the volume to the [volume] target.
  /// If the video is not ready/loaded yet, will wait for it to be ready and then set the volume to the [volume] target.
  Future<void> setVideoVolumeWithIndex(double volume, int index) async {
    final currentState = _getCurrentState();
    if (currentState == null) return;

    final currentVideoFuture = currentState.videos[index];
    if (currentVideoFuture == null) return;

    return _videoControllerLock.synchronized(() async {
      final currentVideo = await currentVideoFuture.future;
      currentVideo.videoController.player.setVolume(volume);
    });
  }
}
