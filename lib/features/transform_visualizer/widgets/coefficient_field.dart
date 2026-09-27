import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:matrix_engine/matrix_engine.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../models/quadratic_surd.dart';

class CoefficientField extends StatefulWidget {
  final String name;
  final QuadraticSurd exact;
  final int revision;
  final ValueChanged<QuadraticSurd> onChanged;
  const CoefficientField({
    super.key,
    required this.name,
    required this.exact,
    required this.revision,
    required this.onChanged,
  });

  /// Drawing approximation of [exact]; never displayed.
  double get value => exact.toDouble();

  static final _limit = QuadraticSurd.fromInt(1000);
  static final _step = QuadraticSurd(Rational(1, 2));
  @override
  State<CoefficientField> createState() => _CoefficientFieldState();
}

class _CoefficientFieldState extends State<CoefficientField> {
  late final TextEditingController _controller;
  final _focus = FocusNode();
  bool _invalid = false;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.exact.toString());
    _focus.addListener(_onFocus);
  }

  void _onFocus() {
    if (!_focus.hasFocus) _commit();
  }

  @override
  void didUpdateWidget(CoefficientField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exact != widget.exact ||
        oldWidget.revision != widget.revision) {
      _controller.text = widget.exact.toString();
      _invalid = false;
    }
  }

  void _commit() {
    // Untouched text, including a √2 entry the keyboard cannot type, is not
    // an edit.
    if (_controller.text == widget.exact.toString()) return;
    final value = QuadraticSurd.tryParse(_controller.text);
    final valid = value != null && value.abs() <= CoefficientField._limit;
    setState(() => _invalid = !valid);
    if (!valid) return;
    if (value == widget.exact) {
      _controller.text = value.toString();
    } else {
      widget.onChanged(value);
    }
  }

  QuadraticSurd _clamp(QuadraticSurd value) {
    final limit = CoefficientField._limit;
    if (value > limit) return limit;
    if (value < -limit) return -limit;
    return value;
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          key: ValueKey('coefficient-${widget.name}'),
          controller: _controller,
          focusNode: _focus,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          textInputAction: TextInputAction.done,
          inputFormatters: [LengthLimitingTextInputFormatter(32)],
          decoration: InputDecoration(
            labelText: widget.name,
            errorText: _invalid ? l10n.coefficientError : null,
            errorMaxLines: 4,
          ),
          onSubmitted: (_) => _commit(),
          onTapOutside: (_) => _focus.unfocus(),
          onChanged: (_) {
            if (_invalid) setState(() => _invalid = false);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: l10n.decreaseCoefficient(widget.name),
              onPressed: widget.exact > -CoefficientField._limit
                  ? () => widget.onChanged(
                      _clamp(widget.exact - CoefficientField._step),
                    )
                  : null,
              icon: const Icon(Icons.remove, size: 18),
            ),
            IconButton(
              tooltip: l10n.increaseCoefficient(widget.name),
              onPressed: widget.exact < CoefficientField._limit
                  ? () => widget.onChanged(
                      _clamp(widget.exact + CoefficientField._step),
                    )
                  : null,
              icon: const Icon(Icons.add, size: 18),
            ),
          ],
        ),
      ],
    );
  }
}
