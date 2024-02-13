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

  void printListOfMockedChannels() async {
    <String, String>{...brazileiraoSerieB, ...brazileiraoSerieC}
        .forEach((key, value) async {
      final channelId = (await _yt.videos.get(value)).channelId;
      print('\'$key\': \'$channelId\'');
    });
  }
}

List<String> getMockedChannelsIds() {
  return brazilianMocks.values.map((e) => e['channelId']!).toList();
}

Map<String, Map<String, String>> brazilianMocks = {
  'Athletico Paranaense': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/teams/b2959ec5-9cc3-44a9-be94-ebe18b106829.png',
    'channelId': 'UCUN1ASH969TSwnuUUU56TmA',
  },
  'Atlético-MG': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/teams/8ef00ece-d69c-4566-b29f-ec1e6cee513f.png',
    'channelId': 'UC0BhAOfmm1tJaJkPyTM9D_g',
  },
  'Vitória': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/TEAM_9dd390b3-7376-4f8d-8a34-626630ff4801.png',
    'channelId': 'UCT2ACrmb364amkLW8L8IhBA',
  },
  'Internacional': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/TEAM_2b7e7010-df2a-426b-8f8a-37134ee0bbda.png',
    'channelId': 'UC7hAvFDWwVajRqrI86KCoxA',
  },
  'Cruzeiro': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/teams/723be270-0f06-48db-b8cc-8d6ac462e295.png',
    'channelId': 'UCqifkpdmE1z3VhfQoJzwpJQ',
  },
  'Palmeiras': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/TEAM_308bf0e7-8ab6-4136-957a-4f3e08cff3c2.png',
    'channelId': 'UCBKc-rPDivvwFiWdG-81wxw',
  },
  'Fluminense': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/TEAM_b92726c5-0eba-4382-afbb-d685fc7e9524.png',
    'channelId': 'UCAAPXtnzlg9krw6MtNbfR-g',
  },
  'Santos': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/teams/191eec60-3ff4-4074-9d65-8e4f3f56ceb4.png',
    'channelId': 'UCF7ki7lz9TduY-I6s3uZp-Q',
  },
  'Bahia': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/TEAM_d9870be0-fb71-4c0f-b146-3d773f1496ae.png',
    'channelId': 'UCcqRCjHozEb9CQHwf_cffdQ',
  },
  'Criciúma': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/TEAM_5caa38ee-0b2d-4736-b1e7-5c66dc7494e8.png',
    'channelId': 'UC_ofom_8UQrjQJ28VqzitpQ',
  },
  'Juventude': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/teams/43aa7d7c-b64b-4181-91fe-14e87fba1a53.png',
    'channelId': 'UCrY4s3Eq7zSa5SE1LjoW_xg',
  },
  'Fortaleza': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/teams/24701171-3c25-45d4-9af9-22ec62729b51.png',
    'channelId': 'UCV5UiFF5AlNKW4sLXcYMG_g',
  },
  'Vasco da Gama': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/teams/ddc671e0-b5e7-44dc-92fd-b8ac65492bd6.png',
    'channelId': 'UCZD5qcen7lbLPFTjfvdLFcw',
  },
  'Flamengo': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/TEAM_51c0c8b6-da57-48b8-9c93-4e4aa048502b.png',
    'channelId': 'UCOa-WaNwQaoyFHLCDk7qKIw',
  },
  'Red Bull Bragantino': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/TEAM_bff6a5f3-0ed6-44a1-8aef-a62c1edb895e.png',
    'channelId': 'UC0x9Ypk2Z1lUdR4a88jMC2Q',
  },
  'São Paulo': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/TEAM_1f68eae1-3ee2-483f-9704-f462027ae9b5.png',
    'channelId': 'UCX3zTAsEoZ61rQMYb_08Tow',
  },
  'Atlético-GO': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/teams/1686b75c-eca8-4661-90c3-b7dbc0f4fb53.png',
    'channelId': 'UCNhcUhri6NMKqzGju0QOUKg',
  },
  'Botafogo': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/teams/6d1ad9db-02d2-4491-8a55-f9912f04f791.png',
    'channelId': 'UCFxjZDrLCOCHkUCu632AmMQ',
  },
  'Grêmio': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/TEAM_21c41d3e-5b9c-4d44-b613-c3ec300089c4.png',
    'channelId': 'UCHKbUAiKHsWCCZrkDY_PZ8Q',
  },
  'Corinthians': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/TEAM_1a4c8296-e104-413c-afe0-ebd4a3d33ee2.png',
    'channelId': 'UCqRraVICLr0asn90cAvkIZQ',
  },
};

