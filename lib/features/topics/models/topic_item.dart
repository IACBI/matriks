import '../../../l10n/generated/app_localizations.dart';

enum TopicType {
  gauss,
  rref,
  linearSystems,
  determinant,
  inverse,
  rankNullity,
  eigen,
  lu,
  transform2d,
  practice,
  add,
  multiply,
}

enum TopicCategory { elimination, algebra, advanced, visual }

class TopicItem {
  final TopicType type;
  final TopicCategory category;
  final String tagText;
  final bool requiresSquare;
  final bool isDualMatrix;
  final bool isAugmentedSystem;

  const TopicItem({
    required this.type,
    required this.category,
    required this.tagText,
    this.requiresSquare = false,
    this.isDualMatrix = false,
    this.isAugmentedSystem = false,
  });

  /// Localized title. The switch is exhaustive, so adding a topic without a
  /// title is a compile error rather than a raw key on screen.
  String title(AppLocalizations l) => switch (type) {
    TopicType.gauss => l.topicGauss,
    TopicType.rref => l.topicRref,
    TopicType.linearSystems => l.topicLinearSystems,
    TopicType.determinant => l.topicDeterminant,
    TopicType.inverse => l.topicInverse,
    TopicType.rankNullity => l.topicRankNullity,
    TopicType.eigen => l.topicEigen,
    TopicType.lu => l.topicLu,
    TopicType.transform2d => l.topicTransform2d,
    TopicType.practice => l.topicPractice,
    TopicType.add => l.topicAdd,
    TopicType.multiply => l.topicMultiply,
  };

  String description(AppLocalizations l) => switch (type) {
    TopicType.gauss => l.topicGaussDesc,
    TopicType.rref => l.topicRrefDesc,
    TopicType.linearSystems => l.topicLinearSystemsDesc,
    TopicType.determinant => l.topicDeterminantDesc,
    TopicType.inverse => l.topicInverseDesc,
    TopicType.rankNullity => l.topicRankNullityDesc,
    TopicType.eigen => l.topicEigenDesc,
    TopicType.lu => l.topicLuDesc,
    TopicType.transform2d => l.topicTransform2dDesc,
    TopicType.practice => l.topicPracticeDesc,
    TopicType.add => l.topicAddDesc,
    TopicType.multiply => l.topicMultiplyDesc,
  };

  static TopicItem of(TopicType type) =>
      allTopics.firstWhere((topic) => topic.type == type);

  /// Suggested order: each topic uses only ideas from the ones before it.
  /// Entry-wise operations first, then elimination, then what elimination
  /// makes possible, and finally geometry and review.
  static const pathOrder = [
    TopicType.add,
    TopicType.multiply,
    TopicType.gauss,
    TopicType.rref,
    TopicType.linearSystems,
    TopicType.determinant,
    TopicType.inverse,
    TopicType.rankNullity,
    TopicType.lu,
    TopicType.eigen,
    TopicType.transform2d,
    TopicType.practice,
  ];

  /// Position in [pathOrder], from 0.
  int get pathIndex => pathOrder.indexOf(type);

  static const List<TopicItem> allTopics = [
    TopicItem(
      type: TopicType.rref,
      category: TopicCategory.elimination,
      tagText: 'RREF',
    ),
    TopicItem(
      type: TopicType.gauss,
      category: TopicCategory.elimination,
      tagText: 'REF',
    ),
    TopicItem(
      type: TopicType.linearSystems,
      category: TopicCategory.elimination,
      tagText: 'Ax = b',
      isAugmentedSystem: true,
    ),
    TopicItem(
      type: TopicType.determinant,
      category: TopicCategory.algebra,
      tagText: 'det(A)',
      requiresSquare: true,
    ),
    TopicItem(
      type: TopicType.inverse,
      category: TopicCategory.algebra,
      tagText: 'A⁻¹',
      requiresSquare: true,
    ),
    TopicItem(
      type: TopicType.rankNullity,
      category: TopicCategory.advanced,
      tagText: 'Rank',
    ),
    TopicItem(
      type: TopicType.eigen,
      category: TopicCategory.advanced,
      tagText: 'λ, v',
      requiresSquare: true,
    ),
    TopicItem(
      type: TopicType.lu,
      category: TopicCategory.advanced,
      tagText: 'A = LU',
      requiresSquare: true,
    ),
    TopicItem(
      type: TopicType.practice,
      category: TopicCategory.visual,
      tagText: 'Quiz',
    ),
    TopicItem(
      type: TopicType.transform2d,
      category: TopicCategory.visual,
      tagText: '2D Geom',
    ),
    TopicItem(
      type: TopicType.add,
      category: TopicCategory.algebra,
      tagText: 'A + B',
      isDualMatrix: true,
    ),
    TopicItem(
      type: TopicType.multiply,
      category: TopicCategory.algebra,
      tagText: 'A × B',
      isDualMatrix: true,
    ),
  ];
}

extension TopicCategoryText on TopicCategory? {
  /// `null` stands for "all categories" in the catalog filter.
  String label(AppLocalizations l) => switch (this) {
    null => l.categoryAll,
    TopicCategory.elimination => l.categoryElimination,
    TopicCategory.algebra => l.categoryAlgebra,
    TopicCategory.advanced => l.categoryAdvanced,
    TopicCategory.visual => l.categoryVisual,
  };
}
