import 'package:flutter/material.dart';
import 'package:youtube_shorts/youtube_shorts.dart';

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
    'https://www.youtube.com/shorts/PiWJWfzVwjU', // 0
    'https://www.youtube.com/shorts/AeZ3dmC676c', // 1
    'https://www.youtube.com/shorts/L1lg_lxUxfw', // 2
    'https://www.youtube.com/shorts/OWPsdhLHK7c', // 3
    'https://www.youtube.com/shorts/GoQhFyoZxRM', // 4
    'https://www.youtube.com/shorts/pzpp3PkVI-s', // 5
    'https://www.youtube.com/shorts/Z9yyWrbonRs', // 6
    'https://www.youtube.com/shorts/LPm0LUBxnRQ', // 7
    'https://www.youtube.com/shorts/sG0lMuv88yg', // 8
    'https://www.youtube.com/shorts/HEwvgMxsLcI', // 9
    'https://www.youtube.com/shorts/8I1Gq1xW8L4', // 10
    'https://www.youtube.com/shorts/tL7D5bivyH4', // 11
    'https://www.youtube.com/shorts/7TVj_KqJ0wY', // 12
    'https://www.youtube.com/shorts/GYqF_LXFlyg', // 13
    'https://www.youtube.com/shorts/Il5rxWOw4GI', // 14
    'https://www.youtube.com/shorts/a3XT1p7Uczk', // 15
    'https://www.youtube.com/shorts/1S-c0yLCsNo', // 16
    'https://www.youtube.com/shorts/S23UPbRai-w', // 17
    'https://www.youtube.com/shorts/ZCDU4O1jnTo', // 18
  ];

  bool seeHorizontalVideos = true;

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
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            title: const Text('See horizontal videos widget'),
            value: seeHorizontalVideos,
            onChanged: (_) {
              setState(() {
                seeHorizontalVideos = !seeHorizontalVideos;
              });
            },
          ),
          const SizedBox(height: 8),
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
                    return ShortsByVideoUrlDisplay(
                      ids: ids.toList(),
                      seeHorizontalVideos: seeHorizontalVideos,
                    );
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
  final bool seeHorizontalVideos;
  const ShortsByVideoUrlDisplay({
    super.key,
    required this.ids,
    required this.seeHorizontalVideos,
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
      youtubeVideoSourceController: VideosSourceController.fromUrlList(
        videoIds: widget.ids,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.seeHorizontalVideos) {
      return Scaffold(
        body: Center(
          child: YoutubeShortsHorizontalStoriesSection(
            shortsPreviewHeight: 295,
            controller: controller,
          ),
        ),
      );
    } else {
      return YoutubeShortsPage(
        controller: controller,
        overlayWidgetBuilder: (
          int index,
          PageController pageController,
          VideoController videoController,
          Video videoData,
          MuxedStreamInfo hostedVideoUrl,
        ) {
          return Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 100, left: 16),
              child: CircleAvatar(
                child: Text('$index'),
              ),
            ),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
