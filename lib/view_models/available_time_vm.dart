import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:task_management_app/models/available_time.dart';
import 'package:task_management_app/repositories/available_time_repo.dart';

class AvailableTimeViewModel with ChangeNotifier {
  final AvailableTimeRepository _availableTimeRepository;
  StreamSubscription<AvailableTime>? _availableTimeSubscription;

  AvailableTime? _availableTime;
  AvailableTime? get availableTime => _availableTime;
  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;
  String _serverId;

  AvailableTimeViewModel(String serverId, {AvailableTimeRepository? availableTimeRepository})
      : _serverId = serverId,_availableTimeRepository = availableTimeRepository ?? AvailableTimeRepository() {
    _initialize();
  }

  void _initialize() {
    _availableTimeSubscription = _availableTimeRepository.streamAvailableTime(_serverId).listen(
      (availableTime) {
        _isInitializing = false;
        _availableTime = availableTime;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _availableTimeSubscription?.cancel();
    super.dispose();
  }
  void updateServerId(String newServerId) {
    if (newServerId != _serverId) {
      _availableTimeSubscription?.cancel();
      _serverId = newServerId;
      _isInitializing = true; 
      notifyListeners(); 
      _initialize();
    }
  }

  Future<void> updateAvailableTime(AvailableTime availableTime) async {
    await _availableTimeRepository.updateAvailableTime(_serverId, availableTime);
  }
}
