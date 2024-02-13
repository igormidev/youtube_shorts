import 'package:example/pages/shorts_by_channel_name.dart';
import 'package:example/pages/shorts_by_multile_channels_name.dart';
import 'package:example/pages/shorts_by_multiple_channels_ids.dart';
import 'package:example/pages/shorts_by_video_url.dart';
import 'package:flutter/material.dart';
import 'package:youtube_shorts/youtube_shorts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(const MyApp());
}

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
            Image.asset(
              'art/logo.PNG',
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const ShortsByMultileChannelsName();
                    },
                  ),
                );
              },
              child: const Text('By youtube multiple channel name'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const ShortsByMultileChannelsIds();
                    },
                  ),
                );
              },
              child: const Text('By youtube multiple channel ids'),
            ),
          ],
        ),
      ),
    );
  }
}
