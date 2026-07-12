// ignore_for_file: avoid_print

import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/material.dart';

import 'house_filters_repository.dart';
import 'my_widgets.dart';

class DialogPage extends StatefulWidget {
  const DialogPage({super.key});

  @override
  State<DialogPage> createState() => _DialogPageState();
}

class _DialogPageState extends State<DialogPage> {
  late final HouseFiltersRepository _filtersRepo;

  @override
  void initState() {
    super.initState();
    _filtersRepo = HouseFiltersRepository();
  }

  void showSortSelector() async {
    final selector = ListSelector(
      dataFetcher: _filtersRepo.fetchSortBuyData,
      selectedDataFetcher: _filtersRepo.fetchSortBuySelectedData,
      resetDataFetcher: _filtersRepo.fetchSortBuyResetData,
      selectionMode: SelectionMode.single,
      radioBuilder: (context, selected) {
        return MyRadio(value: selected);
      },
    );
    final controller = SelectorController(
      selectionMode: selector.selectionMode,
      previousSelected: selector.selectedData,
      resetSelected: selector.resetData,
    );
    controller.addApplyListener((selected) {
      print('addApplyListener: ☎️ $selected');
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.red,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  controller.select('sale_time_asc');
                },
                child: Text('外部选中'),
              ),
              SelectorPanel(
                controller: controller,
                selector: selector,
                onApplyTap: (selected) {
                  print('onApplyTap ✅: $selected');
                  Navigator.of(context).pop(selected);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showFloorPlanBottomSelector() async {
    // final aa = ScrollController();
    // aa.addListener(listener)

    final selector = FlattenSelector(
      dataFetcher: _filtersRepo.fetchFloorPlanBuyData,
      selectedDataFetcher: _filtersRepo.fetchFloorPlanBuySelectedData,
      resetDataFetcher: _filtersRepo.fetchFloorPlanBuyResetData,
      selectionMode: SelectionMode.multiple,
      crossAxisCount: 3,
      childAspectRatio: 2.5,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      sideBarTheme: const SelectorSideBarTheme(width: 98),
    );
    final controller = SelectorController(
      selectionMode: selector.selectionMode,
      previousSelected: selector.selectedData,
      resetSelected: selector.resetData,
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
              selector: selector,
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
              onPressed: showSortSelector,
              child: const Text('Show SortSelector'),
            ),
            ElevatedButton(
              onPressed: showFloorPlanBottomSelector,
              child: const Text('Show FloorPlanBottomSelector'),
            ),
          ],
        ),
      ),
    );
  }
}
