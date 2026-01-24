import 'dart:async';
import 'package:flutter/material.dart';

/// Monitoring status for Sentinel Mode
enum SentinelStatus {
  secure,
  warning,
  compromised,
}

/// Activity event type for Sentinel Mode
enum SentinelActivityType {
  windowSwitch,
  pasteAttempt,
  longInactivity,
}

/// Sentinel Service - Monitors coding challenge integrity
class SentinelService with ChangeNotifier {
  bool _isEnabled = false;
  int _violations = 0;
  final int _maxViolations = 3;
  
  final _activityController = StreamController<SentinelActivityType>.broadcast();
  Stream<SentinelActivityType> get activityStream => _activityController.stream;

  bool get isEnabled => _isEnabled;
  int get violations => _violations;
  
  SentinelStatus get status {
    if (!_isEnabled) return SentinelStatus.secure;
    if (_violations == 0) return SentinelStatus.secure;
    if (_violations >= _maxViolations) return SentinelStatus.compromised;
    return SentinelStatus.warning;
  }

  double get integrityScore {
    if (!_isEnabled) return 1.0;
    return (1.0 - (_violations / _maxViolations)).clamp(0.0, 1.0);
  }

  void startMonitoring() {
    _isEnabled = true;
    _violations = 0;
    notifyListeners();
  }

  void stopMonitoring() {
    _isEnabled = false;
    notifyListeners();
  }

  void reportActivity(SentinelActivityType type) {
    if (!_isEnabled) return;
    
    _violations++;
    _activityController.add(type);
    notifyListeners();
  }

  void resetViolations() {
    _violations = 0;
    notifyListeners();
  }

  void dispose() {
    _activityController.close();
  }
}
