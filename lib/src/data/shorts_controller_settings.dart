class ShortsControllerSettings {
  final bool startWithAutoplay;
  final double startVideoWithVolume;
  final bool videosWillBeInLoop;

  const ShortsControllerSettings({
    this.startWithAutoplay = true,
    this.startVideoWithVolume = 100,
    this.videosWillBeInLoop = true,
  });

  ShortsControllerSettings copyWith({
    bool? startWithAutoplay,
    double? startVideoWithVolume,
    bool? videosWillBeInLoop,
  }) {
    return ShortsControllerSettings(
      startWithAutoplay: startWithAutoplay ?? this.startWithAutoplay,
      startVideoWithVolume: startVideoWithVolume ?? this.startVideoWithVolume,
      videosWillBeInLoop: videosWillBeInLoop ?? this.videosWillBeInLoop,
    );
  }

  @override
  String toString() =>
      'ShortsControllerSettings(startWithAutoplay: $startWithAutoplay, startVideoMuted: $startVideoWithVolume, videosWillBeInLoop: $videosWillBeInLoop)';

  @override
  bool operator ==(covariant ShortsControllerSettings other) {
    if (identical(this, other)) return true;

    return other.startWithAutoplay == startWithAutoplay &&
        other.startVideoWithVolume == startVideoWithVolume &&
        other.videosWillBeInLoop == videosWillBeInLoop;
  }

  @override
  int get hashCode =>
      startWithAutoplay.hashCode ^
      startVideoWithVolume.hashCode ^
      videosWillBeInLoop.hashCode;
}
