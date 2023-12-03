import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart' hide Video;
import 'package:media_kit_video/media_kit_video.dart' as mediaKit show Video;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_shorts/src/logic/shorts_controller.dart';
import 'package:youtube_shorts/src/logic/shorts_state.dart';
import 'package:youtube_shorts/src/utils/extensions.dart';

typedef VideoDataBuilder = Widget Function(
  int index,
  PageController pageController,
  VideoController videoController,
  Video videoData,
  String hostedVideoUrl,
  Widget Function() child,
);

typedef VideoInfoBuilder = Widget Function(
  int index,
  PageController pageController,
  VideoController videoController,
  Video videoData,
  String hostedVideoUrl,
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
          final ShortsStateWithData currentValue = shortsState;
          return PageView.builder(
            scrollDirection: Axis.vertical,
            controller: pageController,
            itemCount: currentValue.maxLenght,
            itemBuilder: (context, index) {
              final videoCompletter = widget.controller.getVideoInIndex(index);
              return FutureBuilder(
                future: videoCompletter?.future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    final data = snapshot.data;
                    if (snapshot.hasError || data == null) {
                      return widget.errrorWidget ?? const _DefaultError();
                    }

                    return Stack(
                      children: [
                        SizedBox.expand(
                          child: Builder(builder: (context) {
                            Widget childBuilder() {
                              final willIgnore =
                                  !widget.willHaveDefaultShortsControllers;

                              return IgnorePointer(
                                ignoring: willIgnore,
                                child: mediaKit.Video(
                                  controller: data.videoController,
                                ),
                              );
                            }

                            if (widget.videoBuilder != null) {
                              return widget.videoBuilder!(
                                index,
                                pageController,
                                data.videoController,
                                data.videoData.videoData,
                                data.videoData.hostedVideoUrl,
                                childBuilder,
                              );
                            }

                            return childBuilder();
                          }),
                        ),
                        widget.overlayWidgetBuilder?.call(
                          index,
                          pageController,
                          data.videoController,
                          data.videoData.videoData,
                          data.videoData.hostedVideoUrl,
                        ),
                      ].removeNull,
                    );
                  }

                  return widget.loadingWidget ?? const _DefaultLoading();
                },
              );
            },
            onPageChanged: (index) {
              widget.controller.notifyCurrentIndex(index);
            },
          );
        } else {
          return widget.loadingWidget ?? const _DefaultLoading();
        }
      },
    );
  }
}

class _DefaultLoading extends StatelessWidget {
  const _DefaultLoading({super.key});

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
  const _DefaultError({super.key});

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
