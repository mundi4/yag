import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'atg.dart';
import 'models/login_model.dart';
import 'models/settings_model.dart';
import 'models/work_target_list_model.dart';
import 'routes.dart';

class BottomButtonBar extends StatelessWidget {
  const BottomButtonBar({super.key});

  @override
  Widget build(BuildContext context) {
    final bool canStart =
        context.select((WorkTargetListModel m) => m.canStartAny);
    final bool canComplete =
        context.select((WorkTargetListModel m) => m.canCompleteAny);

    return ButtonBar(
      alignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
            onPressed: canStart
                ? () async {
                    await _startAll(context);
                  }
                : null,
            icon: const Icon(Icons.start),
            label: const Text('시작')),
        ElevatedButton.icon(
            onPressed: canComplete
                ? () async {
                    await _completeAll(context);
                  }
                : null,
            icon: const Icon(Icons.done),
            label: const Text('완료')),
      ],
    );
  }

  Future<void> _startAll(
    BuildContext context,
  ) async {
    final settingsModel = context.read<SettingsModel>();
    final wtlm = context.read<WorkTargetListModel>();
    try {
      await wtlm.startAll(settingsModel.workResultContents);
    } on AtGException catch (e) {
      if (e.message == 'loggedOut') {
        final loginModel = context.read<LoginModel>();
        if (await loginModel.tryLogin()) {
          await wtlm.loadWorkTargets();
          return;
        } else {
          Navigator.pushReplacementNamed(context, loginRoute);
        }
      } else {
        rethrow;
      }
    }
  }

  Future<void> _completeAll(
    BuildContext context,
  ) async {
    final wtlm = context.read<WorkTargetListModel>();
    try {
      await wtlm.completeAll();
    } on AtGException catch (e) {
      if (e.message == 'loggedOut') {
        final loginModel = context.read<LoginModel>();
        if (await loginModel.tryLogin()) {
          await wtlm.loadWorkTargets();
          return;
        } else {
          Navigator.pushReplacementNamed(context, loginRoute);
        }
      } else {
        rethrow;
      }
    }
  }
}
