# A package for displaying youtube shorts.
You can choose you shorts by passing a list of shorts url's, or by passing a channel name. Under the hood the package is using [youtube_explode_dart](https://pub.dev/packages/youtube_explode_dart) to get youtube video info and [media_kit](https://pub.dev/packages/media_kit) for as the player for videos. 

# Configurations and native permissions
Since the package uses [media_kit](https://pub.dev/packages/media_kit) as it's video player engine, the native configurations of this package are the same configurations of media_kit package. Click here to access the [media_kit package native configuration](https://pub.dev/packages/media_kit#permissions). Please do the configurations for the platforms you pretend to use.

That configurations also includes calling `MediaKit.ensureInitialized();` in the main function. Please check [documentation](https://pub.dev/packages/media_kit#tldr).

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

Now, we need too add the widget that shows the shorts and use the controller you just created.  

## Shorts page use (minimal example): 
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

