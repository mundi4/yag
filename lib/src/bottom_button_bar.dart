import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yag/src/models/settings_model.dart';

import 'models/work_target_list_model.dart';

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
                    final settingsModel = context.read<SettingsModel>();
                    await context
                        .read<WorkTargetListModel>()
                        .startAll(settingsModel.workResultContents);
                  }
                : null,
            icon: const Icon(Icons.start),
            label: const Text('일괄 시작')),
        ElevatedButton.icon(
            onPressed: canComplete
                ? () async {
                    await context.read<WorkTargetListModel>().completeAll();
                  }
                : null,
            icon: const Icon(Icons.done),
            label: const Text('일괄 완료')),
      ],
    );
  }
}
