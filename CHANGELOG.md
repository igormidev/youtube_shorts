## 1.0.0
* Stable version (No more alpha)
* Ended `VideosSourceController.fromYoutubeChannel()` implementation. Now without bugs.
* `VideoInfo` renamed to `VideoStats`
* `VideoStats` (previous VideoInfo) now does not carry more the hostedVideoUrl. But now it contains *hostedVideoInfo* that is a more complext object with more information.

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
