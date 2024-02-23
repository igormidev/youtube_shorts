import 'dart:async';
import 'package:enchanted_collection/enchanted_collection.dart';
import 'package:youtube_shorts/src/data/type_defs.dart';
import 'package:youtube_shorts/src/source/isolate_mixin_helpers.dart';
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

  Future<MuxedStreamInfo> getVideoInfoFromVideoModel(String videoId) async {
    final StreamManifest streamInfo =
        await YoutubeExplode().videos.streamsClient.getManifest(videoId);

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

List<String> getMockedChannelIds() {
  final channelIds = <String>[];
  <String, Map<String, String>>{...brazilianAlternativas}
      .forEach((key, value) async {
    channelIds.add(value['channelId'] as String);
  });
  return channelIds;
}

Map<String, Map<String, String>> brazilianAlternativas = {
  "Athletico Paranaense": {
    "icon":
        "https://prd-images.dreamstock.soccer/640/teams/b2959ec5-9cc3-44a9-be94-ebe18b106829.png",
    "channelId": "UCUN1ASH969TSwnuUUU56TmA"
  },
  "Atlético-MG": {
    "icon":
        "https://prd-images.dreamstock.soccer/640/teams/8ef00ece-d69c-4566-b29f-ec1e6cee513f.png",
    "channelId": "UC0BhAOfmm1tJaJkPyTM9D_g"
  },
  "Vitória": {
    "icon":
        "https://prd-images.dreamstock.soccer/640/TEAM_9dd390b3-7376-4f8d-8a34-626630ff4801.png",
    "channelId": "UCT2ACrmb364amkLW8L8IhBA"
  },
  "Internacional": {
    "icon":
        "https://prd-images.dreamstock.soccer/640/TEAM_2b7e7010-df2a-426b-8f8a-37134ee0bbda.png",
    "channelId": "UC7hAvFDWwVajRqrI86KCoxA"
  },
  "Cruzeiro": {
    "icon":
        "https://prd-images.dreamstock.soccer/640/teams/723be270-0f06-48db-b8cc-8d6ac462e295.png",
    "channelId": "UCqifkpdmE1z3VhfQoJzwpJQ"
  },
  "Palmeiras": {
    "icon":
        "https://prd-images.dreamstock.soccer/640/TEAM_308bf0e7-8ab6-4136-957a-4f3e08cff3c2.png",
    "channelId": "UCBKc-rPDivvwFiWdG-81wxw"
  },
  "Fluminense": {
    "icon":
        "https://prd-images.dreamstock.soccer/640/TEAM_b92726c5-0eba-4382-afbb-d685fc7e9524.png",
    "channelId": "UCAAPXtnzlg9krw6MtNbfR-g"
  },
  "Bahia": {
    "icon":
        "https://prd-images.dreamstock.soccer/640/TEAM_d9870be0-fb71-4c0f-b146-3d773f1496ae.png",
    "channelId": "UCcqRCjHozEb9CQHwf_cffdQ"
  },
  "Criciúma": {
    "icon":
        "https://prd-images.dreamstock.soccer/640/TEAM_5caa38ee-0b2d-4736-b1e7-5c66dc7494e8.png",
    "channelId": "UC_ofom_8UQrjQJ28VqzitpQ"
  },
  "Juventude": {
    "icon":
        "https://prd-images.dreamstock.soccer/640/teams/43aa7d7c-b64b-4181-91fe-14e87fba1a53.png",
    "channelId": "UCrY4s3Eq7zSa5SE1LjoW_xg"
  },
  "Fortaleza": {
    "icon":
        "https://prd-images.dreamstock.soccer/640/teams/24701171-3c25-45d4-9af9-22ec62729b51.png",
    "channelId": "UCV5UiFF5AlNKW4sLXcYMG_g"
  },
  "Flamengo": {
    "icon":
        "https://prd-images.dreamstock.soccer/640/TEAM_51c0c8b6-da57-48b8-9c93-4e4aa048502b.png",
    "channelId": "UCOa-WaNwQaoyFHLCDk7qKIw"
  },
  "Red Bull Bragantino": {
    "icon":
        "https://prd-images.dreamstock.soccer/640/TEAM_bff6a5f3-0ed6-44a1-8aef-a62c1edb895e.png",
    "channelId": "UC0x9Ypk2Z1lUdR4a88jMC2Q"
  },
  "São Paulo": {
    "icon":
        "https://prd-images.dreamstock.soccer/640/TEAM_1f68eae1-3ee2-483f-9704-f462027ae9b5.png",
    "channelId": "UCX3zTAsEoZ61rQMYb_08Tow"
  },
  "Atlético-GO": {
    "icon":
        "https://prd-images.dreamstock.soccer/640/teams/1686b75c-eca8-4661-90c3-b7dbc0f4fb53.png",
    "channelId": "UCNhcUhri6NMKqzGju0QOUKg"
  },
  "Botafogo": {
    "icon":
        "https://prd-images.dreamstock.soccer/640/teams/6d1ad9db-02d2-4491-8a55-f9912f04f791.png",
    "channelId": "UCFxjZDrLCOCHkUCu632AmMQ"
  },
  "Grêmio": {
    "icon":
        "https://prd-images.dreamstock.soccer/640/TEAM_21c41d3e-5b9c-4d44-b613-c3ec300089c4.png",
    "channelId": "UCHKbUAiKHsWCCZrkDY_PZ8Q"
  },
  "Corinthians": {
    "icon":
        "https://prd-images.dreamstock.soccer/640/TEAM_1a4c8296-e104-413c-afe0-ebd4a3d33ee2.png",
    "channelId": "UCqRraVICLr0asn90cAvkIZQ"
  }
};
