part of 'interface_videos_source_controller.dart';

class VideosSourceFromYoutubeChannelName extends VideosSourceController {
  @override
  final Map<int, VideoStats> _cacheVideo = {};

  final String _channelName;

  ChannelUploadsList? channelUploadsList;

  final bool onlyVerticalVideos;

  VideosSourceFromYoutubeChannelName({
    required String channelName,
    this.onlyVerticalVideos = true,
  })  : _channelName = channelName,
        _data = Completer() {
    _obtainChannelsUploadList();
  }

  final Completer<ChannelUploadsList> _data;

  @override
  Future<VideoStats?> getVideoByIndex(int index) async {
    final cacheVideo = _cacheVideo[index];

    if (cacheVideo != null) {
      return Future.value(cacheVideo);
    }

    return _fetchNext(index);
  }

  /// The video interation number inside the channel interation
  int _videoInterationNumber = 0;

  Future<VideoStats?> _fetchNext(int index) async {
    final ChannelUploadsList channelUploads = await _data.future;

    final isVideoInteractorNumberWithinChannelUploadRange =
        _videoInterationNumber < channelUploads.length;

    final Video video;

    if (isVideoInteractorNumberWithinChannelUploadRange) {
      final channelUploadsVideo = channelUploads[_videoInterationNumber];
      video = await _yt.videos.get(channelUploadsVideo.id.value);
    } else {
      await channelUploads.nextPage();

      final isVideoInteractorNumberWithinChannelUploadRangeAfterFetchingNewPage =
          _videoInterationNumber < channelUploads.length;

      if (isVideoInteractorNumberWithinChannelUploadRangeAfterFetchingNewPage) {
        final channelUploadsVideo = channelUploads[_videoInterationNumber];
        video = await _yt.videos.get(channelUploadsVideo.id.value);
      } else {
        return null;
      }
    }

    _videoInterationNumber++;

    final MuxedStreamInfo info = await getVideoInfoFromVideoModel(video);
    final VideoStats response = (videoData: video, hostedVideoInfo: info);

    _cacheVideo[index] = response;
    return response;
  }

  void _obtainChannelsUploadList() async {
    final channel = await _yt.channels.getByUsername(_channelName);
    final uploads = await _yt.channels.getUploadsFromPage(
      channel.id,
      videoSorting: VideoSorting.newest,
      videoType: onlyVerticalVideos ? VideoType.shorts : VideoType.normal,
    );

    _data.complete(uploads);
  }
}
