import 'package:flutter/material.dart';
import 'package:youtube_shorts/youtube_shorts.dart';

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
      youtubeVideoSourceController: VideosSourceController.fromYoutubeChannel(
        channelName: widget.channelName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return YoutubeShortsPage(
      controller: controller,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
