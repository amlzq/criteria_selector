import 'package:flutter/material.dart';

import '../constants.dart';
import '../selector.dart';
import '../selector_entry.dart';
import 'selector_controller.dart';
import 'selector_theme.dart';
import 'selector_theme_data.dart';

/// Content widget rendered inside the dropselect overlay.
///
/// This widget:
/// - Creates a [SelectorController] and exposes it via [SelectorControllerProvider].
/// - Applies [selectorTheme] via [SelectorTheme] for selector widgets.
/// - Awaits [Selector.data] (typically assigned before showing the overlay) and
///   renders the selector body or skeleton accordingly.
///
/// Selection events are forwarded through [onChangeTap], [onApplyTap], and
/// [onResetTap] by the underlying selector views.
class SelectorPanel extends StatefulWidget {
  const SelectorPanel({
    super.key,
    required this.selector,
    this.onChangeTap,
    this.onApplyTap,
    this.onResetTap,
    this.selectorTheme,
  });

  final Selector selector;

  final SelectorCallback? onChangeTap;
  final SelectorCallback? onApplyTap;
  final VoidCallback? onResetTap;

  final SelectorThemeData? selectorTheme;

  @override
  State<SelectorPanel> createState() => _SelectorPanelState();
}

class _SelectorPanelState extends State<SelectorPanel> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = SelectorController(
      selector: widget.selector,
      changeCallback: widget.onChangeTap,
      applyCallback: widget.onApplyTap,
      resetCallback: widget.onResetTap,
    );

    return SelectorTheme(
      data:
          widget.selectorTheme ?? SelectorThemeData.fallback(Theme.of(context)),
      child: ColoredBox(
        color: SelectorTheme.of(context).backgroundColor,
        child: FutureBuilder<SelectorEntries>(
          future: widget.selector.data,
          builder: (context, snapshot) {
            debugPrint('selector data state ${snapshot.connectionState}');
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                // Request failed: show error
                return Text("Error: ${snapshot.error}");
              } else {
                // return controller.selector.buildSkeleton(context);

                // Request succeeded: show data
                final entries = snapshot.data?.toList() ?? <SelectorEntry>[];
                // final controller = SelectorController(
                //   selector: widget.selector,
                //   changeCallback: widget.onChangeTap,
                //   applyCallback: widget.onApplyTap,
                //   resetCallback: widget.onResetTap,
                // );
                debugPrint('entries length: ${entries.length}');
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    debugPrint('selector taped');
                    // Unfocus the current focus scope if needed
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus &&
                        currentFocus.focusedChild != null) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    }
                    // FocusScope.of(context).unfocus();
                  },
                  child: SelectorControllerProvider(
                    controller: controller,
                    child: SelectorTheme(
                      data: widget.selectorTheme ??
                          SelectorThemeData.fallback(Theme.of(context)),
                      child: controller.selector.buildBody(
                          context, entries, controller.previousSelected),
                    ),
                    // controller.selector.builder != null
                    //     ? controller.selector.builder!.call(
                    //         context,
                    //         controller.selector.asyncData,
                    //         controller,
                    //       )
                    //     : switch (controller.selector.layoutMode) {
                    //         SelectorLayoutMode.cascading => CascadingSelectorView(
                    //             entries: entries,
                    //             previousSelected: controller.previousSelected),
                    //         SelectorLayoutMode.grid => GridSelectorView(
                    //             entries: entries,
                    //             previousSelected: controller.previousSelected),
                    //         SelectorLayoutMode.flatten => FlattenSelectorView(
                    //             entries: entries,
                    //             previousSelected: controller.previousSelected),
                    //         SelectorLayoutMode.list => ListSelectorView(
                    //             entries: entries,
                    //             previousSelected: controller.previousSelected),
                    //         // _ => const Placeholder(),
                    //       },
                  ),
                );
              }
            } else {
              // Request in progress: show loading
              return controller.selector.buildSkeleton(context);
            }
          },
        ),
      ),
    );
  }
}
