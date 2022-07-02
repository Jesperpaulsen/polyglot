import 'dart:async';

import 'package:flutter/foundation.dart';

class Debouncer {
  final VoidCallback callbackFn;
  final Duration timeout;
  Timer? _timer;

  Debouncer({required this.callbackFn, required this.timeout});

  void changeHappened() {
    cancelTimer();
    _timer = Timer(timeout, callbackFn);
  }

  void cancelTimer() {
    _timer?.cancel();
  }
}
