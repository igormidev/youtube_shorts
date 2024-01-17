import 'package:flutter/material.dart';
import 'package:enchanted_collection/enchanted_collection.dart';
import 'package:media_kit_video/media_kit_video.dart' as media_kit show Video;
import 'package:youtube_shorts/src/data/type_defs.dart';

class YoutubeShortsVideoPlayer extends StatefulWidget {
  final bool willHaveDefaultShortsControllers;
  final int index;
  final PageController pageController;
  final VideoData data;
  final VideoDataBuilder? videoBuilder;
  final VideoInfoBuilder? overlayWidgetBuilder;
  final bool forceNotMutedAudio;
  const YoutubeShortsVideoPlayer({
    super.key,
    required this.willHaveDefaultShortsControllers,
    required this.index,
    required this.pageController,
    required this.data,
    this.videoBuilder,
    this.overlayWidgetBuilder,
    required this.forceNotMutedAudio,
  });

  @override
  State<YoutubeShortsVideoPlayer> createState() =>
      _YoutubeShortsVideoPlayerState();
}

class _YoutubeShortsVideoPlayerState extends State<YoutubeShortsVideoPlayer>
    with AutomaticKeepAliveClientMixin<YoutubeShortsVideoPlayer> {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    final isNotAlreadyMaxVolume =
        widget.data.videoController.player.state.audioBitrate != 100;
    if (widget.forceNotMutedAudio && isNotAlreadyMaxVolume) {
      widget.data.videoController.player.setVolume(100);
    }
    super.initState();
  }

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
