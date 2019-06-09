import 'package:flutter/widgets.dart';
import 'package:powerflutter/src/widget/power_state.dart';

import 'binding_helper.dart';

class PowerBuilder extends StatefulWidget {
  const PowerBuilder({@required this.builder, Key key})
      : assert(builder != null),
        super(key: key);

  final WidgetBuilder builder;

  void disableBindingDuring(Function() func) {
    BindingHelper.disableRebuildDuring(this, func);
  }

  @override
  State<PowerBuilder> createState() => _PowerBuilderState();
}

class _PowerBuilderState extends PowerState<PowerBuilder> {
  @override
  Widget build(BuildContext context) {
    Widget built;
    BindingHelper.rebuildNewBindableWidget(this);
    built = widget.builder(context);
    BindingHelper.buildBindableWidgetfinished(this);

    return built;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
