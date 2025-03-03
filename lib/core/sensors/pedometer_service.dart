import 'dart:developer' as dev;

import 'package:pedometer/pedometer.dart';

class PedometerService {
  void startListening() {
    Pedometer.stepCountStream.listen((StepCount stepCount) {
      dev.log("Steps taken: ${stepCount.steps}");
    });
  }
}
