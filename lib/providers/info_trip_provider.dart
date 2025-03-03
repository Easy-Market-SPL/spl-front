import 'package:flutter/foundation.dart';

class InfoTripProvider extends ChangeNotifier {
  double _distance = 0.0;
  double _duration = 0.0;

  double get distance => _distance;
  double get duration => _duration;

  void setDistance(double distance) {
    _distance = distance;
    notifyListeners();
  }

  void setDuration(double duration) {
    _duration = duration;
    notifyListeners();
  }

  void reset() {
    _distance = 0.0;
    _duration = 0.0;
    notifyListeners();
  }
}
