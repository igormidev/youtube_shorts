import 'dart:async';
import 'package:enchanted_collection/enchanted_collection.dart';
import 'package:youtube_shorts/src/data/type_defs.dart';
import 'package:youtube_shorts/youtube_explode_fork/youtube_explode_dart.dart';

import 'package:easy_isolate_mixin/easy_isolate_mixin.dart'
    if (dart.library.html) 'package:youtube_shorts/src/source/isolate_helper_mixin_web.dart'
    as easy_isolate_mixin;

part 'impl_from_url_list.dart';
part 'impl_from_channel_name.dart';
part 'impl_from_multiple_channels_name.dart';
part 'impl_from_channel_id.dart';
part 'impl_from_multiple_channels_ids.dart';

abstract class VideosSourceController {
  final YoutubeExplode _yt = YoutubeExplode();

  /// The key is the index of order of the video.
  /// Will always be in crescent order. (1, 2, 3).
  /// So if the index 4 exists, the index 3, 2 and 1 will also exist.
  /// The reason for using a map instead of a list is because a
  /// map is more perfomatic for inserting and removing elements.
  ///
  /// The value is the info of the video.
  abstract final Map<int, VideoStats> _cacheVideo;

  int get currentMaxLenght => _cacheVideo.length;

  Future<VideoStats?> getVideoByIndex(int index);

  void dispose() {
    _yt.close();
  }

  VideosSourceController();

  factory VideosSourceController.fromUrlList({
    required List<String> videoIds,
  }) {
    return VideosSourceControllerFromUrlList(
      videoIds: videoIds,
    );
  }

  factory VideosSourceController.fromYoutubeChannel({
    /// The name of the channel.
    required String channelName,

    /// If false, will bring all videos, even the horizontal/not shorts ones.
    bool onlyVerticalVideos = true,
  }) {
    return VideosSourceFromYoutubeChannelName(
      channelName: channelName,
      onlyVerticalVideos: onlyVerticalVideos,
    );
  }

  factory VideosSourceController.fromMultiYoutubeChannels({
    /// The name of the channels.
    required List<String> channelsName,

    /// If false, will bring all videos, even the horizontal/not shorts ones.
    bool onlyVerticalVideos = true,
  }) {
    return VideosSourceControllerFromMultipleYoutubeChannelsName(
      channelsName: channelsName,
      onlyVerticalVideos: onlyVerticalVideos,
    );
  }

  factory VideosSourceController.fromYoutubeChannelId({
    /// The id of the target youtube channel
    required String channelId,

    /// If false, will bring all videos, even the horizontal/not shorts ones.
    bool onlyVerticalVideos = true,
  }) {
    return VideosSourceFromYoutubeChannelId(
      channelId: channelId,
      onlyVerticalVideos: onlyVerticalVideos,
    );
  }

  factory VideosSourceController.fromMultiYoutubeChannelsIds({
    /// The ids of the target youtube channels
    required List<String> channelsIds,

    /// If false, will bring all videos, even the horizontal/not shorts ones.
    bool onlyVerticalVideos = true,
  }) {
    return VideosSourceControllerFromMultipleYoutubeChannelsIds(
      channelsIds: channelsIds,
      onlyVerticalVideos: onlyVerticalVideos,
    );
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
