import 'package:flutter/material.dart';
import 'package:youtube_shorts/src/ui/elements/default_widgets.dart';
import 'package:youtube_shorts/youtube_shorts.dart';

class VideoDataLoaderElement extends StatefulWidget {
  /// The controller of the short's.
  final ShortsController controller;

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

  final Widget child;

  const VideoDataLoaderElement({
    super.key,
    required this.controller,
    required this.errorWidget,
    required this.loadingWidget,
    required this.child,
  });

  @override
  State<VideoDataLoaderElement> createState() => _VideoDataLoaderElementState();
}

class _VideoDataLoaderElementState extends State<VideoDataLoaderElement> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, shortsState, child) {
        if (shortsState.isDataState) {
          return child!;
        } else if (shortsState.isErrorState) {
          shortsState as ShortsStateError;
          return widget.errorWidget?.call(
                shortsState.error,
                shortsState.stackTrace,
              ) ??
              const YoutubeShortsDefaultErrorWidget();
        } else {
          return widget.loadingWidget ??
              const YoutubeShortsDefaultLoadingWidget();
        }
      },
      child: widget.child,
    );
  }
}
