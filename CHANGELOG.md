## 3.0.0
* Added new source `VideosSourceController.fromMultiYoutubeChannels`
* Added new source `VideosSourceController.fromYoutubeChannelId`
* Added new source `VideosSourceController.fromMultiYoutubeChannelsIds`
* Added `onlyVerticalVideos` option to all sources (unless the **fromUrlList** source).
* Perfomance improvement in `VideosSourceController.fromYoutubeChannel`

## 2.1.1
* Fix audio bug on `YoutubeShortsHorizontalStoriesSection`

## 2.1.0
* Added `notFocusedUiType` parameter to `YoutubeShortsHorizontalStoriesSection`
* Added circular progress indicator in `YoutubeShortsHorizontalStoriesSection` widget
* `setCurrentVideoVolume` renamed to `setCurrentVideoVolume`
* `startVideoWithVolume` config added
* `onPrevVideoPause` added to notifyCurrentIndex function
* `onCurrentVideoPlay` added to notifyCurrentIndex function

## 2.0.1
* Color bug fix

## 2.0.0
### ⚠️ BREAKING CHANGES!
* `ShortsPage` renamed to `YoutubeShortsPage`
* Configs variables and `startWithAutoplay` and `startVideoMuted` are not more in `ShortsControllerSettings`. But inside `ShortsControllerSettings` class of `controllerSettings` parameter of `ShortsControllerSettings`
* `ShortsControllerSettings` added to `ShortsControllerSettings`
* Widget `YoutubeShortsHorizontalStoriesSection` added
* Boolean setting `startVideoMuted` added to `ShortsController` settings

## 1.1.1
* (internal) Removed lock of synchronized package in places that are not needed 

## 1.1.0
* Error State added to package with the error and stacktrace details
* Added shortcut in controller to pause, play, mute and set volume. So now it's no more needed to call the current 
* README.md update
* Better code organization

## 1.0.0
### ⚠️ BREAKING CHANGES!
* Stable version (No more alpha)
* Ended `VideosSourceController.fromYoutubeChannel()` implementation. Now without bugs.
* `VideoInfo` renamed to `VideoStats`
* `VideoStats` (previous VideoInfo) now does not carry more the hostedVideoUrl. But instead it contains *hostedVideoInfo* that is a more complext object with more information.

## 0.4.5 - Alpha
* Using multithread for perfomance improvement

## 0.4.4 - Alpha
* Audio in android bug fix
* Perfomance improvement
* More stable function execution - less bugs. `synchronized` package implemented.

## 0.4.3 - Alpha
* All bugs fixed with initial index
* Giant perfomance improvement
* Initial index putted in `VideosSourceController.fromUrlList`

## 0.4.2 - Alpha
* README.md update

## 0.4.1 - Alpha
* Widget child builder function added

## 0.4.0 - Alpha
* Added `willHaveDefaultShortsControllers` option to `ShortsPage`
* Fix `initialIndex` not working as expected
* Page controller added to builder options for more user controll

## 0.3.0 - Alpha
* Initial index assert guideline
* Export `MediaKit` so developer is able to call `MediaKit.ensureInitialized()`

## 0.2.0 - Alpha
* Initial index option added for `VideosSourceController.fromUrlList`` constructor
* VideoControllerConfiguration of [media_kit](https://pub.dev/packages/media_kit) exported to final user

## 0.1.0 - Alpha
* Initial release
