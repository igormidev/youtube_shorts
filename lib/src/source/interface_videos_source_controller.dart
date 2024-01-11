import 'dart:async';
import 'package:easy_isolate_mixin/easy_isolate_mixin.dart';
import 'package:enchanted_collection/enchanted_collection.dart';
import 'package:youtube_shorts/src/data/type_defs.dart';
import 'package:youtube_shorts/youtube_explode_fork/youtube_explode_dart.dart';

part 'impl_by_url_list.dart';
part 'impl_from_channel_name.dart';

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
