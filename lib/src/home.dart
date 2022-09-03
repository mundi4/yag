import 'package:flutter/material.dart';
import 'package:yag/src/routes.dart';

import 'bottom_button_bar.dart';
import 'due_date_selector.dart';
import 'work_target_list.dart';

class HomePage extends StatelessWidget with RouteAware {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('작업 관리'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, settingsRoute);
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: SafeArea(
          child: Column(
        children: const [
          DueDateSelector(),
          Divider(),
          WorkTargetList(),
          Divider(),
          BottomButtonBar(),
        ],
      )),
    );
  }
}

// class HomePage extends StatefulWidget with RouteAware {
//   const HomePage({Key? key}) : super(key: key);

//   @override
//   State<StatefulWidget> createState() {
//     return _HomePageState();
//   }
// }

// class _HomePageState extends State<HomePage> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // final WorkTargetListModel wtlm = context.read<WorkTargetListModel>();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('작업 관리'),
//         actions: [
//           IconButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, settingsRoute);
//               },
//               icon: const Icon(Icons.settings))
//         ],
//       ),
//       body: SafeArea(
//           child: Column(
//         children: const [
//           DueDateSelector(),
//           Divider(),
//           WorkTargetList(),
//           Divider(),
//           BottomButtonBar(),
//         ],
//       )),
//     );
//   }
// }
