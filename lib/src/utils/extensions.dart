import 'dart:async';

typedef Mapper<T, R> = R Function(
    T value, bool isFirst, bool isLast, int index);

typedef ForEachMapper<T> = FutureOr<void> Function(
    T value, bool isFirst, bool isLast, int index);

extension ListUtils<T> on List<T> {
  List<R> mapper<R>(Mapper<T, R> toElement) {
    return asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value;
      final isLast = (index + 1) == length;
      final isFirst = index == 0;
      return toElement(value, isFirst, isLast, index);
    }).toList();
  }

  FutureOr<void> forEachMapper(ForEachMapper<T> toElement) {
    asMap().entries.forEach((entry) {
      final index = entry.key;
      final value = entry.value;
      final isLast = (index + 1) == length;
      final isFirst = index == 0;
      toElement(value, isFirst, isLast, index);
    });
  }
}

extension NullableListLessBoilerPlateExtension<T> on List<T?> {
  bool get hasANotNullElement => any((element) => element != null);
  List<T> get removeNull => whereType<T>().toList();
}
