import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final SettingsModel settingsModel = SettingsModel();

class SettingsModel extends ChangeNotifier {
  String _workGroup = 'day';
  String _workResultContents = '';
  int _timeOffset = 0;

  String get workGroup => _workGroup;

  set workGroup(String workGroup) {
    if (_workGroup != workGroup) {
      _workGroup = workGroup;
      notifyListeners();
    }
  }

  String get workResultContents => _workResultContents;

  set workResultContents(String value) {
    if (_workResultContents != value) {
      _workResultContents = value;
      notifyListeners();
    }
  }

  int get timeOffset => _timeOffset;

  set timeOffset(int value) {
    if (_timeOffset != value) {
      _timeOffset = value;
      notifyListeners();
    }
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    workGroup = prefs.getString('workGroup') ?? 'day';
    workResultContents = prefs.getString('workResultContents') ?? '작업결과양호';
    timeOffset = int.parse(prefs.getString('timeOffset') ?? '0');

    notifyListeners();
  }

  Future<void> saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString('workGroup', _workGroup);
    prefs.setString('workResultContents', _workResultContents);
    prefs.setString('timeOffset', _timeOffset.toString());
  }
}
