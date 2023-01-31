import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:yag/src/atg.dart';
import 'package:yag/src/models/settings_model.dart';
import 'package:yag/src/models/work_target.dart';

class WorkTargetListModel extends ChangeNotifier {
  final AtG atG;
  final SettingsModel settingsModel;
  DateTime _dueDate = DateUtils.dateOnly(DateTime.now());
  String _workGroup = '';
  List<WorkTarget>? _items;
  bool _canStart = false;
  bool _canComplete = false;

  WorkTargetListModel({required this.atG, required this.settingsModel}) {
    _workGroup = settingsModel.workGroup;
    settingsModel.addListener(_settingsModelChanged);
  }

  @override
  void dispose() {
    super.dispose();
    settingsModel.removeListener(_settingsModelChanged);
  }

  DateTime get dueDate {
    return _dueDate;
  }

  set dueDate(DateTime value) {
    value = DateUtils.dateOnly(value);
    if (_dueDate != value) {
      _dueDate = value;
      notifyListeners();
    }
  }

  String get workGroup {
    return _workGroup;
  }

  UnmodifiableListView<WorkTarget>? get items {
    if (_items != null) {
      return UnmodifiableListView<WorkTarget>(_items!);
    } else {
      return null;
    }
  }

  bool get canStartAny => _canStart;

  bool get canCompleteAny => _canComplete;

  void _settingsModelChanged() {
    if (_workGroup != settingsModel.workGroup) {
      _workGroup = settingsModel.workGroup;
      notifyListeners();
    }
  }

  Future<void> loadWorkTargets() async {
    if (_items != null || _canStart || _canComplete) {
      _items = null;
      _canStart = false;
      _canComplete = false;
      notifyListeners();
    }

    var items = await atg.getWorkTargets(_dueDate, _dueDate);
    if (_workGroup == 'night') {
      items = items
          .where((item) => item.wkPlacNm.startsWith('D야간'))
          .toList(growable: false);
    } else if (_workGroup == 'day') {
      items = items
          .where((item) =>
              item.wkPlacNm.startsWith('D') && !item.wkPlacNm.startsWith('D야간'))
          .toList(growable: false);
    } else {
      items = items
          .where((item) => item.wkPlacNm.startsWith('D'))
          .toList(growable: false);
    }

    _items = items;
    _canStart = items.any((item) => item.wkScd == statusPublished);
    _canComplete = items.any((item) => item.wkScd == statusInProgress);
    notifyListeners();
  }

  Future<void> startAll(String resultContents) async {
    if (_items == null) {
      return;
    }

    _canStart = false;
    _canComplete = false;
    notifyListeners();

    List<WorkTarget> newList = List.from(_items!);
    for (var i = 0; i < _items!.length; i++) {
      final item = _items![i];
      //await Future.delayed(const Duration(milliseconds: 100));
      await atg.updateWorkStatus(item.wkNo, statusInProgress, resultContents);
      newList[i] = item.withStatus(statusInProgress, resultContents);
      notifyListeners();
    }

    _items = newList;
    _canStart = false;
    _canComplete = true;
    notifyListeners();
    // log('done');
  }

  Future<void> completeAll() async {
    if (_items == null) {
      return;
    }

    _canStart = false;
    _canComplete = false;
    notifyListeners();

    List<WorkTarget> newList = List.from(_items!);
    for (var i = 0; i < _items!.length; i++) {
      final item = _items![i];
      await atg.updateWorkStatus(item.wkNo, statusCompleted, null);
      newList[i] = item.withStatus(statusCompleted, null);
    }

    _items = newList;
    _canStart = false;
    _canComplete = false;
    notifyListeners();
    // log('done');
  }
}
