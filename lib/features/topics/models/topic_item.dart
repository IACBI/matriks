import 'package:flutter/material.dart';

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

class TopicItem {
  final TopicType type;
  final String titleKey;
  final String descKey;
  final String categoryKey;
  final String tagText;
  final IconData icon;
  final Color color;
  final bool requiresSquare;
  final bool isDualMatrix;
  final bool isAugmentedSystem;

  const TopicItem({
    required this.type,
    required this.titleKey,
    required this.descKey,
    required this.categoryKey,
    required this.tagText,
    required this.icon,
    required this.color,
    this.requiresSquare = false,
    this.isDualMatrix = false,
    this.isAugmentedSystem = false,
  });

  static const List<TopicItem> allTopics = [
    TopicItem(
      type: TopicType.rref,
      titleKey: 'topicRref',
      descKey: 'topicRrefDesc',
      categoryKey: 'categoryElimination',
      tagText: 'RREF',
      icon: Icons.table_rows_rounded,
      color: Color(0xFF2563EB),
    ),
    TopicItem(
      type: TopicType.gauss,
      titleKey: 'topicGauss',
      descKey: 'topicGaussDesc',
      categoryKey: 'categoryElimination',
      tagText: 'REF',
      icon: Icons.trending_down_rounded,
      color: Color(0xFF0EA5E9),
    ),
    TopicItem(
      type: TopicType.linearSystems,
      titleKey: 'topicLinearSystems',
      descKey: 'topicLinearSystemsDesc',
      categoryKey: 'categoryElimination',
      tagText: 'Ax = b',
      icon: Icons.account_tree_rounded,
      color: Color(0xFF6366F1),
      isAugmentedSystem: true,
    ),
    TopicItem(
      type: TopicType.determinant,
      titleKey: 'topicDeterminant',
      descKey: 'topicDeterminantDesc',
      categoryKey: 'categoryAlgebra',
      tagText: 'det(A)',
      icon: Icons.grid_view_rounded,
      color: Color(0xFFF59E0B),
      requiresSquare: true,
    ),
    TopicItem(
      type: TopicType.inverse,
      titleKey: 'topicInverse',
      descKey: 'topicInverseDesc',
      categoryKey: 'categoryAlgebra',
      tagText: 'A⁻¹',
      icon: Icons.swap_horiz_rounded,
      color: Color(0xFF8B5CF6),
      requiresSquare: true,
    ),
    TopicItem(
      type: TopicType.rankNullity,
      titleKey: 'topicRankNullity',
      descKey: 'topicRankNullityDesc',
      categoryKey: 'categoryAdvanced',
      tagText: 'Rank',
      icon: Icons.bar_chart_rounded,
      color: Color(0xFF14B8A6),
    ),
    TopicItem(
      type: TopicType.eigen,
      titleKey: 'topicEigen',
      descKey: 'topicEigenDesc',
      categoryKey: 'categoryAdvanced',
      tagText: 'λ, v',
      icon: Icons.all_inclusive_rounded,
      color: Color(0xFFD946EF),
      requiresSquare: true,
    ),
    TopicItem(
      type: TopicType.lu,
      titleKey: 'topicLu',
      descKey: 'topicLuDesc',
      categoryKey: 'categoryAdvanced',
      tagText: 'A = LU',
      icon: Icons.splitscreen_rounded,
      color: Color(0xFF0284C7),
      requiresSquare: true,
    ),
    TopicItem(
      type: TopicType.practice,
      titleKey: 'topicPractice',
      descKey: 'topicPracticeDesc',
      categoryKey: 'categoryVisual',
      tagText: 'Quiz',
      icon: Icons.psychology_rounded,
      color: Color(0xFFE11D48),
    ),
    TopicItem(
      type: TopicType.transform2d,
      titleKey: 'topicTransform2d',
      descKey: 'topicTransform2dDesc',
      categoryKey: 'categoryVisual',
      tagText: '2D Geom',
      icon: Icons.aspect_ratio_rounded,
      color: Color(0xFFF97316),
      requiresSquare: true,
    ),
    TopicItem(
      type: TopicType.add,
      titleKey: 'topicAdd',
      descKey: 'topicAddDesc',
      categoryKey: 'categoryAlgebra',
      tagText: 'A + B',
      icon: Icons.add_circle_outline_rounded,
      color: Color(0xFF10B981),
      isDualMatrix: true,
    ),
    TopicItem(
      type: TopicType.multiply,
      titleKey: 'topicMultiply',
      descKey: 'topicMultiplyDesc',
      categoryKey: 'categoryAlgebra',
      tagText: 'A × B',
      icon: Icons.close_rounded,
      color: Color(0xFFEC4899),
      isDualMatrix: true,
    ),
  ];
}