Map<String, Map<String, String>> oldbrazilianMocks = {
  'Athletico Paranaense': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/teams/b2959ec5-9cc3-44a9-be94-ebe18b106829.png',
    'channelId': 'UCUN1ASH969TSwnuUUU56TmA',
  },
  'Atlético-MG': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/teams/8ef00ece-d69c-4566-b29f-ec1e6cee513f.png',
    'channelId': 'UC0BhAOfmm1tJaJkPyTM9D_g',
  },
  'Vitória': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/TEAM_9dd390b3-7376-4f8d-8a34-626630ff4801.png',
    'channelId': 'UCT2ACrmb364amkLW8L8IhBA',
  },
  'Internacional': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/TEAM_2b7e7010-df2a-426b-8f8a-37134ee0bbda.png',
    'channelId': 'UC7hAvFDWwVajRqrI86KCoxA',
  },
  'Cruzeiro': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/teams/723be270-0f06-48db-b8cc-8d6ac462e295.png',
    'channelId': 'UCqifkpdmE1z3VhfQoJzwpJQ',
  },
  'Palmeiras': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/TEAM_308bf0e7-8ab6-4136-957a-4f3e08cff3c2.png',
    'channelId': 'UCBKc-rPDivvwFiWdG-81wxw',
  },
  // 'Cuiabá': {
  //   'icon':
  //       'https://prd-images.dreamstock.soccer/640/teams/cc878ab9-d12c-4c1f-8658-c580a599cf00.png',
  //   'channelId': 'UCnvMjCptspOne0ztN7z-KHg',
  // },
  'Fluminense': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/TEAM_b92726c5-0eba-4382-afbb-d685fc7e9524.png',
    'channelId': 'UCAAPXtnzlg9krw6MtNbfR-g',
  },
  'Bahia': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/TEAM_d9870be0-fb71-4c0f-b146-3d773f1496ae.png',
    'channelId': 'UCcqRCjHozEb9CQHwf_cffdQ',
  },
  'Criciúma': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/TEAM_5caa38ee-0b2d-4736-b1e7-5c66dc7494e8.png',
    'channelId': 'UC_ofom_8UQrjQJ28VqzitpQ',
  },
  'Juventude': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/teams/43aa7d7c-b64b-4181-91fe-14e87fba1a53.png',
    'channelId': 'UCrY4s3Eq7zSa5SE1LjoW_xg',
  },
  'Fortaleza': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/teams/24701171-3c25-45d4-9af9-22ec62729b51.png',
    'channelId': 'UCV5UiFF5AlNKW4sLXcYMG_g',
  },
  'Vasco da Gama': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/teams/ddc671e0-b5e7-44dc-92fd-b8ac65492bd6.png',
    'channelId': 'UCZD5qcen7lbLPFTjfvdLFcw',
  },
  'Flamengo': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/TEAM_51c0c8b6-da57-48b8-9c93-4e4aa048502b.png',
    'channelId': 'UCOa-WaNwQaoyFHLCDk7qKIw',
  },
  'Red Bull Bragantino': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/TEAM_bff6a5f3-0ed6-44a1-8aef-a62c1edb895e.png',
    'channelId': 'UC0x9Ypk2Z1lUdR4a88jMC2Q',
  },
  'São Paulo': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/TEAM_1f68eae1-3ee2-483f-9704-f462027ae9b5.png',
    'channelId': 'UCX3zTAsEoZ61rQMYb_08Tow',
  },
  'Atlético-GO': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/teams/1686b75c-eca8-4661-90c3-b7dbc0f4fb53.png',
    'channelId': 'UCNhcUhri6NMKqzGju0QOUKg',
  },
  'Botafogo': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/teams/6d1ad9db-02d2-4491-8a55-f9912f04f791.png',
    'channelId': 'UCFxjZDrLCOCHkUCu632AmMQ',
  },
  'Grêmio': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/TEAM_21c41d3e-5b9c-4d44-b613-c3ec300089c4.png',
    'channelId': 'UCHKbUAiKHsWCCZrkDY_PZ8Q',
  },
  'Corinthians': {
    'icon':
        'https://prd-images.dreamstock.soccer/640/TEAM_1a4c8296-e104-413c-afe0-ebd4a3d33ee2.png',
    'channelId': 'UCqRraVICLr0asn90cAvkIZQ',
  },
};
final Map<String, String> brazileiraoSerieA = {
  'Athletico Paranaense': 'https://www.youtube.com/watch?v=8owVRxqzbc0',
  'Atlético-GO': 'https://www.youtube.com/watch?v=3DLlq6YWz6U',
  'Atlético mineiro': 'https://www.youtube.com/watch?v=rul4w8WxZz8&t=36s',
  'Bahia': 'https://www.youtube.com/watch?v=ZfYJfY8Bl6g',
  'Botafogo': 'https://www.youtube.com/watch?v=SdIqLAZ7S1s',
  'Bragantino': 'https://www.youtube.com/watch?v=mSnzIpsb4vM',
  'Corinthians': 'https://www.youtube.com/watch?v=Gn2-xwFUqHQ',
  'Criciúma': 'https://www.youtube.com/watch?v=1KiPMWmyDQc&t=27s',
  'Cruzeiro': 'https://www.youtube.com/watch?v=JDUShl7jFYk',
  'Cuiabá': 'https://www.youtube.com/watch?v=WZuG6CWZeWk',
  'Flamengo': 'https://www.youtube.com/watch?v=rDgf1XfWNKU&t=528s',
  'Fluminense': 'https://www.youtube.com/watch?v=1rp8pZlCzZg',
  'Fortaleza': 'https://www.youtube.com/watch?v=9Aze9JRd0RY',
  'Grêmio': 'https://www.youtube.com/watch?v=NjQNP-UbmXs',
  'Internacional': 'https://www.youtube.com/watch?v=kyUX1x9W_6k',
  'Juventude': 'https://www.youtube.com/watch?v=XJTcHOU5DZA',
  'Palmeiras': 'https://www.youtube.com/watch?v=5VcWFhscd9E&t=289s',
  'São Paulo': 'https://www.youtube.com/watch?v=pL3bK6LOiow',
  'Vasco': 'https://www.youtube.com/watch?v=wafQvY9H9AA',
  'EC Vitória': 'https://www.youtube.com/watch?v=Uxum3C9SJt8',
};

