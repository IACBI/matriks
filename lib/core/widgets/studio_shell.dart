import 'package:flutter/material.dart';

import '../../features/topics/views/topics_screen.dart';
import '../../features/practice/views/practice_screen.dart';
import '../../features/transform_visualizer/views/transform_visualizer_screen.dart';
import '../../features/settings/views/settings_screen.dart';
import '../../l10n/generated/app_localizations.dart';

class StudioShell extends StatefulWidget {
  const StudioShell({super.key});
  @override
  State<StudioShell> createState() => _StudioShellState();
}

class _StudioShellState extends State<StudioShell> {
  int _index = 0;
  final Set<int> _visited = {0};
  void _select(int index) => setState(() {
    _index = index;
    _visited.add(index);
  });
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final destinations = [
      (Icons.grid_view_rounded, l.topics),
      (Icons.school_outlined, l.practiceNav),
      (Icons.transform_rounded, l.transformNav),
      (Icons.tune_rounded, l.settings),
    ];
    final media = MediaQuery.of(context);
    final wide = media.size.width >= 960 && media.textScaler.scale(1) <= 1.5;
    final pages = <Widget>[
      const TopicsScreen(),
      PracticeScreen(onReturnTopics: () => _select(0)),
      const TransformVisualizerScreen(),
      const SettingsScreen(),
    ];
    final body = IndexedStack(
      index: _index,
      children: [
        for (var i = 0; i < pages.length; i++)
          TickerMode(
            enabled: i == _index,
            child: _visited.contains(i) ? pages[i] : const SizedBox.shrink(),
          ),
      ],
    );
    return Scaffold(
      body: Row(
        children: [
          if (wide)
            SafeArea(
              child: NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: _select,
                labelType: NavigationRailLabelType.all,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/branding/matriks.png',
                      width: 48,
                      height: 48,
                    ),
                  ),
                ),
                destinations: [
                  for (final d in destinations)
                    NavigationRailDestination(
                      icon: Icon(d.$1),
                      label: Text(d.$2),
                    ),
                ],
              ),
            ),
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : SafeArea(
              top: false,
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < destinations.length; i++)
                      Expanded(
                        child: Semantics(
                          selected: i == _index,
                          child: InkWell(
                            onTap: () => _select(i),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 10,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    destinations[i].$1,
                                    color: i == _index
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    destinations[i].$2,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
