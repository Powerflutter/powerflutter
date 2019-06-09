import 'package:powerflutter/powerflutter.dart';

typedef FactoryFunc<T extends PowerModel> = T Function();

class Power {
  static final classFactory = ClassFactory();
  static final eventBus = EventBus();
  static final Map<Type, Object> _diTypes = Map();

  static setDI<T extends Object>(T object) {
    _diTypes[T] = object;
  }

  static T getDI<T extends Object>() {
    return _diTypes[T] as T;
  }
}

// Annotations:

class ModelName {
  final String name;
  const ModelName(this.name);
}

const powermodel = PowerModelAnnotation();