final Map<String, String> brazileiraoSerieB = {
  "Amazonas: tem": "https://www.youtube.com/watch?v=LZu3hiyIcT4",
  "Avaí: tem": "https://www.youtube.com/watch?v=Z6OFe2s16-c",
  "Botafogo-SP: tem": "https://www.youtube.com/watch?v=nPBLptO1lbQ",
  "Brusque: tem": "https://www.youtube.com/watch?v=uSc0-CX4MW4",
  "Ceará: tem": "https://www.youtube.com/watch?v=0OzKMTMcrDM",
  "Chapecoense: tem": "https://www.youtube.com/watch?v=u4QI08mODjI",
  "Coritiba: tem": "https://www.youtube.com/watch?v=jJ6qRtS7D2s",
  "Goiás: tem 3 unidades de shorts":
      "https://www.youtube.com/watch?v=tDTvWC99Wds",
  "Guarani: tem": "https://www.youtube.com/watch?v=EaG_C9qFN8o",
  "Novorizontino: tem 3 unidades de shorts":
      "https://www.youtube.com/watch?v=xtofmgjfVgc",
  "Paysandu: tem": "https://www.youtube.com/watch?v=7rCYq6BXRzk",
  "Ponte Preta: tem": "https://www.youtube.com/watch?v=m9LMbPyRHnQ",
  "Santos: tem": "https://www.youtube.com/watch?v=4O03ZjSqTeQ",
  "Sport: tem": "https://www.youtube.com/watch?v=ChkwpaQBSqQ",
  "Vila Nova: tem 1 unidade de shorts":
      "https://www.youtube.com/watch?v=6WTQTwwf3vg",
};

