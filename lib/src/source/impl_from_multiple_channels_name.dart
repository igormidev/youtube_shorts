part of 'interface_videos_source_controller.dart';

class VideosSourceControllerFromMultipleYoutubeChannels
    extends VideosSourceController {
  @override
  final Map<int, VideoStats> _videos = {};

  final List<String> _channelsName;

  VideosSourceControllerFromMultipleYoutubeChannels({
    required List<String> channelsName,
  }) : _channelsName = channelsName {
    outStream.listen((event) {
      _videos[event.$1] = event.$2;
    });
    _fetchVideosCluster();
  }

  final StreamController<(int, VideoStats)> _videosFetcher =
      StreamController<(int, VideoStats)>.broadcast();

  StreamSink<(int, VideoStats)> get inStream => _videosFetcher.sink;
  Stream<(int, VideoStats)> get outStream => _videosFetcher.stream;

  /// The numbers of fetch this video already did.
  int _clusterIndex = 0;

  @override
  Future<VideoStats?> getVideoByIndex(int index) async {
    final cacheVideo = _videos[index];

    if (cacheVideo != null) {
      return Future.value(cacheVideo);
    }

    final res = await outStream.firstWhere((element) => element.$1 == index);
    return res.$2;
  }

  @override
  void dispose() {
    _videosFetcher.close();
  }

  void _fetchVideosCluster() async {
    for (final String channelName in _channelsName) {
      final channel = await _yt.channels.getByUsername(channelName);

      final ChannelUploadsList channelUploadsList =
          await _yt.channels.getUploadsFromPage(
        channel.id,
        videoSorting: VideoSorting.newest,
        videoType: VideoType.shorts,
      );

      for (final Video video in channelUploadsList) {
        final MuxedStreamInfo info = await getVideoInfoFromVideoModel(video);
        final VideoStats response = (videoData: video, hostedVideoInfo: info);

        print('Adding video ${_videos.length} to the stream');
        inStream.add((_videos.length, response));
      }
    }

    print('Finishing adding videos to the stream');
    _clusterIndex++;
  }
}
