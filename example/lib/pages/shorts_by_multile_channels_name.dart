import 'package:flutter/material.dart';
import 'package:youtube_shorts/youtube_shorts.dart';

class ShortsByMultileChannelsName extends StatefulWidget {
  const ShortsByMultileChannelsName({super.key});

  @override
  State<ShortsByMultileChannelsName> createState() =>
      _ShortsByMultileChannelsNameState();
}

class _ShortsByMultileChannelsNameState
    extends State<ShortsByMultileChannelsName> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  final TextEditingController _textEditingController = TextEditingController();

  List<String> links = [
    'fcbarcelona',
    'realmadridcf',
    'atleticodemadrid',
  ];

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
          children: [
            const SizedBox(height: 8),
            Text(
              'Type the channel names you want\nto play in stories',
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

                    return null;
                  },
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Type the youtube channel name',
                    // labelText: 'Type the youtube channel name or id',
                    suffixIcon: IconButton(
                      onPressed: () {
                        final isValid =
                            _formkey.currentState?.validate() == true;
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
            ElevatedButton(
              onPressed: () {
                if (links.isEmpty) return;

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return ShortsByMultipleChannelNameDisplay(
                        channelsName: links,
                      );
                    },
                  ),
                );
              },
              child: const Text('Start shorts view'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class ShortsByMultipleChannelNameDisplay extends StatefulWidget {
  final List<String> channelsName;
  const ShortsByMultipleChannelNameDisplay({
    super.key,
    required this.channelsName,
  });

  @override
  State<ShortsByMultipleChannelNameDisplay> createState() =>
      _ShortsByMultipleChannelNameDisplayState();
}

class _ShortsByMultipleChannelNameDisplayState
    extends State<ShortsByMultipleChannelNameDisplay> {
  late final ShortsController controller;

  @override
  void initState() {
    super.initState();
    controller = ShortsController(
      youtubeVideoSourceController:
          VideosSourceController.fromMultiYoutubeChannels(
        channelsName: widget.channelsName,
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
