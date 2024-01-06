import 'dart:async';

import 'package:easy_isolate_mixin/easy_isolate_mixin.dart';
import 'package:enchanted_collection/enchanted_collection.dart';
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

class VideosSourceControllerFromUrlList extends VideosSourceController
    with IsolateHelperMixin {
  @override
  final Map<int, VideoInfo> _videos = {};

  final Map<int, String> _videoIds;

  final int initialIndex;

  VideosSourceControllerFromUrlList({
    required this.initialIndex,
    required List<String> videoIds,
  }) : _videoIds = Map.fromEntries(videoIds
            .mapper((value, isFirst, isLast, index) => MapEntry(index, value)));

  @override
  Future<VideoInfo?> getVideoByIndex(int index) async {
    return loadWithIsolate(() async {
      final cacheVideo = _videos[index];
      if (cacheVideo != null) return Future.value(cacheVideo);

      final videoid = _videoIds[index];
      if (videoid == null) return null;

      final video = await _yt.videos.get(videoid);
      final url = await getVideoUrlFromVideoModel(video);
      final VideoInfo response = (videoData: video, hostedVideoUrl: url);
      _videos[index] = response;

      return response;
    });
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
    // Perform your expensive work here
    // Return the result
    final cacheVideo = _videos[index];

    print('tracking 0: index - ($index)');
    print('tracking 1: cacheVideo - (${cacheVideo != null})');

    if (cacheVideo != null) {
      print('tracking 1 - (returned)');
      return Future.value(cacheVideo);
    }

    print(
      'tracking 2: channelUploadsList - (${channelUploadsList?.channel.value})',
    );
    if (channelUploadsList == null) {
      final channel = await _yt.channels.getByUsername(_channelName);
      print('tracking 3.1.1: channel - (${channel.id})');
      channelUploadsList = await _yt.channels.getUploadsFromPage(
        channel.id,
        VideoSorting.newest,
      );
      print(
        'tracking 3.1.2: channelUploadsList - (${channelUploadsList?.channel.value})',
      );
    } else {
      final newChannelUploadsList = await channelUploadsList?.nextPage();
      print(
        'tracking 2.2.1: newChannelUploadsList - (${newChannelUploadsList?.channel.value})',
      );
      channelUploadsList = newChannelUploadsList;
    }

    VideoInfo? desiredVideo;
    // final len = channelUploadsList?.length;
    // int innerIndex = -1;
    // for (final value in channelUploadsList ?? []) {
    //   final isLast = value == len;
    //   innerIndex += 1;

    //   final video = value;
    //   final url = await getVideoUrlFromVideoModel(video);

    //   print('tracking 4.$innerIndex: url');
    //   final VideoInfo response = (videoData: video, hostedVideoUrl: url);

    //   final newCacheIndex = _lastIndexAdded + innerIndex;
    //   _videos[newCacheIndex] = response;
    //   print('tracking 5.$innerIndex: newCacheIndex - ($newCacheIndex)');

    //   final isTargetVideo = innerIndex == index;
    //   print('tracking 6.$innerIndex: isTargetVideo - ($isTargetVideo)');
    //   if (isTargetVideo) {
    //     desiredVideo = response;
    //   }

    //   print('tracking 7.$innerIndex: isLast - ($isLast)');
    //   if (isLast) {
    //     _lastIndexAdded = _lastIndexAdded += innerIndex;
    //   }
    // }
    final list = channelUploadsList?.toList() ?? [];
    await list.forEachMapper((
      value,
      isFirst,
      isLast,
      innerIndex,
    ) async {
      final video = value;
      final url = await getVideoUrlFromVideoModel(video);

      print('tracking 4.$innerIndex: url');
      final VideoInfo response = (videoData: video, hostedVideoUrl: url);

      final newCacheIndex = _lastIndexAdded + innerIndex;
      _videos[newCacheIndex] = response;
      print('tracking 5.$innerIndex: newCacheIndex - ($newCacheIndex)');

      final isTargetVideo = innerIndex == index;
      print('tracking 6.$innerIndex: isTargetVideo - ($isTargetVideo)');
      if (isTargetVideo) {
        desiredVideo = response;
      }

      print('tracking 7.$innerIndex: isLast - ($isLast)');
      if (isLast) {
        _lastIndexAdded = _lastIndexAdded += innerIndex;
      }
    });

    final haveDesiredVideo = desiredVideo != null;
    if (haveDesiredVideo == false) {
      print('tracking 8 - (returned)');
      return null;
    }

    print('tracking 8 - SUCCESS');
    return Future.value(desiredVideo);
  }
}
