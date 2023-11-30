import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
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
      title: 'Flutter Demo',
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
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Choose your youtube video source'),
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

class ShortsByVideoUrl extends StatefulWidget {
  const ShortsByVideoUrl({super.key});

  @override
  State<ShortsByVideoUrl> createState() => _ShortsByVideoUrlState();
}

class _ShortsByVideoUrlState extends State<ShortsByVideoUrl> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
  }

  List<String> links = [
    'https://www.youtube.com/shorts/PiWJWfzVwjU',
    'https://www.youtube.com/shorts/AeZ3dmC676c',
    'https://www.youtube.com/shorts/L1lg_lxUxfw',
    'https://www.youtube.com/shorts/OWPsdhLHK7c',
    'https://www.youtube.com/shorts/GoQhFyoZxRM',
    'https://www.youtube.com/shorts/pzpp3PkVI-s',
    'https://www.youtube.com/shorts/Z9yyWrbonRs',
    'https://www.youtube.com/shorts/LPm0LUBxnRQ',
    'https://www.youtube.com/shorts/sG0lMuv88yg',
    'https://www.youtube.com/shorts/HEwvgMxsLcI',
    'https://www.youtube.com/shorts/8I1Gq1xW8L4',
    'https://www.youtube.com/shorts/tL7D5bivyH4',
    'https://www.youtube.com/shorts/7TVj_KqJ0wY',
    'https://www.youtube.com/shorts/GYqF_LXFlyg',
    'https://www.youtube.com/shorts/Il5rxWOw4GI',
    'https://www.youtube.com/shorts/a3XT1p7Uczk',
    'https://www.youtube.com/shorts/1S-c0yLCsNo',
    'https://www.youtube.com/shorts/S23UPbRai-w',
    'https://www.youtube.com/shorts/ZCDU4O1jnTo',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('By url list'),
        actions: [
          IconButton(
            onPressed: () {
              if (links.isEmpty) {
                links.clear();
                setState(() {});
              }
            },
            icon: const Icon(Icons.delete),
            tooltip: 'Delete all fields',
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            'Type the urls you want\nto play in stories',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: links.length,
              itemBuilder: (context, index) {
                final String link = links[index];
                return ListTile(
                  title: Text(link),
                  trailing: IconButton(
                    onPressed: () {
                      links.remove(link);
                      setState(() {});
                    },
                    icon: const Icon(Icons.delete),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formkey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: _textEditingController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  final linkUrl = RegExp(
                    r'https://www.youtube.com/shorts/[a-zA-Z0-9]+',
                  );

                  if (linkUrl.hasMatch(value) == false) {
                    return 'Is not a youtube short url';
                  }

                  return null;
                },
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Type the youtube SHORTS link',
                  // labelText: 'Type the youtube channel name or id',
                  suffixIcon: IconButton(
                    onPressed: () {
                      final isValid = _formkey.currentState?.validate() == true;
                      if (isValid) {
                        links.add(_textEditingController.text);
                        setState(() {});
                      }
                    },
                    icon: const Icon(Icons.add),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_textEditingController.text.isNotEmpty) {
                final isValid = _formkey.currentState?.validate() == true;
                if (isValid == false) return;
              }
              final ids = links.map(
                (v) => v.replaceAll('https://www.youtube.com/shorts/', ''),
              );

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return ShortsByVideoUrlDisplay(ids: ids.toList());
                  },
                ),
              );
            },
            child: const Text('Start shorts view'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class ShortsByVideoUrlDisplay extends StatefulWidget {
  final List<String> ids;
  const ShortsByVideoUrlDisplay({
    super.key,
    required this.ids,
  });

  @override
  State<ShortsByVideoUrlDisplay> createState() =>
      _ShortsByVideoStateUrlDisplay();
}

class _ShortsByVideoStateUrlDisplay extends State<ShortsByVideoUrlDisplay> {
  late final ShortsController controller;

  @override
  void initState() {
    super.initState();
    controller = ShortsController(
      youtubeVideoInfoService: VideosSourceController.fromUrlList(
        videoIds: widget.ids,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShortsPage(
      controller: controller,
      overlayWidgetBuilder: (
        int index,
        VideoController videoController,
        videoData,
        String hostedVideoUrl,
      ) {
        return Center(
          child: CircleAvatar(
            child: Text('$index'),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class ShortsByChannelName extends StatefulWidget {
  const ShortsByChannelName({super.key});

  @override
  State<ShortsByChannelName> createState() => _ShortsByChannelNameState();
}

class _ShortsByChannelNameState extends State<ShortsByChannelName> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController _textEditingController = TextEditingController(
    text: 'fcbarcelona',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('By channel name'),
        actions: [
          IconButton(
            onPressed: () {
              _textEditingController.clear();
            },
            icon: const Icon(Icons.delete),
            tooltip: 'Clean field',
          ),
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Text(
              'Type the urls you want\nto play in stories',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formkey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: _textEditingController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }

                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Type the youtube SHORTS link',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_textEditingController.text.isNotEmpty) {
                  final isValid = _formkey.currentState?.validate() == true;
                  if (isValid == false) return;
                }

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return ShortsByChannelNameDisplay(
                        channelName: _textEditingController.text,
                      );
                    },
                  ),
                );
              },
              child: const Text('Start shorts view'),
            ),
          ],
        ),
      ),
    );
  }
}

class ShortsByChannelNameDisplay extends StatefulWidget {
  final String channelName;
  const ShortsByChannelNameDisplay({super.key, required this.channelName});

  @override
  State<ShortsByChannelNameDisplay> createState() =>
      _ShortsByChannelNameDisplayState();
}

class _ShortsByChannelNameDisplayState
    extends State<ShortsByChannelNameDisplay> {
  late final ShortsController controller;

  @override
  void initState() {
    super.initState();
    controller = ShortsController(
      youtubeVideoInfoService: VideosSourceController.fromYoutubeChannel(
        channelName: widget.channelName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShortsPage(
      controller: controller,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
