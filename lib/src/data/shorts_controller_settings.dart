class ShortsControllerSettings {
  final bool startWithAutoplay;
  final bool startVideoMuted;
  final bool videosWillBeInLoop;

  const ShortsControllerSettings({
    this.startWithAutoplay = true,
    this.startVideoMuted = false,
    this.videosWillBeInLoop = true,
  });

  ShortsControllerSettings copyWith({
    bool? startWithAutoplay,
    bool? startVideoMuted,
    bool? videosWillBeInLoop,
  }) {
    return ShortsControllerSettings(
      startWithAutoplay: startWithAutoplay ?? this.startWithAutoplay,
      startVideoMuted: startVideoMuted ?? this.startVideoMuted,
      videosWillBeInLoop: videosWillBeInLoop ?? this.videosWillBeInLoop,
    );
  }

  @override
  String toString() =>
      'ShortsControllerSettings(startWithAutoplay: $startWithAutoplay, startVideoMuted: $startVideoMuted, videosWillBeInLoop: $videosWillBeInLoop)';

  @override
  bool operator ==(covariant ShortsControllerSettings other) {
    if (identical(this, other)) return true;

    return other.startWithAutoplay == startWithAutoplay &&
        other.startVideoMuted == startVideoMuted &&
        other.videosWillBeInLoop == videosWillBeInLoop;
  }

  @override
  int get hashCode =>
      startWithAutoplay.hashCode ^
      startVideoMuted.hashCode ^
      videosWillBeInLoop.hashCode;
}
