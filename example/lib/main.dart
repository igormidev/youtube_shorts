// ignore_for_file: depend_on_referenced_packages

import 'package:example/pages/shorts_by_channel_name.dart';
import 'package:example/pages/shorts_by_video_url.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  final preList = testIndexes.sublist(0, 3);
  final postList = testIndexes.sublist(3);
  runApp(const MyApp());
}

const int currentIndex = 5;
// final List<int> testIndexes = [2, 3, 4, 5, 6, 7, 8];
// final List<int> testIndexes = [1, 2, 3, 4, 5, 6, 7];
final List<int> testIndexes = [6, 7, 8, 9, 10, 11, 12];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Youtube Shorts Display Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return ColoredBox(
          color: Colors.deepPurple[200]!,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: SizedBox.expand(child: child),
          ),
        );
      },
      home: const SelectionPage(),
    );
  }
}

class SelectionPage extends StatelessWidget {
  const SelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Youtube Shorts Display Demo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://freelogopng.com/images/all_img/1684952459youtube-shorts-logo-png.png',
              width: 300,
            ),
            const SizedBox(height: 16),
            Text(
              'Choose your youtube video source',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const ShortsByVideoUrl();
                    },
                  ),
                );
              },
              child: const Text('By list of video urls'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const ShortsByChannelName();
                    },
                  ),
                );
              },
              child: const Text('By youtube channel name'),
            ),
          ],
        ),
      ),
    );
  }
}
