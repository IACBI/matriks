import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix_engine/matrix_engine.dart';

import '../../step_player/views/step_player_screen.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../matrix_input/views/matrix_input_screen.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../../settings/widgets/language_menu.dart';
import '../../transform_visualizer/views/transform_visualizer_screen.dart';
import '../../practice/views/practice_screen.dart';
import '../models/topic_item.dart';
import '../widgets/topic_glyph.dart';
import '../search_fold.dart';

/// Shell destinations a catalog entry can switch to instead of opening a
/// second, independent copy of the same screen.
enum StudioSection { practice, transform }

class TopicsScreen extends StatefulWidget {
  /// Switches the shell to the practice or transform destination. Without it
  /// (a screen hosted on its own) those topics open as pushed pages.
  final ValueChanged<StudioSection>? onOpenSection;
  const TopicsScreen({super.key, this.onOpenSection});
  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  TopicCategory? _selectedCategory;
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _openTopic(TopicItem topic) {
    context.read<SettingsCubit>().openTopic(topic.type.name);
    final section = switch (topic.type) {
      TopicType.transform2d => StudioSection.transform,
      TopicType.practice => StudioSection.practice,
      _ => null,
    };
    final open = widget.onOpenSection;
    if (section != null && open != null) {
      open(section);
      return;
    }
    final Widget screen = switch (topic.type) {
      TopicType.transform2d => const TransformVisualizerScreen(),
      TopicType.practice => const PracticeScreen(),
      _ => MatrixInputScreen(topic: topic),
    };
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  void _openLesson(TopicType type) {
    final topic = TopicItem.of(type);
    final settings = context.read<SettingsCubit>()..openTopic(type.name);
    final solution = type == TopicType.linearSystems
        ? LinearSystemsSolver.solve(
            Matrix.fromInts([
              [1, 2, 5],
              [3, 4, 11],
            ]),
          )
        : GaussJordanSolver.solve(
            Matrix.fromInts([
              [1, 2, 1],
              [2, 5, 4],
              [1, 3, 3],
            ]),
            EliminationOptions(
              toRref: type == TopicType.rref,
              normalizePivotToOne: type == TopicType.rref,
            ),
          );
    final navigator = Navigator.of(context);
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => StepPlayerScreen(
          solution: solution,
          topicTitle: topic.title(AppLocalizations.of(context)!),
          workedExample: true,
          onLessonComplete: () => settings.completeTopic(type.name),
          // The finished example hands over to the editor for the same topic.
          onOwnMatrix: () => navigator.pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => MatrixInputScreen(topic: topic),
            ),
          ),
        ),
      ),
    );
  }

  void _resetFilters() => setState(() {
    _searchController.clear();
    _selectedCategory = null;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final settings = context.watch<SettingsCubit>().state;
    final compact = settings.compact;
    final query = foldForSearch(_searchController.text.trim());
    final topics = TopicItem.allTopics.where((topic) {
      final matchesCategory =
          _selectedCategory == null || topic.category == _selectedCategory;
      final searchable = foldForSearch(
        '${topic.title(l10n)} ${topic.description(l10n)} ${topic.tagText}',
      );
      return matchesCategory && (query.isEmpty || searchable.contains(query));
    }).toList()..sort((a, b) => a.pathIndex.compareTo(b.pathIndex));
    final completed = TopicItem.allTopics
        .where((t) => settings.completedTopics.contains(t.type.name))
        .length;
    final last = TopicType.values
        .where((t) => t.name == settings.lastTopic)
        .map(TopicItem.of)
        .firstOrNull;
    final browsing = query.isEmpty && _selectedCategory == null;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/branding/matriks_icon.png',
                width: 32,
                height: 32,
              ),
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Text(
                'Matriks',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          const LanguageMenu(),
          IconButton(
            tooltip: l10n.toggleTheme,
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: () => context.read<SettingsCubit>().toggleTheme(
              currentBrightness: theme.brightness,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppTheme.contentWidth),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width < 600 ? 20 : 48,
                vertical: 16,
              ),
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    l10n.selectTopic,
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.topicSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                if (browsing && last != null) ...[
                  _ContinueCard(topic: last, onOpen: () => _openTopic(last)),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: l10n.searchTopics,
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: l10n.clearSearch,
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => setState(_searchController.clear),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final category in <TopicCategory?>[
                      null,
                      ...TopicCategory.values,
                    ])
                      ChoiceChip(
                        label: Text(category.label(l10n)),
                        selected: _selectedCategory == category,
                        showCheckmark: false,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = category),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (browsing) ...[
                  // Open by default: the starter lessons are the intended
                  // first step for a new learner and were easy to miss folded.
                  ExpansionTile(
                    initiallyExpanded: true,
                    tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                    childrenPadding: const EdgeInsets.all(12),
                    leading: Icon(
                      Icons.auto_awesome_outlined,
                      color: scheme.primary,
                    ),
                    title: Text(l10n.learningPath),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton(
                              onPressed: () => _openLesson(TopicType.gauss),
                              child: Text(l10n.pathEliminate),
                            ),
                            OutlinedButton(
                              onPressed: () => _openLesson(TopicType.rref),
                              child: Text(l10n.pathReduce),
                            ),
                            OutlinedButton(
                              onPressed: () =>
                                  _openLesson(TopicType.linearSystems),
                              child: Text(l10n.pathSolve),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
                if (topics.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 36,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noTopicsFound,
                          style: theme.textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.noTopicsFoundDesc,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _resetFilters,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(l10n.clearSearch),
                        ),
                      ],
                    ),
                  )
                else ...[
                  if (browsing)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        l10n.pathProgress(
                          completed,
                          TopicItem.allTopics.length,
                        ),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  for (final topic in topics)
                    _TopicRow(
                      topic: topic,
                      compact: compact,
                      completed: settings.completedTopics.contains(
                        topic.type.name,
                      ),
                      onTap: () => _openTopic(topic),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  final TopicItem topic;
  final VoidCallback onOpen;

  const _ContinueCard({required this.topic, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      key: const ValueKey('continue-card'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TopicGlyph(type: topic.type),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.continueLearning,
                        style: theme.textTheme.labelMedium,
                      ),
                      Text(
                        topic.title(l10n),
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            FilledButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(l10n.continueAction),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicRow extends StatelessWidget {
  final TopicItem topic;
  final bool compact;
  final bool completed;
  final VoidCallback onTap;

  const _TopicRow({
    required this.topic,
    required this.compact,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final title = Row(
      children: [
        Flexible(
          child: Text(topic.title(l10n), style: theme.textTheme.titleMedium),
        ),
        if (completed) ...[
          const SizedBox(width: 8),
          Semantics(
            label: l10n.topicCompleted,
            child: Icon(
              Icons.check_circle_rounded,
              size: 18,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ],
    );
    final description = Text(
      topic.description(l10n),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
    final tag = Text(
      topic.tagText,
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        clipBehavior: Clip.antiAlias,
        color: theme.colorScheme.surface,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: compact ? 12 : 20,
              horizontal: 20,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide =
                    constraints.maxWidth >= 800 &&
                    MediaQuery.textScalerOf(context).scale(1) <= 1.3;
                return Row(
                  crossAxisAlignment: wide
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      child: Text(
                        '${topic.pathIndex + 1}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    TopicGlyph(type: topic.type),
                    const SizedBox(width: 16),
                    if (wide) ...[
                      Expanded(flex: 3, child: title),
                      const SizedBox(width: 24),
                      Expanded(flex: 5, child: description),
                      const SizedBox(width: 24),
                      SizedBox(width: 90, child: tag),
                    ] else
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            title,
                            const SizedBox(height: 4),
                            description,
                            const SizedBox(height: 8),
                            tag,
                          ],
                        ),
                      ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
