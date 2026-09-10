import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../models/transform_matrix.dart';

class CoefficientField extends StatefulWidget {
  final String name;
  final double value;
  final int revision;
  final ValueChanged<double> onChanged;
  const CoefficientField({
    super.key,
    required this.name,
    required this.value,
    required this.revision,
    required this.onChanged,
  });
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
    _controller = TextEditingController(text: formatCoefficient(widget.value));
    _focus.addListener(_onFocus);
  }

  void _onFocus() {
    if (!_focus.hasFocus) _commit();
  }

  @override
  void didUpdateWidget(CoefficientField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value ||
        oldWidget.revision != widget.revision) {
      _controller.text = formatCoefficient(widget.value);
      _invalid = false;
    }
  }

  void _commit() {
    if (_controller.text == formatCoefficient(widget.value)) return;
    final value = double.tryParse(_controller.text.trim().replaceAll(',', '.'));
    final valid = value != null && value.isFinite && value.abs() <= 1000;
    setState(() => _invalid = !valid);
    if (valid) widget.onChanged(value);
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
              onPressed: widget.value > -1000
                  ? () =>
                        widget.onChanged((widget.value - .5).clamp(-1000, 1000))
                  : null,
              icon: const Icon(Icons.remove, size: 18),
            ),
            IconButton(
              tooltip: l10n.increaseCoefficient(widget.name),
              onPressed: widget.value < 1000
                  ? () =>
                        widget.onChanged((widget.value + .5).clamp(-1000, 1000))
                  : null,
              icon: const Icon(Icons.add, size: 18),
            ),
          ],
        ),
      ],
    );
  }
}
