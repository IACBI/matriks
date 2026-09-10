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
  const TransformVisualizerScreen({super.key});

  @override
  State<TransformVisualizerScreen> createState() =>
      _TransformVisualizerScreenState();
}

class _TransformVisualizerScreenState extends State<TransformVisualizerScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  String? _selectedPreset = 'shear';
  double a = 1.0;
  double b = 1.0;
  double c = 0.0;
  double d = 1.0;

  late AnimationController _animController;
  late CurvedAnimation _animation;
  TransformMatrix _start = TransformMatrix.identity;
  int _coefficientRevision = 0;
  TransformMatrix get _target => TransformMatrix(a, b, c, d);
  TransformMatrix get _current => _start.interpolate(_target, _animation.value);
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
    final l10n = AppLocalizations.of(context);
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
          title: Text(l10n?.transformScreenTitle ?? '2D Linear Transformation'),
          actions: [
            IconButton(
              tooltip: l10n?.toggleTheme ?? 'Toggle Theme',
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
                            _buildPresetChip(
                              l10n?.presetShear ?? 'Shear',
                              'shear',
                            ),
                            _buildPresetChip(
                              l10n?.presetRotation ?? 'Rotation 45°',
                              'rotation',
                            ),
                            _buildPresetChip(
                              l10n?.presetScale ?? 'Scale',
                              'scale',
                            ),
                            _buildPresetChip(
                              l10n?.presetReflection ?? 'Reflection',
                              'reflection',
                            ),
                            _buildPresetChip(
                              l10n?.presetProjection ?? 'Projection (det=0)',
                              'projection',
                            ),
                            _buildPresetChip(
                              l10n?.presetReset ?? 'Reset (I)',
                              'identity',
                            ),
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
                                  l10n?.transformCoefficients ??
                                      'Transformation matrix',
                                  style: theme.textTheme.titleMedium,
                                ),
                                if (_selectedPreset == null)
                                  Text(
                                    l10n?.customTransform ?? 'Custom',
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
                                l10n?.basisVectors ??
                                    'Transformed basis vectors',
                                style: theme.textTheme.labelMedium,
                              ),
                              Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                children: [
                                  _buildBadge(
                                    label:
                                        l10n?.basisVectorI(
                                          currentA.toStringAsFixed(1),
                                          currentC.toStringAsFixed(1),
                                        ) ??
                                        'i = ($currentA, $currentC)',
                                    color: theme.colorScheme.primary,
                                  ),
                                  _buildBadge(
                                    label:
                                        l10n?.basisVectorJ(
                                          currentB.toStringAsFixed(1),
                                          currentD.toStringAsFixed(1),
                                        ) ??
                                        'j = ($currentB, $currentD)',
                                    color: AppTheme.accentGreen,
                                  ),
                                ],
                              ),
                              Text(
                                '${l10n?.targetDeterminant ?? 'Target determinant'}: ${formatCoefficient(det)}',
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
                                    ? (l10n?.pause ?? 'Pause')
                                    : (l10n?.play ?? 'Play'),
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
                                    label: l10n!.transformProgress,
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
                          child: Text(
                            l10n.transformTransitionHint,
                            style: theme.textTheme.bodySmall,
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
