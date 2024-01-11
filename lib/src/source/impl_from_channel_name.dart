part of 'interface_videos_source_controller.dart';

class VideosSourceControllerYoutubeChannel extends VideosSourceController {
  @override
  final Map<int, VideoStats> _videos = {};

  final String _channelName;

  ChannelUploadsList? channelUploadsList;

  int _lastIndexAdded = 0;
  final bool onlyVerticalVideos;

  VideosSourceControllerYoutubeChannel({
    required String channelName,
    this.onlyVerticalVideos = true,
  }) : _channelName = channelName;

  @override
  Future<VideoStats?> getVideoByIndex(int index) async {
    final cacheVideo = _videos[index];

    if (cacheVideo != null) {
      return Future.value(cacheVideo);
    }

    if (channelUploadsList == null) {
      final channel = await _yt.channels.getByUsername(_channelName);
      channelUploadsList = await _yt.channels.getUploadsFromPage(
        channel.id,
        videoSorting: VideoSorting.newest,
        videoType: VideoType.shorts,
      );
    } else {
      final newChannelUploadsList = await channelUploadsList?.nextPage();
      channelUploadsList = newChannelUploadsList;
    }

    VideoStats? desiredVideo;
    final list = channelUploadsList?.toList() ?? [];

    await list.forEachMapper((
      value,
      isFirst,
      isLast,
      innerIndex,
    ) async {
      final video = value;
      final MuxedStreamInfo info = await getVideoInfoFromVideoModel(video);

      final VideoStats response = (videoData: video, hostedVideoInfo: info);

      final newCacheIndex = _lastIndexAdded + innerIndex;
      _videos[newCacheIndex] = response;

      final isTargetVideo = innerIndex == index;
      if (isTargetVideo) {
        desiredVideo = response;
      }

      if (isLast) {
        _lastIndexAdded = _lastIndexAdded += innerIndex;
      }
    });

    final haveDesiredVideo = desiredVideo != null;
    if (haveDesiredVideo == false) {
      return null;
    }

    return Future.value(desiredVideo);
  }
}
