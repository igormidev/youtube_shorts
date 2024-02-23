import 'package:flutter/material.dart';
import 'package:youtube_shorts/youtube_shorts.dart';
import 'package:youtube_shorts/src/ui/elements/video_data_loader_element.dart';
import 'package:youtube_shorts/src/ui/elements/youtube_shorts_video_player.dart';
import 'package:youtube_shorts/src/ui/elements/video_completer_future_builder.dart';

class YoutubeShortsPage extends StatefulWidget {
  /// The controller of the short's.
  final ShortsController controller;

  /// The builder that will be called to build the widget of each video.
  ///
  /// If null, will use default [media_kit.Video]. That is:
  /// ```dart
  /// Video(
  ///   controller: videoController,
  /// )
  /// ```
  ///
  /// The most amount of the time you will need only the default [media_kit.Video].
  /// But if you need to customize the video widget in some way, you can use this builder.
  /// Notice: If you want to display a widget above the video, use [overlayWidgetBuilder].
  final VideoDataBuilder? videoBuilder;

  /// This is the builder that will create the widget that will be
  /// displayed when its in an ad index.
  final AdsDataBuilder? adsWidgetBuilder;

  /// This is the widget that will be displayed over the video.
  ///
  /// Notice, the Video widget [videoBuilder] or default [media_kit.Video],
  /// is `inside a Stack` widget. And above that widget is the [overlayWidgetBuilder].
  /// So everthing you put in this builder will be displayed above the video.
  ///
  /// ℹ️ Tip: If you wan't to use the full space of the [Stack] to position your widget,
  /// use SizedBox.expand() as the first widget you will return.
  final VideoInfoBuilder? overlayWidgetBuilder;

  /// The widget that will be displayed while the [ShortsController]
  /// initial dependencies are loading.
  ///
  /// If null, the default widget is:
  /// ```dart
  /// const Center(
  ///   child: SizedBox(
  ///     width: 50,
  ///     height: 50,
  ///     child: CircularProgressIndicator.adaptive(),
  ///   ),
  /// );
  /// ```
  final Widget? loadingWidget;

  /// Will be displayed when an error occurs.
  ///
  /// If null, the default widget is:
  /// ```dart
  /// const Center(
  ///   child: SizedBox(
  ///     width: 50,
  ///     height: 50,
  ///     child: Icon(Icons.error),
  ///   ),
  /// );
  /// ```
  final Widget Function(Object error, StackTrace? stackTrace)? errorWidget;

  /// If true, will show default video buttons
  /// when user tap's on the screen.
  /// Such as:
  /// - pause/play button
  /// - bar with video duration and current time
  /// - fullscreen button
  final bool willHaveDefaultShortsControllers;

  /// When the video switches from one to other use this function to execute any logic
  /// The logic will be executed after the previous video is paused
  final OnNotifyCallback? onPrevVideoPauseCallback;

  /// When the video switches from one to other use this function to execute any logic
  /// The logic will be executed after the current video is played
  final OnNotifyCallback? onCurrentVideoPlayCallback;

  final double? initialVolume;

  /// The widget that will display the video.
  const YoutubeShortsPage({
    super.key,
    required this.controller,
    this.videoBuilder,
    this.adsWidgetBuilder,
    this.overlayWidgetBuilder,
    this.loadingWidget,
    this.errorWidget,
    this.onPrevVideoPauseCallback,
    this.onCurrentVideoPlayCallback,
    this.willHaveDefaultShortsControllers = true,
    this.initialVolume,
  });

  @override
  State<YoutubeShortsPage> createState() => _YoutubeShortsPageState();
}

class _YoutubeShortsPageState extends State<YoutubeShortsPage> {
  late final PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(
      initialPage: widget.controller.currentIndex, // The initial index
    );
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VideoDataLoaderElement(
      controller: widget.controller,
      errorWidget: widget.errorWidget,
      loadingWidget: widget.loadingWidget,
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: pageController,
        onPageChanged: (index) {
          widget.controller.notifyCurrentIndex(
            index,
            onCurrentVideoPlay: widget.onCurrentVideoPlayCallback,
            onPrevVideoPause: widget.onPrevVideoPauseCallback,
          );
        },
        itemBuilder: (context, index) {
          final bool isSelectedIndex = widget.controller.currentIndex == index;

          final int maxLenght = widget.controller.maxLenght;
          final bool isIndexBellowMaxLenght = index >= maxLenght;
          if (!isSelectedIndex && isIndexBellowMaxLenght) return null;
          final data = widget.controller.getVideoInIndex(index);
          if (data is ShortsVideoData) {
            return VideoCompleterFutureBuilder(
              index: index,
              shortsVideoData: data,
              errorWidget: widget.errorWidget,
              loadingWidget: widget.loadingWidget,
              builder: (context, videoData) {
                return YoutubeShortsVideoPlayer(
                  key: ValueKey(index),
                  willHaveDefaultShortsControllers:
                      widget.willHaveDefaultShortsControllers,
                  index: index,
                  pageController: pageController,
                  data: videoData,
                  videoBuilder: widget.videoBuilder,
                  overlayWidgetBuilder: widget.overlayWidgetBuilder,
                  initialVolume: widget.initialVolume,
                );
              },
            );
          } else {
            return widget.adsWidgetBuilder?.call(
                  index,
                  pageController,
                ) ??
                SizedBox.fromSize();
          }
        },
      ),
    );
  }
}
