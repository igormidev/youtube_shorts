import 'package:flutter/material.dart';

class YoutubeShortsDefaultErrorWidget extends StatelessWidget {
  const YoutubeShortsDefaultErrorWidget({super.key});

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

class YoutubeShortsDefaultLoadingWidget extends StatelessWidget {
  const YoutubeShortsDefaultLoadingWidget({super.key});

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
