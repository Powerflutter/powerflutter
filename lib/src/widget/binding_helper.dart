import 'package:flutter/widgets.dart';
import 'package:powerflutter/powerflutter.dart';
import 'package:powerflutter/src/widget/power_state.dart';

class BindingHelper {
  static final Set<Widget> _noRebuildStates = Set();
  static final List<PowerState> _buildStatesStack = new List();
  static State _activeWidgetState;

  static final Map<PowerModel, Map<String, List<PowerState>>> observeringStates = Map();

  static bool _firstUse = true;

  static void rebuildNewBindableWidget(PowerState state) {
    if (_firstUse) {
      PowerModel.observationStream.listen(modelIsOberserved);
      PowerModel.changesStream.listen(modelChanged);
      _firstUse = false;
    }
    _buildStatesStack.add(state);
    _activeWidgetState = state;
  }

  static void modelChanged(Change event) {
    var stateList = getStatesList(event.object, event.name);
    if (stateList == null) return;
    for (var item in stateList) {
      if (!_noRebuildStates.contains(item.widget) && item.context is StatefulElement) (item.context as StatefulElement).markNeedsBuild();
    }
  }

  static List<PowerState> getStatesList(PowerModel object, String name) {
    var models = observeringStates[object];
    if (models == null) return null;
    return models[name];
  }

  static void modelIsOberserved(Observation event) {
    if (_activeWidgetState == null) return;
    var models = observeringStates[event.object];
    if (models == null) {
      models = Map();
      observeringStates[event.object] = models;
    }
    var stateList = models[event.name];
    if (stateList == null) {
      stateList = List();
      models[event.name] = stateList;
    }
    if (!stateList.contains(_activeWidgetState)) {
      stateList.add(_activeWidgetState);
    }
  }

  static removeState(PowerState state) {
    for (var item in observeringStates.values) {
      for (var list in item.values) {
        if (list.contains(state)) list.remove(state);
      }
    }
  }

  static void buildBindableWidgetfinished(PowerState state) {
    _buildStatesStack.remove(state);
    if (_buildStatesStack.length == 0)
      _activeWidgetState = null;
    else
      _activeWidgetState = _buildStatesStack[_buildStatesStack.length - 1];
  }

  static void disableRebuildDuring(Widget widget, Function() func) {
    _noRebuildStates.add(widget);
    func();
    _noRebuildStates.remove(widget);
  }
}
