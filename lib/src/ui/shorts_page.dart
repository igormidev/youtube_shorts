import 'package:enchanted_collection/enchanted_collection.dart';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart' hide Video;
import 'package:media_kit_video/media_kit_video.dart' as media_kit show Video;
import 'package:youtube_shorts/src/logic/shorts_controller.dart';
import 'package:youtube_shorts/src/logic/shorts_state.dart';
import 'package:youtube_shorts/youtube_explode_fork/youtube_explode_dart.dart';

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

class ShortsPage extends StatefulWidget {
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
  final Widget? errrorWidget;

  /// If true, will show default video buttons
  /// when user tap's on the screen.
  /// Such as:
  /// - pause/play button
  /// - bar with video duration and current time
  /// - fullscreen button
  final bool willHaveDefaultShortsControllers;

  /// The widget that will display the video.
  const ShortsPage({
    super.key,
    required this.controller,
    this.videoBuilder,
    this.overlayWidgetBuilder,
    this.loadingWidget,
    this.errrorWidget,
    this.willHaveDefaultShortsControllers = true,
  });

  @override
  State<ShortsPage> createState() => _ShortsPageState();
}

class _ShortsPageState extends State<ShortsPage> {
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
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, shortsState, child) {
        if (shortsState is ShortsStateWithData) {
          return child!;
        } else {
          return widget.loadingWidget ?? const _DefaultLoading();
        }
      },
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: pageController,
        itemBuilder: (context, index) {
          final ShortsStateWithData currentValue =
              widget.controller.value as ShortsStateWithData;

          final isSelectedIndex = widget.controller.currentIndex == index;
          final int maxLenght = currentValue.maxLenght;
          final isIndexBellowMaxLenght = index >= maxLenght;
          if (!isSelectedIndex && isIndexBellowMaxLenght) return null;

          final videoCompletter = widget.controller.getVideoInIndex(index);

          return FutureBuilder(
            future: videoCompletter?.future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final data = snapshot.data;
                if (snapshot.hasError || data == null) {
                  return widget.errrorWidget ?? const _DefaultError();
                }

                return _VideoPlayerDisplay(
                  key: ValueKey(index),
                  willHaveDefaultShortsControllers:
                      widget.willHaveDefaultShortsControllers,
                  index: index,
                  pageController: pageController,
                  data: data,
                  videoBuilder: widget.videoBuilder,
                  overlayWidgetBuilder: widget.overlayWidgetBuilder,
                );
              }

              return widget.loadingWidget ?? const _DefaultLoading();
            },
          );
        },
        onPageChanged: (index) {
          widget.controller.notifyCurrentIndex(index);
        },
      ),
    );
  }
}

class _VideoPlayerDisplay extends StatefulWidget {
  final bool willHaveDefaultShortsControllers;
  final int index;
  final PageController pageController;
  final VideoData data;
  final VideoDataBuilder? videoBuilder;
  final VideoInfoBuilder? overlayWidgetBuilder;
  const _VideoPlayerDisplay({
    super.key,
    required this.willHaveDefaultShortsControllers,
    required this.index,
    required this.pageController,
    required this.data,
    this.videoBuilder,
    this.overlayWidgetBuilder,
  });

  @override
  State<_VideoPlayerDisplay> createState() => _VideoPlayerDisplayState();
}

class _VideoPlayerDisplayState extends State<_VideoPlayerDisplay>
    with AutomaticKeepAliveClientMixin<_VideoPlayerDisplay> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: [
        SizedBox.expand(
          child: Builder(
            builder: (context) {
              final willIgnore = !widget.willHaveDefaultShortsControllers;

              final videoPlayer = IgnorePointer(
                ignoring: willIgnore,
                child: media_kit.Video(
                  fill: Colors.transparent,
                  controller: widget.data.videoController,
                ),
              );
              if (widget.videoBuilder != null) {
                return widget.videoBuilder!(
                  widget.index,
                  widget.pageController,
                  widget.data.videoController,
                  widget.data.videoData.videoData,
                  widget.data.videoData.hostedVideoInfo,
                  videoPlayer,
                );
              }

              return videoPlayer;
            },
          ),
        ),
        widget.overlayWidgetBuilder?.call(
          widget.index,
          widget.pageController,
          widget.data.videoController,
          widget.data.videoData.videoData,
          widget.data.videoData.hostedVideoInfo,
        ),
      ].removeNull,
    );
  }
}

class _DefaultLoading extends StatelessWidget {
  const _DefaultLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 50,
        height: 50,
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}

class _DefaultError extends StatelessWidget {
  const _DefaultError();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 50,
        height: 50,
        child: Icon(Icons.error),
      ),
    );
  }
}
