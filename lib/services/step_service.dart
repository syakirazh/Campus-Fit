import 'dart:async';
import 'dart:developer';

import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

/// Bridges the hardware step-counter (via the `pedometer` package, backed by
/// Android's step-counter sensor) into a simple "steps today" stream.
///
/// The sensor reports a cumulative count since device boot, so we convert that
/// into a per-day figure using a baseline captured the first time we see a
/// reading on a given calendar day.
class StepService {
  StreamSubscription<StepCount>? _subscription;

  /// Requests the activity-recognition permission. Returns true if granted.
  Future<bool> requestPermission() async {
    final status = await Permission.activityRecognition.request();
    return status.isGranted;
  }

  Future<bool> get hasPermission async =>
      (await Permission.activityRecognition.status).isGranted;

  /// Starts listening to the pedometer.
  ///
  /// [onCumulative] receives the raw since-boot count; the caller is
  /// responsible for baseline maths (kept in [StepService] callers/state so the
  /// baseline can be persisted). [onError] fires if the sensor is unavailable
  /// (e.g. on a device with no step counter) so the feature can degrade
  /// gracefully rather than crash.
  void start({
    required void Function(int cumulative) onCumulative,
    required void Function(Object error) onError,
  }) {
    _subscription?.cancel();
    _subscription = Pedometer.stepCountStream.listen(
      (event) => onCumulative(event.steps),
      onError: (Object e) {
        log('Pedometer error: $e', name: 'StepService');
        onError(e);
      },
      cancelOnError: false,
    );
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }
}
