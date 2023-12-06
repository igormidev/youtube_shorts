<p float="left">
  <img src="https://freelogopng.com/images/all_img/1684952459youtube-shorts-logo-png.png" width="170"/>
  <img style="margin: 0 0 -10px 0;" src="https://images.vexels.com/media/users/3/158039/isolated/preview/05331045aee2a8e5142775d30365b88e-handshake-silhouette-icon.png" width="80"/>
  <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/f/fe/Dart_programming_language_logo.svg/1200px-Dart_programming_language_logo.svg.png" width="180" />
</p>

### ▶️ youtube_shorts: A package for displaying youtube shorts.
A vertical youtube shorts player. You can choose what shorts will be displayed by passing a list of shorts url's or by passing a channel name. Under the hood the package is using [youtube_explode_dart](https://pub.dev/packages/youtube_explode_dart) to get youtube video info and [media_kit](https://pub.dev/packages/media_kit) as the player for videos. 

<br>

# Configurations and native permissions
Since the package uses [media_kit](https://pub.dev/packages/media_kit) as it's video player engine, the native configurations of this package are the same configurations of media_kit package. Click here to access the [media_kit package native configuration](https://pub.dev/packages/media_kit#permissions). Please do the configurations for the platforms you pretend to use.

That configurations also includes calling `MediaKit.ensureInitialized();` in the main function. Please check [documentation](https://pub.dev/packages/media_kit#tldr).

After macking the configuration, use [`package:permission_handler`](https://pub.dev/packages/permission_handler) to request access at runtime:

```dart
if (/* Android 13 or higher. */) {
  // Video permissions.
  if (await Permission.videos.isDenied || await Permission.videos.isPermanentlyDenied) {
    final state = await Permission.videos.request();
    if (!state.isGranted) {
      await SystemNavigator.pop();
    }
  }
  // Audio permissions.
  if (await Permission.audio.isDenied || await Permission.audio.isPermanentlyDenied) {
    final state = await Permission.audio.request();
    if (!state.isGranted) {
      await SystemNavigator.pop();
    }
  }
} else {
  if (await Permission.storage.isDenied || await Permission.storage.isPermanentlyDenied) {
    final state = await Permission.storage.request();
    if (!state.isGranted) {
      await SystemNavigator.pop();
    }
  }
}
```

# Basic how to use
First, you will need to create a `VideosSourceController` that will controll all the video source. There are two constructor of the source controller. From a list of url or from the channel name. Examples are bellow:

## By list of youtube url's (example): 
```dart
late final ShortsController controller;

@override
void initState() {
  super.initState();
  controller = ShortsController(
    youtubeVideoInfoService: VideosSourceController.fromUrlList(
      videoIds: [
        'https://www.youtube.com/shorts/PiWJWfzVwjU',
        'https://www.youtube.com/shorts/AeZ3dmC676c',
        'https://www.youtube.com/shorts/L1lg_lxUxfw',
        'https://www.youtube.com/shorts/OWPsdhLHK7c',
        ...
      ],
    ),
  );
}
```

## By channel name (example): 
```dart
late final ShortsController controller;

@override
void initState() {
  super.initState();
  controller = ShortsController(
    youtubeVideoInfoService: VideosSourceController.fromYoutubeChannel(
      channelName: 'fcbarcelona',
    ),
  );
}
```

## Shorts page use (minimal example): 
Now, we need too add the widget that shows the shorts and will use the controller we just created.

```dart
@override
Widget build(BuildContext context) {
  return ShortsPage(
    controller: controller,
  );
}
```

Don't forget to dispose the controller after closing the page.
```dart
@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```

---
Made with ❤ by [Igor Miranda](https://github.com/igormidev) <br>
If you like the package, give a 👍