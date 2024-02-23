// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:youtube_shorts/src/data/type_defs.dart';

sealed class ShortsState {
  const ShortsState();
}

class ShortsStateError extends ShortsState {
  final Object error;
  final StackTrace stackTrace;
  const ShortsStateError({
    required this.error,
    required this.stackTrace,
  });
}

class ShortsStateLoading extends ShortsState {
  const ShortsStateLoading();
}

class ShortsStateWithData extends ShortsState {
  // The index and the video controller of the currently playing video.
  final Map<int, ShortsData> videos;

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

abstract class ShortsData {
  const ShortsData();
}

class ShortsVideoData implements ShortsData {
  final VideoDataCompleter video;
  ShortsVideoData({
    required this.video,
  });
}

class ShortsAdsData implements ShortsData {
  ShortsAdsData();
}

extension ShortsStateWithDataExtension on ShortsState {
  bool get isLoadingState => this is ShortsStateLoading;
  bool get isErrorState => this is ShortsStateError;
  bool get isDataState => this is ShortsStateWithData;
}


/*

































































indexesWithAdd = [2,5,7]



































*/