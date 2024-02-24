part of 'interface_videos_source_controller.dart';

class VideosSourceControllerFromMultipleYoutubeChannelsIds
    extends VideosSourceController
    with easy_isolate_mixin.IsolateHelperMixin, IsolateMixinHelpers {
  @override
  final Map<int, VideoStats> _cacheVideo = {};

  final bool onlyVerticalVideos;

  VideosSourceControllerFromMultipleYoutubeChannelsIds({
    required List<String> channelsIds,
    this.onlyVerticalVideos = true,
  })  : _channelsIds = channelsIds,
        _data = Map.fromEntries(channelsIds
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

  final List<String> _channelsIds;
  final Map<String, Completer<ChannelUploadsList>> _data;

  int _channelInterationNumber = 0;

  /// The video interation number inside the channel interation
  int _videoInterationNumber = 0;

  Future<VideoStats?> _fetchNext(int index) async {
    final String channelId = _channelsIds[_channelInterationNumber];
    final ChannelUploadsList channelUploads;

    try {
      channelUploads = (await _data[channelId]?.future)!;
    } catch (_) {
      final isLastChannel = _channelInterationNumber == _channelsIds.length - 1;
      if (isLastChannel) {
        _channelInterationNumber = 0;
        _videoInterationNumber++;
      } else {
        _channelInterationNumber++;
      }
      return _fetchNext(index);
    }

    final isVideoInteractorNumberWithinChannelUploadRange =
        _videoInterationNumber < channelUploads.length;

    Video? video;
    try {
      if (isVideoInteractorNumberWithinChannelUploadRange) {
        final channelUploadsVideo = channelUploads[_videoInterationNumber];
        final String videoId = channelUploadsVideo.id.value;
        video = await getVideo(videoId);
      } else {
        await channelUploads.nextPage();

        final isVideoInteractorNumberWithinChannelUploadRangeAfterFetchingNewPage =
            _videoInterationNumber < channelUploads.length;

        if (isVideoInteractorNumberWithinChannelUploadRangeAfterFetchingNewPage) {
          final channelUploadsVideo = channelUploads[_videoInterationNumber];
          final String videoId = channelUploadsVideo.id.value;
          video = await getVideo(videoId);
        } else {
          video = null;
        }
      }
    } catch (_) {
      video = null;
    }

    final isLastChannel = _channelInterationNumber == _channelsIds.length - 1;
    if (isLastChannel) {
      _channelInterationNumber = 0;
      _videoInterationNumber++;
    } else {
      _channelInterationNumber++;
    }

    if (video == null) return _fetchNext(index);

    final MuxedStreamInfo info;
    try {
      info = await getMuxedInfo(video.id.value);
    } catch (error) {
      return _fetchNext(index);
    }
    final VideoStats response = (videoData: video, hostedVideoInfo: info);

    _cacheVideo[index] = response;
    return response;
  }

  void _obtainChannelsUploadList() async {
    for (final id in _channelsIds) {
      try {
        final uploads = _yt.channels.getUploadsFromPage(
          ChannelId(id),
          videoSorting: VideoSorting.newest,
          videoType: onlyVerticalVideos ? VideoType.shorts : VideoType.normal,
        );

        _data[id]!.complete(uploads);
      } catch (error, stackTrace) {
        final exception = error;
        _data[id]!.completeError(exception, stackTrace);
        rethrow;
      }
    }
  }
}
