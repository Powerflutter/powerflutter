import 'package:powerflutter/powerflutter.dart';

class ClassFactory {
  final Map<Type, FactoryFunc> _factoryTypes = Map();

  register<T extends PowerModel>(FactoryFunc<T> create) {
    registerWithoutInitalCreation(create, create().runtimeType);
  }

  registerWithoutInitalCreation<T extends PowerModel>(FactoryFunc<T> create, Type type) {
    _factoryTypes[type] = create;
    PowerList<T> list = PowerList<T>();
    PowerMap<T> map = PowerMap<T>();
    _factoryTypes[list.runtimeType] = () => PowerList<T>();
    _factoryTypes[map.runtimeType] = () => PowerMap<T>();
  }

  FactoryFunc get(Type type) {
    var factoryFunc = _factoryTypes[type];
    assert(factoryFunc != null, "Please call Power.classFactory.registerClass for $Type");
    return factoryFunc;
  }
}
