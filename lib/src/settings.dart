import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yag/src/models/login_model.dart';
import 'package:yag/src/models/settings_model.dart';
import 'package:yag/src/routes.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SettingsPageState();
  }
}

class _SettingsPageState extends State<SettingsPage> with RestorationMixin {
  late final RestorableString _workGroup;
  late final RestorableString _resultContents;
  late final RestorableDouble _timeOffset;

  final sizedBoxSpace = const SizedBox(height: 24);

  @override
  void initState() {
    super.initState();
    final settingsModel = context.read<SettingsModel>();
    _workGroup = RestorableString(settingsModel.workGroup);
    _resultContents = RestorableString(settingsModel.workResultContents);
    _timeOffset = RestorableDouble(settingsModel.timeOffset.toDouble());
  }

  @override
  void dispose() {
    _timeOffset.dispose();
    super.dispose();
  }

  void load() {}

  @override
  String get restorationId => 'settings';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_workGroup, '_workGroup');
    registerForRestoration(_resultContents, '_resultContents');
    registerForRestoration(_timeOffset, '_timeOffset');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('설정'),
        ),
        body: SafeArea(
            child: Scrollbar(
          child: SingleChildScrollView(
              restorationId: 'settings_scroll_view',
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(children: [
                sizedBoxSpace,
                Form(
                    child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: DropdownButtonFormField<String>(
                        items: const [
                          DropdownMenuItem<String>(
                              value: 'day', child: Text('주간')),
                          DropdownMenuItem<String>(
                              value: 'night', child: Text('야간')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _workGroup.value = value ?? 'day';
                          });
                        },
                        value: _workGroup.value,
                        decoration: const InputDecoration(
                          // filled: true,
                          //fillColor: Hexcolor('#ecedec'),
                          labelText: '작업 필터',
                          //border: new CustomBorderTextFieldSkin().getSkin(),
                        ),
                      ),
                    ),

                    if (_workGroup.value == 'night')
                      buildTimeOffsetSlider(settingsModel),

                    sizedBoxSpace,
                    TextFormField(
                      onChanged: (value) {
                        setState(() {
                          _resultContents.value = value;
                        });
                      },
                      initialValue: _resultContents.value,
                      decoration: const InputDecoration(
                        labelText: '작업결과 텍스트',
                        hintText: '예: 작업결과 양호',
                      ),
                    ),
                    sizedBoxSpace,
                    // TextFormField(
                    //   decoration: const InputDecoration(
                    //     labelText: '작업 검색 필터',
                    //     hintText: 'D',
                    //   ),
                    // ),
                    // sizedBoxSpace,
                  ],
                )),
                ElevatedButton(
                  onPressed: save,
                  child: const Text('저장'),
                ),
                sizedBoxSpace,
                const Divider(),
                Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                        onPressed: logout,
                        style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.tertiary),
                        child: const Text('로그아웃하기'))),
                const SizedBox(height: 24),
                if (Platform.isWindows)
                  const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('모바일(안드로이드) 버전: 👉 mundi4@gmail.com'))
              ])),
        )));
  }

  void save() {
    final settingsModel = context.read<SettingsModel>();
    settingsModel.workGroup = _workGroup.value;
    settingsModel.workResultContents = _resultContents.value;
    settingsModel.timeOffset = _timeOffset.value.toInt();
    settingsModel.saveToStorage();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('저장되었습니다.'),
      action: SnackBarAction(
          label: '닫기',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }),
    ));
  }

  Future<void> logout() async {
    final loginModel = context.read<LoginModel>();
    await loginModel.logout();

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('로그아웃되었습니다.'),
      ));

      Navigator.pushNamedAndRemoveUntil(
          context, loginRoute, ModalRoute.withName(loginRoute));
    }
  }

  Widget buildTimeOffsetSlider(SettingsModel settingsModel) {
    return Column(
      children: [
        sizedBoxSpace,
        Text(
          '앱 실행 시에 보여줄 날짜 조정',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        Slider(
            value: _timeOffset.value,
            min: 0,
            max: 12,
            divisions: 12,
            onChanged: (value) {
              setState(() {
                _timeOffset.value = value;
              });
            }),
        Text(
          _timeOffset.value > 0 ? '${_timeOffset.value.toInt()}시간 빠르게' : '',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
