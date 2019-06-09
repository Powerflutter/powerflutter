import 'dart:collection';

import 'power_model.dart';

class PowerList<T extends PowerModel> with ListMixin<T>, PowerModel {
  final List<T> _list = List();

  static const String listChanged = "ListChanged";

  @override
  int get length {
    isObserved(listChanged);
    return _list.length;
  }

  @override
  set length(int newLength) {
    _list.length = newLength;
    hasChanged(listChanged, null);
  }

  @override
  T operator [](int index) {
    isObserved(listChanged);
    return _list[index];
  }

  @override
  void operator []=(int index, T value) {
    _list[index] = value;
    hasChanged(listChanged, null);
  }

  void swap(int x, int y) {
    var tmp = _list[x];
    _list[x] = _list[y];
    _list[y] = tmp;
    hasChanged(listChanged, null);
  }

  @override
  StringBuffer toJsonInternal(StringBuffer buffer) {
    if (buffer == null) buffer = StringBuffer();
    buffer.write("[");
    for (var i = 0; i < _list.length; i++) {
      if (i != 0) buffer.write(",");
      _list[i].toJsonInternal(buffer);
    }
    buffer.write("]");
    return buffer;
  }

  List<W> buildWidgets<W>(W Function(T) buildFunction) {
    return map(buildFunction).toList();
  }

  T makeTyped(Map item) {
    return PowerModel.makeTyped<T>(item);
  }
}
