import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/settings/cubit/settings_cubit.dart';
import '../../features/topics/models/topic_item.dart';

import '../../features/topics/views/topics_screen.dart';
import '../../features/practice/views/practice_screen.dart';
import '../../features/transform_visualizer/views/transform_visualizer_screen.dart';
import '../../features/settings/views/settings_screen.dart';
import '../../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';

class StudioShell extends StatefulWidget {
  const StudioShell({super.key});
  @override
  State<StudioShell> createState() => _StudioShellState();
}

class _StudioShellState extends State<StudioShell> {
  int _index = 0;
  final Set<int> _visited = {0};
  void _select(int index) {
    // Practice and Transformations are topics on the learning path; opened
    // here or from the catalog, they are where the learner left off.
    final topic = switch (index) {
      1 => TopicType.practice,
      2 => TopicType.transform2d,
      _ => null,
    };
    if (topic != null) context.read<SettingsCubit?>()?.openTopic(topic.name);
    setState(() {
      _index = index;
      _visited.add(index);
    });
  }

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
      TopicsScreen(
        onOpenSection: (section) => _select(switch (section) {
          StudioSection.practice => 1,
          StudioSection.transform => 2,
        }),
      ),
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
    // Each region is its own traversal group, so Tab finishes the rail before
    // entering the page instead of alternating between them by height.
    return Scaffold(
      body: Row(
        children: [
          if (wide)
            FocusTraversalGroup(
              child: SafeArea(
                child: NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: _select,
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/branding/matriks_icon.png',
                        width: 48,
                        height: 48,
                      ),
                    ),
                  ),
                  destinations: [
                    for (final d in destinations)
                      NavigationRailDestination(
                        icon: Icon(d.$1),
                        // Merges into the destination's node, which
                        // NavigationRail does not mark as a button; Windows
                        // UI Automation then exposes it as text that cannot
                        // be invoked.
                        label: Semantics(button: true, child: Text(d.$2)),
                      ),
                  ],
                ),
              ),
            ),
          Expanded(child: FocusTraversalGroup(child: body)),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : FocusTraversalGroup(
              child: SafeArea(
                top: false,
                child: Material(
                  color: Theme.of(context).colorScheme.surface,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < destinations.length; i++)
                        Expanded(
                          child: _BottomDestination(
                            icon: destinations[i].$1,
                            label: destinations[i].$2,
                            selected: i == _index,
                            onTap: () => _select(i),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

/// Bottom navigation item. The selected item is marked by a filled indicator
/// behind its icon and a bolder label, not by colour alone.
class _BottomDestination extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BottomDestination({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: AppTheme.motion(context),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? scheme.primary.withValues(alpha: .14)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              // A label wider than its quarter of a phone (Transformations,
              // or any label at large text) shrinks to fit on one line
              // rather than breaking inside the word.
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? scheme.onSurface
                        : scheme.onSurfaceVariant,
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
