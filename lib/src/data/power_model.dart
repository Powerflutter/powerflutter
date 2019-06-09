import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:powerflutter/powerflutter.dart';
import 'package:uuid/uuid.dart';

@immutable
class Observation {
  final PowerModel object;
  final String name;
  const Observation(this.object, this.name);
}

@immutable
class Change {
  final PowerModel object;
  final String name;
  final oldValue;
  const Change(this.object, this.name, this.oldValue);
}

class PowerModelInternalState {
  bool muted = false;
}

class PowerModel {
  static StreamController<Observation> _observations = StreamController.broadcast(sync: true);
  static Stream<Observation> get observationStream => _observations.stream;
  static StreamController<Change> _changes = StreamController.broadcast(sync: true);
  static Stream<Change> get changesStream => _changes.stream;

  static T makeTyped<T>(Map value) {
    var factory = Power.classFactory.get(T);
    if (factory != null) {
      var object = factory();
      value.forEach((k, v) => object.set(k, v));
      return object as T;
    }
    return null;
  }

  static disableAllUpdates() {
    _observations.close();
    _changes.close();
  }

  final Map<String, dynamic> _values = Map();
  final _state = PowerModelInternalState();

  String get uuid => get("uuid", () => Uuid().v4());

  set<T>(String name, T value) {
    assert(value == null || value is String || value is num || value is bool || value is PowerModel || value is List || value is Map,
        "only set values of Type String, int, double, bool, PowerModel, PowerList or PowerMap, $value was set for $name on $this");
    var oldValue = _values[name];
    if (oldValue == value) return;
    _values[name] = value;
    hasChanged(name, oldValue);
  }

  T get<T>(String name, T Function() defaultValueFunction) {
    isObserved(name);
    var value = _values[name];
    if (value is T) return value;

    // If value is Map it is not yet converted from serialization, convert it
    if (value is Map) {
      var typed = makeTyped<T>(value);
      set(name, typed);
      return typed;
    }

    //convert to PowerList if it is a List
    if (value is List) {
      T newList = Power.classFactory.get(T)() as T;
      var powerList = newList as PowerList;
      for (var item in value) {
        powerList.add(powerList.makeTyped(item));
      }
      set(name, newList);
      return newList;
    }

    // nothing found, use default Value
    var defaultValue = defaultValueFunction();
    set<T>(name, defaultValue);
    return defaultValue;
  }

  String toJson() {
    return toJsonInternal(StringBuffer()).toString();
  }

  @protected
  StringBuffer toJsonInternal(StringBuffer buffer) {
    buffer.write("{");
    var firstItem = true;
    _values.forEach((key, value) {
      if (firstItem)
        firstItem = false;
      else
        buffer.write(",");
      buffer.write('"');
      buffer.write(key);
      buffer.write('"');
      buffer.write(":");
      try {
        if (value is PowerModel)
          value.toJsonInternal(buffer);
        else
          buffer.write(json.encode(value));
      } catch (e) {}
    });
    buffer.write("}");
    return buffer;
  }

  void fillFromJsonString(String jsonData) {
    if (jsonData == "") return;
    var object = json.decode(jsonData) as Map;
    object.forEach((key, value) => set(key, value));
  }

  @protected
  void hasChanged(String name, oldValue) {
    _changes.sink.add(new Change(this, name, oldValue));
  }

  @protected
  void isObserved(String name) {
    if (!_state.muted) _observations.sink.add(Observation(this, name));
  }

  dynamic getWithoutBinding<T extends PowerModel>(dynamic Function(T x) item) {
    _state.muted = true;
    var returnValue = item(this);
    _state.muted = false;
    return returnValue;
  }
}
