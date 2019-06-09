import 'package:flutter/widgets.dart';

abstract class PowerStatefulWidget extends StatefulWidget {
  const PowerStatefulWidget({Key key}) : super(key: key);
}

abstract class PowerState<T extends StatefulWidget> extends State<T> {}
