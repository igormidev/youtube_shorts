import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart' as media_kit show Video;
import 'package:youtube_shorts/src/ui/elements/condition_to_update_value_listenable.dart';
import 'package:youtube_shorts/src/ui/elements/video_completer_future_builder.dart';
import 'package:youtube_shorts/src/ui/elements/video_data_loader_element.dart';
import 'package:youtube_shorts/youtube_shorts.dart';

class YoutubeShortsHorizontalStoriesSection extends StatefulWidget {
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
  final Widget Function(Object error, StackTrace? stackTrace)? errorWidget;

  /// If true, will show default video buttons
  /// when user tap's on the screen.
  /// Such as:
  /// - pause/play button
  /// - bar with video duration and current time
  /// - fullscreen button
  final bool willHaveDefaultShortsControllers;

  /// The height of the preview of the shorts.
  final double shortsPreviewHeight;

  const YoutubeShortsHorizontalStoriesSection({
    super.key,
    required this.controller,
    this.loadingWidget,
    this.errorWidget,
    this.videoBuilder,
    this.overlayWidgetBuilder,
    this.willHaveDefaultShortsControllers = true,
    this.shortsPreviewHeight = 295,
  });

  @override
  State<YoutubeShortsHorizontalStoriesSection> createState() =>
      _YoutubeShortsHorizontalStoriesSectionState();
}

class _YoutubeShortsHorizontalStoriesSectionState
    extends State<YoutubeShortsHorizontalStoriesSection> {
  late PageController pageController;
  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    widget.controller.updateControllerSettings(
      updateFunction: (currentController) {
        return currentController.copyWith(
          startVideoMuted: true,
        );
      },
    );

    super.initState();
  }

  void _configurePageController(double deviceWidth) {
    /// 295 = 411.429
    ///  x  = deviceWidth
    final otimizedSize = 411.429 * 295 / deviceWidth;

    // 295 is default height value. 0.40 is default aspect ratio of 307
    // 295 - 0.40
    // widget.shortsPreviewHeight - targetViewportFraction
    final double targetViewportFraction =
        widget.shortsPreviewHeight * 0.40 / otimizedSize;

    pageController = PageController(
      viewportFraction: targetViewportFraction,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _configurePageController(constraints.maxWidth);
      return VideoDataLoaderElement(
        controller: widget.controller,
        errorWidget: widget.errorWidget,
        loadingWidget: widget.loadingWidget,
        child: SizedBox(
          height: widget.shortsPreviewHeight,
          child: PageView.builder(
            controller: pageController,
            onPageChanged: (int index) {
              selectedIndex.value = index;
              widget.controller.notifyCurrentIndex(index);
            },
            padEnds: false,
            itemBuilder: (context, index) {
              return ConditionToUpdateValueListenable(
                currentIndexNotifier: selectedIndex,
                index: index,
                controller: widget.controller,
                builder: (context) {
                  final ShortsStateWithData shortsState =
                      widget.controller.value as ShortsStateWithData;

                  final isPlaceHolderPadding = index >= shortsState.maxLenght;
                  if (isPlaceHolderPadding) {
                    return const SizedBox.shrink();
                  }

                  final bool isSelectedIndex =
                      widget.controller.currentIndex == index;
                  final int maxLenght = shortsState.maxLenght;
                  final bool isIndexBellowMaxLenght = index >= maxLenght;

                  if (!isSelectedIndex && isIndexBellowMaxLenght) {
                    return SizedBox.fromSize();
                  }

                  return VideoCompleterFutureBuilder(
                    index: index,
                    controller: widget.controller,
                    errorWidget: widget.errorWidget,
                    loadingWidget: widget.loadingWidget,
                    builder: (context, videoData) {
                      return ValueListenableBuilder(
                        valueListenable: selectedIndex,
                        builder: (context, value, child) {
                          final bool isSelected = index == value;

                          return Transform.scale(
                            scale: isSelected ? 1 : 0.95,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 8,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  onTap: () async {
                                    if (isSelected) {
                                      _goToShortsPage();
                                    } else {
                                      _animateToPageWithIndex(index);
                                    }
                                  },
                                  child: IgnorePointer(
                                    ignoring: true,
                                    child: media_kit.Video(
                                      fill: Colors.transparent,
                                      controller: videoData.videoController,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    selectedIndex.dispose();
    pageController.dispose();
    super.dispose();
  }

  void _animateToPageWithIndex(int index) {
    selectedIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.ease,
    );
  }

  void _goToShortsPage() async {
    widget.controller.updateControllerSettings(
      updateFunction: (currentController) {
        return currentController.copyWith(
          startVideoMuted: false,
        );
      },
    );

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return YoutubeShortsPage(
            controller: widget.controller,
            forceNotMutedAudio: true,
            errorWidget: widget.errorWidget,
            loadingWidget: widget.loadingWidget,
            overlayWidgetBuilder: widget.overlayWidgetBuilder,
            videoBuilder: widget.videoBuilder,
            willHaveDefaultShortsControllers:
                widget.willHaveDefaultShortsControllers,
          );
        },
      ),
    );

    widget.controller.muteCurrentVideo();

    widget.controller.updateControllerSettings(
      updateFunction: (currentController) {
        return currentController.copyWith(
          startVideoMuted: true,
        );
      },
    );
  }
}
