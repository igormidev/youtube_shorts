import 'package:flutter/material.dart';
import 'package:synchronized/synchronized.dart';
import 'package:youtube_shorts/src/logic/shorts_controller.dart';

class ConditionToUpdateValueListenable<T> extends StatefulWidget {
  /// The controller of the short's.
  final ShortsController controller;
  final ValueNotifier<int> currentIndexNotifier;
  final int index;
  final Widget Function(BuildContext context) builder;

  const ConditionToUpdateValueListenable({
    super.key,
    required this.controller,
    required this.currentIndexNotifier,
    required this.index,
    required this.builder,
  });

  @override
  State<ConditionToUpdateValueListenable> createState() =>
      _ConditionToUpdateValueListenableState();
}

class _ConditionToUpdateValueListenableState
    extends State<ConditionToUpdateValueListenable> {
  final Lock lock = Lock();
  bool willShow = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateWillShow);
    widget.currentIndexNotifier.addListener(_updateWillShow);
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.addListener(_updateWillShow);
    widget.currentIndexNotifier.addListener(_updateWillShow);
  }

  bool hadBeenUpdated = false;
  void _updateWillShow() {
    lock.synchronized(() {
      if (hadBeenUpdated == true) return;

      final existsVideo =
          widget.controller.getVideoInIndex(widget.index) != null;
      if (existsVideo) {
        hadBeenUpdated = true;

        setState(() {
          willShow = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (willShow) {
      return widget.builder(context);
    } else {
      return SizedBox.fromSize();
    }
  }
}
