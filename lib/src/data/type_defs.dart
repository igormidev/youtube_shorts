import 'dart:async';

import 'package:media_kit_video/media_kit_video.dart' show VideoController;
import 'package:youtube_shorts/youtube_explode_fork/src/videos/streams/muxed_stream_info.dart';
import 'package:youtube_shorts/youtube_explode_fork/src/videos/video.dart';

/// The video data (url, title, description etc...) and the hosted video info.
typedef VideoStats = ({Video videoData, MuxedStreamInfo hostedVideoInfo});

/// The data to controll video player and the video stats.
typedef VideoData = ({VideoController videoController, VideoStats videoData});

/// The completer typedef of [VideoData].
typedef VideoDataCompleter = Completer<VideoData>;

/// The dispose function of [VideoDataCompleter].
typedef DisposeFunction = FutureOr<void> Function();
