part of 'interface_videos_source_controller.dart';

class VideosSourceControllerFromMultipleYoutubeChannelsIds
    extends VideosSourceController {
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
        video = await _yt.videos.get(channelUploadsVideo.id.value);
      } else {
        await channelUploads.nextPage();

        final isVideoInteractorNumberWithinChannelUploadRangeAfterFetchingNewPage =
            _videoInterationNumber < channelUploads.length;

        if (isVideoInteractorNumberWithinChannelUploadRangeAfterFetchingNewPage) {
          final channelUploadsVideo = channelUploads[_videoInterationNumber];
          video = await _yt.videos.get(channelUploadsVideo.id.value);
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
    final MuxedStreamInfo info = await getVideoInfoFromVideoModel(video);
    final VideoStats response = (videoData: video, hostedVideoInfo: info);

    _cacheVideo[index] = response;
    return response;
  }

  void _obtainChannelsUploadList() async {
    Future.wait(
      _channelsIds.map((String id) async {
        await _yt.channels
            .getUploadsFromPage(
          ChannelId(id),
          videoSorting: VideoSorting.newest,
          videoType: onlyVerticalVideos ? VideoType.shorts : VideoType.normal,
        )
            .then((uploads) {
          _data[id]!.complete(uploads);
        }).onError((error, stackTrace) {
          if (error is FatalFailureException) {
            print('FatalFailureException on id $id:\n$error');
            _data[id]!.completeError(error, stackTrace);
            throw error;
          }
          final exception = error ??
              Exception(
                'Unknown error. Please check $id',
              );
          _data[id]!.completeError(exception, stackTrace);
          throw exception;
        });
      }),
    );
  }
}
