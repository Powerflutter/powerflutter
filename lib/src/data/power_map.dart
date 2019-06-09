import 'dart:collection';

import 'power_model.dart';

class PowerMap<V extends PowerModel> with MapMixin<String, V>, PowerModel {
  final Map<String, V> _map = new Map();

  static const String mapChanged = "MapChanged";

  @override
  V operator [](Object key) {
    isObserved(mapChanged);
    return _map[key];
  }

  @override
  void operator []=(String key, V value) {
    hasChanged(mapChanged, null);
    _map[key] = value;
  }

  @override
  void clear() {
    hasChanged(mapChanged, null);
    _map.clear();
  }

  @override
  Iterable<String> get keys {
    isObserved(mapChanged);
    return _map.keys;
  }

  @override
  V remove(Object key) {
    hasChanged(mapChanged, null);
    return _map.remove(key);
  }
}
