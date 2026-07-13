// ignore_for_file: avoid_print

import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/material.dart';

import 'house_filters_repository.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  late final HouseFiltersRepository _filtersRepo;

  @override
  void initState() {
    super.initState();
    _filtersRepo = HouseFiltersRepository();
  }

  void showFloorPlanBottomSelector() async {
    // final aa = ScrollController();
    // aa.addListener(listener)

    final delegate = FlattenSelectorDelegate(
      entriesLoader: _filtersRepo.fetchFloorPlanBuyData,
      selectedEntriesLoader: _filtersRepo.fetchFloorPlanBuySelectedData,
      resetEntriesLoader: _filtersRepo.fetchFloorPlanBuyResetData,
      selectionMode: SelectionMode.multiple,
      crossAxisCount: 3,
      childAspectRatio: 2.5,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      sideBarTheme: const SelectorSideBarTheme(width: 98),
    );
    final controller = SelectorController(
      selectionMode: delegate.selectionMode,
      previousSelected: delegate.selectedData,
      resetSelected: delegate.resetData,
    );
    controller.addChangeListener((selected) {
      print('Changed: ☎️ $selected');
    });
    controller.addApplyListener((selected) {
      print('Applied: ☎️ $selected');
    });
    controller.addResetListener(() {
      print('Reset ☎️');
    });

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: SelectorPanel(
              controller: controller,
              delegate: delegate,
              onChangeTap: (selected) {
                print('onChangeTap ✅: $selected');
              },
              onApplyTap: (selected) {
                print('onApplyTap ✅: $selected');
                Navigator.of(context).pop(selected);
              },
              onResetTap: () {
                print('onResetTap ✅');
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dialog Sheet')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: showFloorPlanBottomSelector,
              child: const Text('Show Sort Selector'),
            ),
            ElevatedButton(
              onPressed: showFloorPlanBottomSelector,
              child: const Text('Show FloorPlan Selector'),
            ),
          ],
        ),
      ),
    );
  }
}
