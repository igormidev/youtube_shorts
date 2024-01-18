import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart' as media_kit show Video;
import 'package:youtube_shorts/src/data/not_focused_ui_type.dart';
import 'package:youtube_shorts/src/ui/elements/condition_to_update_value_listenable.dart';
import 'package:youtube_shorts/src/ui/elements/default_widgets.dart';
import 'package:youtube_shorts/src/ui/elements/video_completer_future_builder.dart';
import 'package:youtube_shorts/src/ui/elements/video_data_loader_element.dart';
import 'package:youtube_shorts/youtube_shorts.dart';

class YoutubeShortsHorizontalStoriesSection extends StatefulWidget {
  /// The type of the ui that will be displayed when the video is not focused
  /// and the user is not interacting with the video.
  ///
  /// You can show a preview of the video, or the video tumbnail.
  final NotFocusedUiType notFocusedUiType;

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
    this.notFocusedUiType = const PlayerPaused(),
  });

  @override
  State<YoutubeShortsHorizontalStoriesSection> createState() =>
      _YoutubeShortsHorizontalStoriesSectionState();
}

class _YoutubeShortsHorizontalStoriesSectionState
    extends State<YoutubeShortsHorizontalStoriesSection> {
  late PageController pageController;
  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);

  void _configurePageController(double deviceWidth) {
    /// 295 = 411.429
    ///  x  = deviceWidth
    final otimizedSize = 295 * deviceWidth / 411.429;

    // 295 is default height value. 0.40 is default aspect ratio of 307
    // 295 - 0.40
    // widget.shortsPreviewHeight - targetViewportFraction
    final double targetViewportFraction =
        widget.shortsPreviewHeight * 0.40 / otimizedSize;

    pageController = PageController(
      viewportFraction: targetViewportFraction,
    );

    /// Override current settings to not start with volume.
    widget.controller.updateControllerSettings(
      updateFunction: (currentController) {
        return currentController.copyWith(
          startVideoWithVolume: 0,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _configurePageController(constraints.maxWidth);

      return SizedBox(
        height: widget.shortsPreviewHeight,
        child: VideoDataLoaderElement(
          controller: widget.controller,
          errorWidget: widget.errorWidget,
          loadingWidget: widget.loadingWidget,
          child: Builder(builder: (context) {
            return PageView.builder(
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
                  emptyWidget: widget.loadingWidget ??
                      const YoutubeShortsDefaultLoadingWidget(),
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
                                        _goToShortsPage(index);
                                      } else {
                                        _animateToPageWithIndex(index);
                                      }
                                    },
                                    child: IgnorePointer(
                                      ignoring: true,
                                      child: switch (widget.notFocusedUiType) {
                                        PlayerPaused() => media_kit.Video(
                                            fill: Colors.transparent,
                                            controller:
                                                videoData.videoController,
                                          ),
                                        WithTumbnailType tumbnail => isSelected
                                            ? media_kit.Video(
                                                fill: Colors.transparent,
                                                controller:
                                                    videoData.videoController,
                                              )
                                            : Builder(
                                                builder: (context) {
                                                  final dataTumbnail = videoData
                                                      .videoData
                                                      .videoData
                                                      .thumbnails;
                                                  return Image.network(
                                                    switch (tumbnail.quality) {
                                                      TumbnailQuality
                                                            .lowResUrl =>
                                                        dataTumbnail.lowResUrl,
                                                      TumbnailQuality
                                                            .mediumResUrl =>
                                                        dataTumbnail
                                                            .mediumResUrl,
                                                      TumbnailQuality
                                                            .standardResUrl =>
                                                        dataTumbnail
                                                            .standardResUrl,
                                                      TumbnailQuality
                                                            .highResUrl =>
                                                        dataTumbnail.highResUrl,
                                                      TumbnailQuality
                                                            .maxResUrl =>
                                                        dataTumbnail.maxResUrl,
                                                    },
                                                    fit: BoxFit.cover,
                                                  );
                                                },
                                              ),
                                      },
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
            );
          }),
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

  void _goToShortsPage(int index) async {
    widget.controller.setVideoVolumeWithIndex(100, index);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return YoutubeShortsPage(
            controller: widget.controller,
            errorWidget: widget.errorWidget,
            loadingWidget: widget.loadingWidget,
            overlayWidgetBuilder: widget.overlayWidgetBuilder,
            videoBuilder: widget.videoBuilder,
            willHaveDefaultShortsControllers:
                widget.willHaveDefaultShortsControllers,
            initialVolume: 100,
            onCurrentVideoPlayCallback: (prevVideo, prevIndex, currentIndex) {
              selectedIndex.value = currentIndex;
              pageController.jumpToPage(currentIndex);
            },
          );
        },
      ),
    );

    widget.controller.muteCurrentVideo();
  }
}
