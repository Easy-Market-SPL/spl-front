import 'package:flutter/foundation.dart';

class InfoTripProvider extends ChangeNotifier {
  double _distance = 0.0;
  int _duration = 0;
  bool _metersDistance = false;

  double get distance => _distance;
  int get duration => _duration;
  bool get metersDistance => _metersDistance;

  void setDistance(double distance) {
    _distance = distance;
    notifyListeners();
  }

  void setDuration(int duration) {
    _duration = duration;
    notifyListeners();
  }

  void setMeters(bool meters) {
    _metersDistance = meters;
    notifyListeners();
  }

  void reset() {
    _distance = 0.0;
    _duration = 0;
    _metersDistance = false;
    notifyListeners();
  }
}
