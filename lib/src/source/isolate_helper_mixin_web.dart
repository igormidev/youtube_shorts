/// Web version of [IsolateHelperMixin] just because 'easy_isolate_mixin'
/// package does not have suport to web.
mixin IsolateHelperMixin {
  Future<T> loadWithIsolate<T>(Future<T> Function() function) {
    return function();
  }
}
