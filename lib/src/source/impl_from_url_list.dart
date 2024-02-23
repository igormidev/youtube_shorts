part of 'interface_videos_source_controller.dart';

class VideosSourceControllerFromUrlList extends VideosSourceController
    with easy_isolate_mixin.IsolateHelperMixin {
  @override
  final Map<int, VideoStats> _cacheVideo = {};

  final Map<int, String> _videoIds;

  VideosSourceControllerFromUrlList({
    required List<String> videoIds,
  }) : _videoIds = Map.fromEntries(videoIds
            .mapper((value, isFirst, isLast, index) => MapEntry(index, value)));

  @override
  Future<VideoStats?> getVideoByIndex(int index) async {
    return loadWithIsolate(() async {
      final cacheVideo = _cacheVideo[index];
      if (cacheVideo != null) return Future.value(cacheVideo);

      final videoid = _videoIds[index];
      if (videoid == null) return null;

      final Video video = await _yt.videos.get(videoid);
      final MuxedStreamInfo info = await getVideoInfoFromVideoModel(
        video.id.value,
      );
      final VideoStats response = (videoData: video, hostedVideoInfo: info);
      _cacheVideo[index] = response;

      return response;
    });
  }
}
