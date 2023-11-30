import 'package:youtube_shorts/src/utils/extensions.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

typedef VideoInfo = ({Video videoData, String hostedVideoUrl});

abstract class VideosSourceController {
  final YoutubeExplode _yt = YoutubeExplode();

  /// The key is the index of order of the video.
  /// Will always be in crescent order. (1, 2, 3).
  /// So if the index 4 exists, the index 3, 2 and 1 will also exist.
  /// The reason for using a map instead of a list is because a
  /// map is more perfomatic for inserting and removing elements.
  ///
  /// The value is the info of the video.
  abstract final Map<int, VideoInfo> _videos;

  int get currentMaxLenght => _videos.length;

  Future<VideoInfo?> getVideoByIndex(int index);

  void dispose() {
    _yt.close();
  }

  VideosSourceController();

  factory VideosSourceController.fromUrlList({
    required List<String> videoIds,
  }) {
    return VideosSourceControllerFromUrlList(videoIds: videoIds);
  }

  factory VideosSourceController.fromYoutubeChannel({
    required String channelName,
  }) {
    return VideosSourceControllerYoutubeChannel(channelName: channelName);
  }

  Future<String> getVideoUrlFromVideoModel(Video video) async {
    final StreamManifest streamInfo =
        await _yt.videos.streamsClient.getManifest(video.id);

    final onlyNumberRegex = RegExp(r'[^0-9]');

    int currentBiggestQuality = 0;
    String currentBiggestQualityUrl = '';
    for (final element in streamInfo.muxed) {
      final qualityLabelInDouble =
          int.tryParse(element.qualityLabel.replaceAll(onlyNumberRegex, ''));
      if (qualityLabelInDouble == null) continue;

      if (qualityLabelInDouble > currentBiggestQuality) {
        currentBiggestQuality = qualityLabelInDouble;
        currentBiggestQualityUrl = element.url.toString();
      }
    }

    if (currentBiggestQuality == 0) {
      currentBiggestQualityUrl = streamInfo.muxed.last.url.toString();
    }

    return currentBiggestQualityUrl;
  }
}

class VideosSourceControllerFromUrlList extends VideosSourceController {
  @override
  final Map<int, VideoInfo> _videos = {};

  final Map<int, String> _videoIds;

  VideosSourceControllerFromUrlList({
    required List<String> videoIds,
  }) : _videoIds = Map.fromEntries(videoIds
            .mapper((value, isFirst, isLast, index) => MapEntry(index, value)));

  @override
  Future<VideoInfo?> getVideoByIndex(int index) async {
    final cacheVideo = _videos[index];
    if (cacheVideo != null) return Future.value(cacheVideo);

    final videoid = _videoIds[index];
    if (videoid == null) return null;

    final video = await _yt.videos.get(videoid);
    final url = await getVideoUrlFromVideoModel(video);
    final VideoInfo response = (videoData: video, hostedVideoUrl: url);
    _videos[index] = response;

    return response;
  }
}

class VideosSourceControllerYoutubeChannel extends VideosSourceController {
  @override
  final Map<int, VideoInfo> _videos = {};

  final String _channelName;

  ChannelUploadsList? channelUploadsList;

  int _lastIndexAdded = 0;

  VideosSourceControllerYoutubeChannel({
    required String channelName,
  }) : _channelName = channelName;

  @override
  Future<VideoInfo?> getVideoByIndex(int index) async {
    final cacheVideo = _videos[index];
    if (cacheVideo != null) return Future.value(cacheVideo);

    if (channelUploadsList == null) {
      final channel = await _yt.channels.getByUsername(_channelName);
      channelUploadsList = await _yt.channels.getUploadsFromPage(
        channel.id,
        VideoSorting.newest,
      );
    } else {
      final newChannelUploadsList = await channelUploadsList?.nextPage();
      channelUploadsList = newChannelUploadsList;
    }

    VideoInfo? desiredVideo;
    await channelUploadsList?.forEachMapper((
      value,
      isFirst,
      isLast,
      innerIndex,
    ) async {
      print('innerIndex: $innerIndex');
      final video = value;
      final url = await getVideoUrlFromVideoModel(video);
      final VideoInfo response = (videoData: video, hostedVideoUrl: url);

      _videos[_lastIndexAdded + innerIndex] = response;

      if (innerIndex == index) {
        desiredVideo = response;
      }

      if (isLast) {
        _lastIndexAdded = _lastIndexAdded += innerIndex;
      }
    });

    if (desiredVideo == null) {
      return null;
    }

    return Future.value(desiredVideo);
  }
}
