part of 'interface_videos_source_controller.dart';

class VideosSourceControllerFromMultipleYoutubeChannels
    extends VideosSourceController {
  @override
  final Map<int, VideoStats> _cacheVideo = {};

  final bool onlyVerticalVideos;

  VideosSourceControllerFromMultipleYoutubeChannels({
    required List<String> channelsName,
    this.onlyVerticalVideos = true,
  })  : _channelsName = channelsName,
        _data = Map.fromEntries(channelsName
            .map((value) => MapEntry(value, Completer<ChannelUploadsList>()))) {
    _obtainChannelsUploadList();
  }

  @override
  Future<VideoStats?> getVideoByIndex(int index) async {
    final cacheVideo = _cacheVideo[index];

    if (cacheVideo != null) {
      return Future.value(cacheVideo);
    }

    return _fetchNext(index);
  }

  final List<String> _channelsName;
  final Map<String, Completer<ChannelUploadsList>> _data;

  int _channelInterationNumber = 0;

  /// The video interation number inside the channel interation
  int _videoInterationNumber = 0;

  Future<VideoStats?> _fetchNext(int index) async {
    final String channelName = _channelsName[_channelInterationNumber];
    final ChannelUploadsList channelUploads =
        (await _data[channelName]?.future)!;

    final isVideoInteractorNumberWithinChannelUploadRange =
        _videoInterationNumber < channelUploads.length;

    final Video? video;

    if (isVideoInteractorNumberWithinChannelUploadRange) {
      video = channelUploads[_videoInterationNumber];
    } else {
      await channelUploads.nextPage();

      final isVideoInteractorNumberWithinChannelUploadRangeAfterFetchingNewPage =
          _videoInterationNumber < channelUploads.length;
      if (isVideoInteractorNumberWithinChannelUploadRangeAfterFetchingNewPage) {
        video = channelUploads[_videoInterationNumber];
      } else {
        video = null;
      }
    }

    final isLastChannel = _channelInterationNumber == _channelsName.length - 1;
    if (isLastChannel) {
      _channelInterationNumber = 0;
      _videoInterationNumber++;
    } else {
      _channelInterationNumber++;
    }

    if (video == null) return _fetchNext(index);
    final MuxedStreamInfo info = await getVideoInfoFromVideoModel(video);
    final VideoStats response = (videoData: video, hostedVideoInfo: info);

    _cacheVideo[index] = response;
    return response;
  }

  void _obtainChannelsUploadList() async {
    Future.wait(
      _channelsName.map((e) async {
        final channel = await _yt.channels.getByUsername(e);
        final uploads = await _yt.channels.getUploadsFromPage(
          channel.id,
          // channel.id,
          videoSorting: VideoSorting.newest,
          videoType: onlyVerticalVideos ? VideoType.shorts : VideoType.normal,
        );
        _data[e]!.complete(uploads);
      }),
    );
  }
}
