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
import '../search_fold.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});
  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  String _selectedCategory = 'categoryAll';
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _openTopic(TopicItem topic) {
    final Widget screen = switch (topic.type) {
      TopicType.transform2d => const TransformVisualizerScreen(),
      TopicType.practice => const PracticeScreen(),
      _ => MatrixInputScreen(topic: topic),
    };
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  void _openLesson(TopicType type) {
    final topic = TopicItem.allTopics.firstWhere((topic) => topic.type == type);
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
    final title = _resolveTopicTitle(
      AppLocalizations.of(context),
      topic.titleKey,
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StepPlayerScreen(
          solution: solution,
          topicTitle: title,
          workedExample: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final query = foldForSearch(_searchController.text.trim());
    const categories = [
      'categoryAll',
      'categoryElimination',
      'categoryAlgebra',
      'categoryAdvanced',
      'categoryVisual',
    ];
    final topics = TopicItem.allTopics.where((topic) {
      final matchesCategory =
          _selectedCategory == 'categoryAll' ||
          topic.categoryKey == _selectedCategory;
      final searchable = foldForSearch(
        '${_resolveTopicTitle(l10n, topic.titleKey)} '
        '${_resolveTopicDesc(l10n, topic.descKey)} ${topic.tagText}',
      );
      return matchesCategory && (query.isEmpty || searchable.contains(query));
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/branding/matriks.png',
                width: 32,
                height: 32,
              ),
            ),
            SizedBox(width: 10),
            Flexible(
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
          IconButton(
            tooltip: l10n?.searchTopics ?? 'Search topics',
            icon: const Icon(Icons.search_rounded),
            onPressed: _searchFocus.requestFocus,
          ),
          const LanguageMenu(),
          IconButton(
            tooltip: l10n?.toggleTheme ?? 'Toggle Theme',
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
                    l10n?.selectTopic ?? 'Select a Linear Algebra Topic',
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n?.topicSubtitle ?? 'Learn step-by-step with interactive, animated solutions.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: l10n?.searchTopics ?? 'Search topics...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: l10n?.clearSearch ?? 'Clear Search',
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => setState(_searchController.clear),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories
                      .map(
                        (key) => ChoiceChip(
                          label: Text(_resolveCategoryTitle(l10n, key)),
                          selected: _selectedCategory == key,
                          showCheckmark: false,
                          onSelected: (_) =>
                              setState(() => _selectedCategory = key),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                if (query.isEmpty && _selectedCategory == 'categoryAll') ...[
                  ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                    childrenPadding: const EdgeInsets.all(12),
                    leading: Icon(
                      Icons.auto_awesome_outlined,
                      color: scheme.primary,
                    ),
                    title: Text(l10n?.learningPath ?? 'New to matrices?'),
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton(
                            onPressed: () => _openLesson(TopicType.gauss),
                            child: Text(
                              l10n?.pathEliminate ?? '1 · Create zeros',
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () => _openLesson(TopicType.rref),
                            child: Text(
                              l10n?.pathReduce ?? '2 · Find the pivots',
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () =>
                                _openLesson(TopicType.linearSystems),
                            child: Text(
                              l10n?.pathSolve ?? '3 · Solve a system',
                            ),
                          ),
                        ],
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
                          l10n?.noTopicsFound ?? 'No matching topics found',
                          style: theme.textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n?.noTopicsFoundDesc ??
                              'Try another keyword or category.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => setState(() {
                            _searchController.clear();
                            _selectedCategory = 'categoryAll';
                          }),
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(l10n?.clearSearch ?? 'Clear Search'),
                        ),
                      ],
                    ),
                  )
                else
                  ...topics.map(
                    (topic) => _buildTopicRow(context, topic, l10n),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicRow(
    BuildContext context,
    TopicItem topic,
    AppLocalizations? l10n,
  ) {
    final theme = Theme.of(context);
    final title = Text(
      _resolveTopicTitle(l10n, topic.titleKey),
      style: theme.textTheme.titleMedium,
    );
    final description = Text(
      _resolveTopicDesc(l10n, topic.descKey),
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
          onTap: () => _openTopic(topic),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: context.watch<SettingsCubit>().state.compact ? 12 : 20,
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
                    Icon(
                      topic.icon,
                      color: theme.colorScheme.primary,
                      size: 26,
                    ),
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

  String _resolveCategoryTitle(AppLocalizations? l10n, String key) {
    if (l10n == null) return key;
    switch (key) {
      case 'categoryAll':
        return l10n.categoryAll;
      case 'categoryElimination':
        return l10n.categoryElimination;
      case 'categoryAlgebra':
        return l10n.categoryAlgebra;
      case 'categoryAdvanced':
        return l10n.categoryAdvanced;
      case 'categoryVisual':
        return l10n.categoryVisual;
      default:
        return key;
    }
  }

  String _resolveTopicTitle(AppLocalizations? l10n, String key) {
    if (l10n == null) return key;
    switch (key) {
      case 'topicGauss':
        return l10n.topicGauss;
      case 'topicRref':
        return l10n.topicRref;
      case 'topicLinearSystems':
        return l10n.topicLinearSystems;
      case 'topicDeterminant':
        return l10n.topicDeterminant;
      case 'topicInverse':
        return l10n.topicInverse;
      case 'topicRankNullity':
        return l10n.topicRankNullity;
      case 'topicEigen':
        return l10n.topicEigen;
      case 'topicLu':
        return l10n.topicLu;
      case 'topicPractice':
        return l10n.topicPractice;
      case 'topicTransform2d':
        return l10n.topicTransform2d;
      case 'topicAdd':
        return l10n.topicAdd;
      case 'topicMultiply':
        return l10n.topicMultiply;
      default:
        return key;
    }
  }

  String _resolveTopicDesc(AppLocalizations? l10n, String key) {
    if (l10n == null) return key;
    switch (key) {
      case 'topicGaussDesc':
        return l10n.topicGaussDesc;
      case 'topicRrefDesc':
        return l10n.topicRrefDesc;
      case 'topicLinearSystemsDesc':
        return l10n.topicLinearSystemsDesc;
      case 'topicDeterminantDesc':
        return l10n.topicDeterminantDesc;
      case 'topicInverseDesc':
        return l10n.topicInverseDesc;
      case 'topicRankNullityDesc':
        return l10n.topicRankNullityDesc;
      case 'topicEigenDesc':
        return l10n.topicEigenDesc;
      case 'topicLuDesc':
        return l10n.topicLuDesc;
      case 'topicPracticeDesc':
        return l10n.topicPracticeDesc;
      case 'topicTransform2dDesc':
        return l10n.topicTransform2dDesc;
      case 'topicAddDesc':
        return l10n.topicAddDesc;
      case 'topicMultiplyDesc':
        return l10n.topicMultiplyDesc;
      default:
        return key;
    }
  }
}
