import 'package:easy_isolate_mixin/easy_isolate_mixin.dart';
import 'package:youtube_shorts/youtube_explode_fork/src/videos/streams/muxed_stream_info.dart';
import 'package:youtube_shorts/youtube_explode_fork/src/videos/streams/stream_manifest.dart';
import 'package:youtube_shorts/youtube_explode_fork/src/videos/video.dart';
import 'package:youtube_shorts/youtube_explode_fork/src/youtube_explode_base.dart';

mixin IsolateMixinHelpers on IsolateHelperMixin {
  Future<MuxedStreamInfo> getMuxedInfo(String videoId) async {
    return loadWithIsolate(() async {
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
    });
  }

  Future<Video> getVideo(String channelId) async {
    return loadWithIsolate(() async {
      return await YoutubeExplode().videos.get(channelId);
    });
  }
}
