import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'models/work_target_list_model.dart';

class DueDateSelector extends StatelessWidget {
  const DueDateSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dueDate = context.select((WorkTargetListModel m) => m.dueDate);

    final locale = Localizations.localeOf(context).languageCode;
    //'-${Localizations.localeOf(context).countryCode}';

    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        child: Row(children: [
          IconButton(
              onPressed: () => _goPrevDate(context),
              icon: const Icon(Icons.navigate_before)),
          //const SizedBox(width: 7),
          Expanded(
              child: Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () => _showDatePicker(context),
                    child: Text(DateFormat.yMMMMEEEEd(locale).format(dueDate),
                        style: Theme.of(context).textTheme.titleLarge),
                  ))),
          IconButton(
              onPressed: () => _goNextDate(context),
              icon: const Icon(Icons.navigate_next)),
        ]));
  }

  void _goPrevDate(BuildContext context) {
    final WorkTargetListModel wtlm = context.read<WorkTargetListModel>();
    wtlm.dueDate = wtlm.dueDate.subtract(const Duration(days: 1));
  }

  void _goNextDate(BuildContext context) {
    final WorkTargetListModel wtlm = context.read<WorkTargetListModel>();
    wtlm.dueDate = wtlm.dueDate.add(const Duration(days: 1));
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final WorkTargetListModel wtlm = context.read<WorkTargetListModel>();
    var date = await showDatePicker(
        context: context,
        initialDate: wtlm.dueDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        initialEntryMode: DatePickerEntryMode.calendarOnly);
    if (date != null) {
      wtlm.dueDate = date;
    }
  }
}

// class DueDateSelector extends StatefulWidget {
//   const DueDateSelector({Key? key}) : super(key: key);

//   @override
//   State<DueDateSelector> createState() => _DueDateSelectorState();
// }

// class _DueDateSelectorState extends State<DueDateSelector> {
//   @override
//   Widget build(BuildContext context) {
//     final dueDate = context.select((WorkTargetListModel m) => m.dueDate);

//     final locale = Localizations.localeOf(context).languageCode;
//     //'-${Localizations.localeOf(context).countryCode}';

//     return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
//         child: Row(children: [
//           IconButton(
//               onPressed: _goPrevDate, icon: const Icon(Icons.navigate_before)),
//           //const SizedBox(width: 7),
//           Expanded(
//               child: Align(
//                   alignment: Alignment.center,
//                   child: GestureDetector(
//                     onTap: _showDatePicker,
//                     child: Text(DateFormat.yMMMMEEEEd(locale).format(dueDate),
//                         style: Theme.of(context).textTheme.titleLarge),
//                   ))),
//           IconButton(
//               onPressed: _goNextDate, icon: const Icon(Icons.navigate_next)),
//           //ElevatedButton(onPressed: _showDatePicker, child: const Text('변경')),
//         ]));
//   }

//   void _goPrevDate() {
//     final WorkTargetListModel wtlm = context.read<WorkTargetListModel>();
//     setState(() {
//       wtlm.dueDate = wtlm.dueDate.subtract(const Duration(days: 1));
//     });
//   }

//   void _goNextDate() {
//     final WorkTargetListModel wtlm = context.read<WorkTargetListModel>();
//     setState(() {
//       wtlm.dueDate = wtlm.dueDate.add(const Duration(days: 1));
//     });
//   }

//   Future<void> _showDatePicker() async {
//     final WorkTargetListModel wtlm = context.read<WorkTargetListModel>();
//     var date = await showDatePicker(
//         context: context,
//         initialDate: wtlm.dueDate,
//         firstDate: DateTime(2020),
//         lastDate: DateTime(2100),
//         initialEntryMode: DatePickerEntryMode.calendarOnly);
//     if (date != null) {
//       setState(() {
//         wtlm.dueDate = date;
//       });
//     }
//   }
// }
