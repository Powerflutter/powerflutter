import 'package:powerflutter/powerflutter.dart';
import 'package:powerflutter/src/data/power_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PowerSharedPreferences {
  static persistModel<T extends PowerModel>(PowerModel model, String key, {Duration duration: const Duration(milliseconds: 1000)}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var data = prefs.getString(key);
    if (data != null) model.fillFromJsonString(data);

    var waitingForSaving = false;
    PowerModel.changesStream.listen((change) {
      if (waitingForSaving) return;
      waitingForSaving = true;
      Future.delayed(
          duration,
          () => {
                prefs.setString(key, model.toJson()),
                waitingForSaving = false,
              });
    });
    return model;
  }
}
