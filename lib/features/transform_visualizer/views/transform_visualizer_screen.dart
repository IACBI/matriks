import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../widgets/transform_grid_painter.dart';
import '../widgets/coefficient_field.dart';
import '../models/transform_matrix.dart';

class TransformVisualizerScreen extends StatefulWidget {
  /// Opens with this matrix instead of the shear preset, for example from a
  /// 2×2 eigen result.
  final TransformMatrix? initial;

  const TransformVisualizerScreen({super.key, this.initial});

  @override
  State<TransformVisualizerScreen> createState() =>
      _TransformVisualizerScreenState();
}

class _TransformVisualizerScreenState extends State<TransformVisualizerScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late String? _selectedPreset = widget.initial == null ? 'shear' : null;
  late double a = widget.initial?.a ?? 1.0;
  late double b = widget.initial?.b ?? 1.0;
  late double c = widget.initial?.c ?? 0.0;
  late double d = widget.initial?.d ?? 1.0;

  late AnimationController _animController;
  late CurvedAnimation _animation;
  TransformMatrix _start = TransformMatrix.identity;
  int _coefficientRevision = 0;
  TransformMatrix get _target => TransformMatrix(a, b, c, d);
  TransformMatrix get _current => _start.interpolate(_target, _animation.value);

  /// Units from the centre to the shorter canvas edge. Taken from both ends
  /// of the animation so the view stays still while the grid moves, and wide
  /// enough that a large coefficient does not leave the canvas empty.
  double get _viewRadius {
    double reach(TransformMatrix m) =>
        math.max(m.a.abs() + m.b.abs(), m.c.abs() + m.d.abs());
    return math.max(3.5, 1.4 * math.max(reach(_start), reach(_target)));
  }

  /// Unit directions (canvas orientation, y down) of the target's real
  /// eigenvectors. None for complex eigenvalues or a multiple of the
  /// identity, where every direction qualifies.
  List<Offset> get _eigenDirections {
    final t = _target;
    if (t.b.abs() < 1e-9 && t.c.abs() < 1e-9 && (t.a - t.d).abs() < 1e-9) {
      return const [];
    }
    final trace = t.a + t.d;
    final disc = trace * trace - 4 * t.determinant;
    if (disc < -1e-12) return const [];
    final root = math.sqrt(math.max(disc, 0));
    final directions = <Offset>[];
    for (final lambda in {(trace + root) / 2, (trace - root) / 2}) {
      var v = Offset(t.b, lambda - t.a);
      if (v.distance < 1e-9) v = Offset(lambda - t.d, t.c);
      if (v.distance < 1e-9) continue;
      final unit = Offset(v.dx, -v.dy) / v.distance;
      if (directions.every(
        (u) => (u.dx * unit.dy - u.dy * unit.dx).abs() > 1e-6,
      )) {
        directions.add(unit);
      }
    }
    return directions;
  }

  static String _short(double value) => value
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Muting a ticker alone still counts elapsed time while the page is hidden.
    if (!TickerMode.valuesOf(context).enabled) _animController.stop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && _animController.isAnimating) {
      setState(() => _animController.stop());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    _animation.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _playAnimation() {
    // Watching a transformation completes this topic on the learning path.
    context.read<SettingsCubit?>()?.completeTopic('transform2d');
    if (MediaQuery.disableAnimationsOf(context)) {
      setState(
        () => _animController.value = _animController.value == 1 ? 0 : 1,
      );
      return;
    }
    setState(() {
      if (_animController.isAnimating) {
        _animController.stop();
      } else if (_animController.isCompleted ||
          _animController.status == AnimationStatus.reverse) {
        _animController.reverse();
      } else {
        _animController.forward();
      }
    });
  }

  void _applyPreset(String name) {
    final target = TransformMatrix.preset(name);
    _changeTarget(target, preset: name);
  }

  void _changeTarget(TransformMatrix target, {String? preset}) {
    final visible = _current;
    _animController.stop();
    setState(() {
      _start = visible;
      a = target.a;
      b = target.b;
      c = target.c;
      d = target.d;
      _selectedPreset = preset;
      if (preset != null) _coefficientRevision++;
    });
    _animateTransform();
  }

  void _animateTransform() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _animController.value = 1;
    } else {
      _animController.forward(from: 0);
    }
  }

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.space) {
      _playAnimation();
    } else if (key == LogicalKeyboardKey.keyR) {
      _applyPreset('identity');
    } else if (key == LogicalKeyboardKey.keyS) {
      _applyPreset('shear');
    } else if (key == LogicalKeyboardKey.keyP) {
      _applyPreset('projection');
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final det = (a * d) - (b * c);

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (!node.hasPrimaryFocus) return KeyEventResult.ignored;
        return _handleKeyEvent(event);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.transformScreenTitle),
          actions: [
            IconButton(
              tooltip: l10n.toggleTheme,
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              ),
              onPressed: () => context.read<SettingsCubit>().toggleTheme(
                currentBrightness: theme.brightness,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape =
                  MediaQuery.of(context).orientation == Orientation.landscape;
              final isMobileLandscape =
                  isLandscape && constraints.maxHeight < 480;

              Widget buildCanvas() {
                return Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.surfaceDark
                        : AppTheme.scaffoldLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(
                      color: isDark
                          ? AppTheme.borderDark
                          : AppTheme.borderLight,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        final current = _current;
                        return RepaintBoundary(
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: TransformGridPainter(
                              a: current.a,
                              b: current.b,
                              c: current.c,
                              d: current.d,
                              isDark: isDark,
                              textScale: MediaQuery.textScalerOf(context)
                                  .scale(1),
                              viewRadius: _viewRadius,
                              // Same colours as the basis vector labels.
                              iColor: theme.colorScheme.primary,
                              jColor: AppTheme.accentGreen,
                              eigenDirections: _eigenDirections,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }

              Widget buildControls() {
                return AnimatedBuilder(
                  animation: _animation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Presets row
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 6.0,
                        ),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildPresetChip(l10n.presetShear, 'shear'),
                            _buildPresetChip(l10n.presetRotation, 'rotation'),
                            _buildPresetChip(l10n.presetScale, 'scale'),
                            _buildPresetChip(
                              l10n.presetReflection,
                              'reflection',
                            ),
                            _buildPresetChip(
                              l10n.presetProjection,
                              'projection',
                            ),
                            _buildPresetChip(l10n.presetReset, 'identity'),
                          ],
                        ),
                      ),

                      // 2x2 Matrix numeric editor
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.surfaceVariantDark
                              : Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                          border: Border.all(
                            color: isDark
                                ? AppTheme.borderDark
                                : AppTheme.borderLight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  l10n.transformCoefficients,
                                  style: theme.textTheme.titleMedium,
                                ),
                                if (_selectedPreset == null)
                                  Text(
                                    l10n.customTransform,
                                    style: theme.textTheme.labelMedium,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildCellControl(
                                    'a',
                                    a,
                                    (v) => _changeTarget(
                                      TransformMatrix(v, b, c, d),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildCellControl(
                                    'b',
                                    b,
                                    (v) => _changeTarget(
                                      TransformMatrix(a, v, c, d),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildCellControl(
                                    'c',
                                    c,
                                    (v) => _changeTarget(
                                      TransformMatrix(a, b, v, d),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildCellControl(
                                    'd',
                                    d,
                                    (v) => _changeTarget(
                                      TransformMatrix(a, b, c, v),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  builder: (context, child) {
                    final current = _current;
                    final currentA = current.a;
                    final currentB = current.b;
                    final currentC = current.c;
                    final currentD = current.d;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.basisVectors,
                                style: theme.textTheme.labelMedium,
                              ),
                              Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                children: [
                                  _buildBadge(
                                    label: l10n.basisVectorI(
                                      _short(currentA),
                                      _short(currentC),
                                    ),
                                    color: theme.colorScheme.primary,
                                  ),
                                  _buildBadge(
                                    label: l10n.basisVectorJ(
                                      _short(currentB),
                                      _short(currentD),
                                    ),
                                    color: AppTheme.accentGreen,
                                  ),
                                ],
                              ),
                              Text(
                                '${l10n.targetDeterminant}: ${formatCoefficient(det)}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Slider & Play/Pause controls
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              IconButton(
                                tooltip: _animController.isAnimating
                                    ? (l10n.pause)
                                    : (l10n.play),
                                onPressed: _playAnimation,
                                icon: Icon(
                                  _animController.isAnimating
                                      ? Icons.pause_circle_filled_rounded
                                      : Icons.play_circle_fill_rounded,
                                  size: 36,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                    inactiveTrackColor: isDark
                                        ? AppTheme.borderDark
                                        : AppTheme.borderLight,
                                    thumbColor: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                  child: Semantics(
                                    label: l10n.transformProgress,
                                    child: Slider(
                                      semanticFormatterCallback: (value) =>
                                          l10n.progressPercent(
                                            (value * 100).round(),
                                          ),
                                      value: _animController.value,
                                      min: 0.0,
                                      max: 1.0,
                                      onChanged: (val) {
                                        _animController.stop();
                                        _animController.value = val;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                l10n.progressPercent(
                                  (_animController.value * 100).round(),
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        child!,
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.transformLegendOriginal,
                                style: theme.textTheme.bodySmall,
                              ),
                              if (_eigenDirections.isNotEmpty)
                                Text(
                                  l10n.transformLegendEigen,
                                  style: theme.textTheme.bodySmall,
                                ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.transformTransitionHint,
                                style: theme.textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.transformShortcutsHint,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              }

              if ((constraints.maxWidth >= 960 ||
                      (constraints.maxWidth >= 600 && isMobileLandscape)) &&
                  MediaQuery.textScalerOf(context).scale(1) <= 1.5) {
                return Row(
                  children: [
                    Expanded(flex: 5, child: buildCanvas()),
                    VerticalDivider(
                      width: 1,
                      color: isDark
                          ? AppTheme.borderDark
                          : AppTheme.borderLight,
                    ),
                    Expanded(
                      flex: 4,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: buildControls(),
                      ),
                    ),
                  ],
                );
              }

              // Keep the operation visible while reaching presets on phones.
              // Short screens and large text retain the full scrolling layout.
              if (constraints.maxHeight >= 500 &&
                  MediaQuery.textScalerOf(context).scale(1) <= 1.5) {
                return Column(
                  children: [
                    SizedBox(
                      height: (constraints.maxHeight * .4).clamp(200.0, 320.0),
                      child: buildCanvas(),
                    ),
                    Expanded(
                      child: SingleChildScrollView(child: buildControls()),
                    ),
                  ],
                );
              }

              return ListView(
                children: [
                  SizedBox(
                    height: constraints.maxWidth.clamp(260.0, 460.0),
                    child: buildCanvas(),
                  ),
                  buildControls(),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
    );
  }

  Widget _buildPresetChip(String title, String name) {
    return ChoiceChip(
      label: Text(title),
      selected: _selectedPreset == name,
      onSelected: (_) => _applyPreset(name),
    );
  }

  Widget _buildCellControl(
    String name,
    double val,
    ValueChanged<double> onChanged,
  ) => CoefficientField(
    name: name,
    value: val,
    revision: _coefficientRevision,
    onChanged: onChanged,
  );
}
