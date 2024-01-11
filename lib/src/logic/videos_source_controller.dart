import 'dart:async';
import 'package:easy_isolate_mixin/easy_isolate_mixin.dart';
import 'package:enchanted_collection/enchanted_collection.dart';
import 'package:youtube_shorts/youtube_explode_fork/youtube_explode_dart.dart';

typedef VideoStats = ({Video videoData, MuxedStreamInfo hostedVideoInfo});

abstract class VideosSourceController {
  final YoutubeExplode _yt = YoutubeExplode();

  /// The key is the index of order of the video.
  /// Will always be in crescent order. (1, 2, 3).
  /// So if the index 4 exists, the index 3, 2 and 1 will also exist.
  /// The reason for using a map instead of a list is because a
  /// map is more perfomatic for inserting and removing elements.
  ///
  /// The value is the info of the video.
  abstract final Map<int, VideoStats> _videos;

  int get currentMaxLenght => _videos.length;

  Future<VideoStats?> getVideoByIndex(int index);

  void dispose() {
    _yt.close();
  }

  VideosSourceController();

  factory VideosSourceController.fromUrlList({
    int initialIndex = 0,
    required List<String> videoIds,
  }) {
    return VideosSourceControllerFromUrlList(
      initialIndex: initialIndex,
      videoIds: videoIds,
    );
  }

  factory VideosSourceController.fromYoutubeChannel({
    required String channelName,
  }) {
    return VideosSourceControllerYoutubeChannel(channelName: channelName);
  }

  Future<MuxedStreamInfo> getVideoInfoFromVideoModel(Video video) async {
    final StreamManifest streamInfo =
        await _yt.videos.streamsClient.getManifest(video.id);

    final onlyNumberRegex = RegExp(r'[^0-9]');

    int currentBiggestQuality = 0;

    MuxedStreamInfo? muxedStreamInfo;

    // Get the maximum quality
    for (final element in streamInfo.muxed) {
      final qualityLabelInDouble =
          int.tryParse(element.qualityLabel.replaceAll(onlyNumberRegex, ''));
      if (qualityLabelInDouble == null) continue;

      if (qualityLabelInDouble > currentBiggestQuality) {
        currentBiggestQuality = qualityLabelInDouble;
        muxedStreamInfo = element;
      }
    }

    if (currentBiggestQuality == 0 || muxedStreamInfo == null) {
      muxedStreamInfo = streamInfo.muxed.last;
    }

    return muxedStreamInfo;
  }
}

class VideosSourceControllerFromUrlList extends VideosSourceController
    with IsolateHelperMixin {
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
