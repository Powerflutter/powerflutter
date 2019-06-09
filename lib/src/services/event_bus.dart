import 'dart:async';

class EventBus {
  StreamController _streamController = StreamController.broadcast(sync: true);

  Stream<T> on<T>() {
    if (T == dynamic) {
      return _streamController.stream;
    } else {
      return _streamController.stream.where((event) => event is T).cast<T>();
    }
  }

  void fire(event) {
    _streamController.add(event);
  }
}
