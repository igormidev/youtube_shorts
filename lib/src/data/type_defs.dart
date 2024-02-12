import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart' show VideoController;
import 'package:youtube_shorts/src/data/shorts_controller_settings.dart';
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

/// Update the [ShortsControllerSettings] function
///
/// Receiving the current [currentController] and return the new settings.
typedef UpdateSettingsFunction = ShortsControllerSettings Function(
    ShortsControllerSettings currentController);

typedef OnNotifyCallback = FutureOr<void> Function(
  VideoData prevVideo,
  int prevIndex,
  int currentIndex,
);

typedef VideoDataBuilder = Widget Function(
  int index,
  PageController pageController,
  VideoController videoController,
  Video videoData,
  MuxedStreamInfo hostedVideoInfo,
  Widget child,
);

typedef VideoInfoBuilder = Widget Function(
  int index,
  PageController pageController,
  VideoController videoController,
  Video videoData,
  MuxedStreamInfo hostedVideoInfo,
);
