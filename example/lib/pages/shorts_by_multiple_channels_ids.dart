import 'package:flutter/material.dart';
import 'package:youtube_shorts/youtube_shorts.dart';

class ShortsByMultileChannelsIds extends StatefulWidget {
  const ShortsByMultileChannelsIds({super.key});

  @override
  State<ShortsByMultileChannelsIds> createState() =>
      _ShortsByMultileChannelsIdsState();
}

class _ShortsByMultileChannelsIdsState
    extends State<ShortsByMultileChannelsIds> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  final TextEditingController _textEditingController = TextEditingController();

  List<String> ids = [
    'UC14UlmYlSNiQCBe9Eookf_A', // Barcelona
    'UCWV3obpZVGgJ3j9FVhEjF2Q', // Real Madrid
    'UCuzKFwdh7z2GHcIOX_tXgxA', // Atlético de Madrid
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('By channel ids'),
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
              'Type the channel ids of the channels you want to play in stories',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: ids.length,
                itemBuilder: (context, index) {
                  final String link = ids[index];
                  return ListTile(
                    title: Text(link),
                    trailing: IconButton(
                      onPressed: () {
                        ids.remove(link);
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
                    labelText: 'Type the youtube channel id',
                    suffixIcon: IconButton(
                      onPressed: () {
                        final isValid =
                            _formkey.currentState?.validate() == true;
                        if (isValid) {
                          ids.add(_textEditingController.text);
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
                if (ids.isEmpty) return;

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return ShortsByMultipleChannelIdsDisplay(
                        channelsIds: ids,
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

class ShortsByMultipleChannelIdsDisplay extends StatefulWidget {
  final List<String> channelsIds;
  const ShortsByMultipleChannelIdsDisplay({
    super.key,
    required this.channelsIds,
  });

  @override
  State<ShortsByMultipleChannelIdsDisplay> createState() =>
      _ShortsByMultipleChannelIdsDisplayState();
}

class _ShortsByMultipleChannelIdsDisplayState
    extends State<ShortsByMultipleChannelIdsDisplay> {
  late final ShortsController controller;

  @override
  void initState() {
    super.initState();
    controller = ShortsController(
      youtubeVideoSourceController:
          VideosSourceController.fromMultiYoutubeChannelsIds(
        channelsIds: getMockedChannelIds(),
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
