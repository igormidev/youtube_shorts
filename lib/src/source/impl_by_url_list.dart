part of 'interface_videos_source_controller.dart';

class VideosSourceControllerFromUrlList extends VideosSourceController
    with easy_isolate_mixin.IsolateHelperMixin {
  @override
  final Map<int, VideoStats> _videos = {};

  final Map<int, String> _videoIds;

  final int initialIndex;

  VideosSourceControllerFromUrlList({
    required this.initialIndex,
    required List<String> videoIds,
  }) : _videoIds = Map.fromEntries(videoIds
            .mapper((value, isFirst, isLast, index) => MapEntry(index, value)));

  @override
  Future<VideoStats?> getVideoByIndex(int index) async {
    return loadWithIsolate(() async {
      final cacheVideo = _videos[index];
      if (cacheVideo != null) return Future.value(cacheVideo);

      final videoid = _videoIds[index];
      if (videoid == null) return null;

      final video = await _yt.videos.get(videoid);
      final info = await getVideoInfoFromVideoModel(video);
      final VideoStats response = (videoData: video, hostedVideoInfo: info);
      _videos[index] = response;

      return response;
    });
  }
}
