import 'package:flutter/widgets.dart';
import 'package:powerflutter/powerflutter.dart';

abstract class PowerWidget<T extends PowerModel> extends StatefulWidget {
  const PowerWidget({Key key}) : super(key: key);

  T get model => Power.getDI<T>();
  BuildContext get context => Power.getDI<BuildContext>();

  @override
  _PowerWidgetState createState() => _PowerWidgetState();

  void disableBindingDuring(Function() func) {
    BindingHelper.disableRebuildDuring(this, func);
  }

  Widget build(BuildContext context);
}

class _PowerWidgetState extends PowerState<PowerWidget> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    Widget built;
    dynamic error;

    BindingHelper.rebuildNewBindableWidget(this);
    try {
      Power.setDI(context);
      built = widget.build(context);
    } on Object catch (ex) {
      error = ex;
    }
    BindingHelper.buildBindableWidgetfinished(this);

    if (error != null) {
      throw error;
    }

    return built;
  }

  @override
  dispose() {
    BindingHelper.removeState(this);
    super.dispose();
  }
}
