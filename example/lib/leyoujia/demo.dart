import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/material.dart';

import 'house_filters_repository.dart';
import 'my_widgets.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dialog Sheet')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('区域选择器'),
            CriteriaSelector(
              delegate: CascadingSelectorDelegate(
                entriesLoader: _filtersRepo.fetchRegionData,
                selectedEntriesLoader: _filtersRepo.fetchRegionSelectedData,
                resetEntriesLoader: _filtersRepo.fetchRegionResetData,
                selectionMode: SelectionMode.single,
                radioBuilder: (context, selected) {
                  return MyRadio(value: selected);
                },
                checkboxBuilder: (context, selected) {
                  return MyCheckbox(value: selected);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
