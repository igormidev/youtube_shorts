/// The type of UI that will be displayed when the video is not focused.
sealed class NotFocusedUiType {
  const NotFocusedUiType();

  /// Will display a "mini-player" of the video
  ///
  /// This is more "heavy" for cellphone with a lot of CPU power.
  /// If you wan't something more light, use [withTumbnailType] constructor.
  factory NotFocusedUiType.withPlayerPaused() {
    return const PlayerPaused();
  }

  /// Will display the tumbnail in the videos that are now focused.
  ///
  /// This is more "light" for cellphone without a lot of CPU power.
  /// If you wan't something with more animations, use [withPlayerPaused] constructor.
  ///
  /// Select the quality of the tumbnail in [qualityType].
  factory NotFocusedUiType.withTumbnail({
    TumbnailQuality qualityType = TumbnailQuality.highResUrl,
  }) {
    return WithTumbnailType(
      quality: qualityType,
    );
  }
}

class PlayerPaused extends NotFocusedUiType {
  const PlayerPaused();
}

class WithTumbnailType extends NotFocusedUiType {
  final TumbnailQuality quality;

  const WithTumbnailType({
    required this.quality,
  });
}

enum TumbnailQuality {
  lowResUrl,
  mediumResUrl,
  highResUrl,
  standardResUrl,
  maxResUrl;
}
