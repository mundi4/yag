import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yag/src/models/login_model.dart';
import 'package:yag/src/models/work_target.dart';
import 'package:yag/src/models/work_target_list_model.dart';

import 'atg.dart';
import 'routes.dart';

class WorkTargetList extends StatefulWidget {
  const WorkTargetList({super.key});

  @override
  State<StatefulWidget> createState() {
    return _WorkTargetListState();
  }
}

class _WorkTargetListState extends State<WorkTargetList> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  UnmodifiableListView<WorkTarget>? _items;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => loadWorkTargets());
  }

  Future<void> loadWorkTargets() async {
    final wtlm = context.read<WorkTargetListModel>();
    try {
      await wtlm.loadWorkTargets();
    } on AtGException catch (e) {
      if (e.message == 'loggedOut') {
        final loginModel = context.read<LoginModel>();
        if (await loginModel.tryLogin()) {
          await wtlm.loadWorkTargets();
          return;
        } else {
          Navigator.pushReplacementNamed(context, loginRoute);
        }
        // Navigator.pushReplacementNamed(context, loginRoute);
      } else {
        rethrow;
      }
    }
  }

  @override
  void didChangeDependencies() {
    // log('didChangeDependencies');
    super.didChangeDependencies();
    _refreshIndicatorKey.currentState?.show();
  }

  @override
  void didUpdateWidget(WorkTargetList widget) {
    // log('didUpdateWidget');
    super.didUpdateWidget(widget);
    // _refreshIndicatorKey.currentState?.show();
  }

  @override
  Widget build(BuildContext context) {
    // log('list build');
    context.select((WorkTargetListModel m) => m.dueDate);
    context.select((WorkTargetListModel m) => m.workGroup);
    // context.select((WorkTargetListModel m) => m.items);

    return Expanded(
        child: Column(children: [
      // buildSummary(),
      Expanded(
          child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: loadWorkTargets,
              child: Scrollbar(child: _WorkTargetListView())))
    ]));
  }

  Widget buildSummary() {
    if (_items == null) {
      return const SizedBox.shrink();
    } else if (_items!.isEmpty) {
      return Column(children: [
        const Text(
          '노는 날~? 😎😎😎',
          style: TextStyle(fontSize: 24),
        ),
        Image.asset(
          'images/day_off.png',
          height: 200,
          fit: BoxFit.contain,
        ),
      ]);
    } else {
      return Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${_items!.length}개의 작업을 찾았습니다.',
            ),
          ));
    }
  }
}

class _WorkTargetListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = context.select((WorkTargetListModel m) => m.items);

    if (items == null) {
      return const SizedBox.shrink();
    }

    if (items.isEmpty) {
      return Column(children: [
        const Text(
          '노는 날~? 😎😎😎',
          style: TextStyle(fontSize: 24),
        ),
        Image.asset(
          'images/day_off.png',
          height: 200,
          fit: BoxFit.contain,
        ),
      ]);
    }

    return ListView(
      children: _buildListItems(items),
    );

    // return Column(children: [
    //   // buildSummary(items),
    //   if (items == null) const SizedBox.shrink(),
    //   if (items != null)
    //     ListView(
    //       children: _buildListItems(items),
    //     ),
    // ]);

    // if (items == null) {
    //   return const SizedBox.shrink();
    // } else {
    //   return ListView(
    //     children: _buildListItems(items),
    //   );
    // }
  }

  List<ListTile> _buildListItems(List<WorkTarget> items) {
    List<ListTile> result = List.generate(items.length, (index) {
      final item = items[index];
      IconData icon;
      Color? color;
      switch (item.wkScd) {
        case '1': // 작업발행
          icon = Icons.today;
          color = Colors.grey;
          break;
        case '2': // 진행중
          icon = Icons.watch_later;
          color = Colors.blue;
          break;
        case '3': // 작업완료
          icon = Icons.done;
          color = Colors.green;
          break;
        case '4': // 지연완료
          icon = Icons.done;
          color = Colors.orange;
          break;
        default:
          icon = Icons.done;
          break;
      }
      return ListTile(
          leading: ExcludeSemantics(
              child: CircleAvatar(
            backgroundColor: color,
            foregroundColor: const Color(0xffffffff),
            child: Icon(icon, size: 24),
            //),
          )),
          title: Text(item.wkPlacNm,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Row(children: [
            Text(item.wkSnm, style: TextStyle(color: color)),
            if (item.wkRsltCnts.isNotEmpty) const SizedBox(width: 5),
            if (item.wkRsltCnts.isNotEmpty) Text(item.wkRsltCnts)
          ]));
    });

    return result;
  }

  Widget buildSummary(List<WorkTarget>? items) {
    if (items == null) {
      return const SizedBox.shrink();
    } else if (items.isEmpty) {
      return Column(children: [
        const Text(
          '노는 날~? 😎😎😎',
          style: TextStyle(fontSize: 24),
        ),
        Image.asset(
          'images/day_off.png',
          height: 200,
          fit: BoxFit.contain,
        ),
      ]);
    } else {
      return Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${items.length}개의 작업을 찾았습니다.',
            ),
          ));
    }
  }
}