// Botafogo-PB
// Figueirense
// Caxias (Sociedade Esportiva e Recreativa Caxias do Sul)
// Floresta Esporte Clube
// Londrina EC
// São Bernardo
// São José-RS
// Tombense
// Ypiranga

final Map<String, String> brazileiraoSerieC = {
  "ABC: tem": "https://www.youtube.com/watch?v=tl5ZoUkOQIg",
  "Aparecidense: tem ": "https://www.youtube.com/watch?v=NlGi0NftN40",
  "Athletic Club-MG: tem": "https://www.youtube.com/watch?v=X4M7iICTCjg",
  "Confiança (Associação Desportiva Confiança): tem":
      "https://www.youtube.com/watch?v=FpsNQtFRAP4",
  "CSA: tem": "https://www.youtube.com/watch?v=yzKeecaYPuo",
  "Ferroviária-SP: tem": "https://www.youtube.com/watch?v=fBjIqShCCrI",
  "Ferroviário-CE (erroviário Atlético Clube): tem":
      "https://www.youtube.com/watch?v=A4rHLBuQ5mI",
  "Náutico: tem": "https://www.youtube.com/watch?v=A84BBHcFV2E",
  "Remo: tem": "https://www.youtube.com/watch?v=J9DVZJblmps",
  "Sampaio Corrêa: tem": "https://www.youtube.com/watch?v=T2B_bXb9xUo",
  "Volta Redonda: tem": "https://www.youtube.com/watch?v=u-hT10wP4Xo",
};

//The name of the channel and the an video from the youtube channel
Map<String, String> laLigaTeams = {
  "real madrid": "https://www.youtube.com/watch?v=fXdNZcGuXL0&t=1s",
  "girona": "https://www.youtube.com/watch?v=fVyjt2jetA8&t=4s",
  "barcelona": "https://www.youtube.com/watch?v=BIh437lBTto&t=36s",
  "atlético de madrid": "https://www.youtube.com/watch?v=AZkyyyeF0H4",
  "ath bibao (athletic club)":
      "https://www.youtube.com/watch?v=uC-etTJc_Fo&t=100s",
  "betis (real betis balompié)":
      "https://www.youtube.com/watch?v=qrdlT4cpn14&t=21s",
  "real sociedad": "https://www.youtube.com/watch?v=K_XwKDcrvz0",
  "las palmas (Unión Deportiva Las Palmas)":
      "https://www.youtube.com/watch?v=XQ4vEGTf-WM",
  "valencia": "https://www.youtube.com/watch?v=v23yWI4ulTQ",
  "getafe": "https://www.youtube.com/watch?v=W6j2NZ2E2JQ",
  "osasuna (Club Atlético Osasuna)":
      "https://www.youtube.com/watch?v=WaadFNsYQJg",
  "alavés (Deportivo Alavés)": "https://www.youtube.com/watch?v=QScBSgj8Vlw",
  "villarreal": "https://www.youtube.com/watch?v=Kxb88exm5f0",
  "rayo vallecano de madrid": "https://www.youtube.com/watch?v=Gj8oqLTPgrQ",
  "sevilla": "https://www.youtube.com/watch?v=OSD0QxnsgQw",
  "mallorca": "https://www.youtube.com/watch?v=uGJCGODUNcY",
  "celta de vigo (RC celta)": "https://www.youtube.com/watch?v=yVJ1RiNiTGY",
  "cádiz": "https://www.youtube.com/watch?v=NCKFxOadmcE",
  "granada": "https://www.youtube.com/watch?v=M8zqpbaS2iI",
  "almería": "https://www.youtube.com/watch?v=wQ5I4avXL84",
};
