import 'package:youtube_shorts/src/logic/shorts_controller.dart';

sealed class ShortsState {
  const ShortsState();
}

class ShortsStateLoading extends ShortsState {
  const ShortsStateLoading();
}

class ShortsStateWithData extends ShortsState {
  // The index and the video controller of the currently playing video.
  final Map<int, VideoDataCompleter> videos;

  int get maxLenght {
    final res = videos.keys.reduce(
      (value, element) {
        return value > element ? value : element;
      },
    );
    return res + 1;
  }

  const ShortsStateWithData({
    required this.videos,
  });
}
