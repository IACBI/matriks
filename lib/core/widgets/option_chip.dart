import 'package:flutter/material.dart';

/// A [ChoiceChip] for one option of a group where exactly one is chosen
/// (theme, topic category, transformation preset), exposed to screen
/// readers as a radio button.
///
/// A chip's own node is a button, and the Windows accessibility bridge
/// picks the button role over any checked state, so UI Automation showed
/// every option as a plain button and Narrator never said which one was
/// chosen. This node carries the label, the checked state and the tap
/// instead, and mirrors the chip's keyboard focus so Narrator still
/// follows Tab.
class OptionChip extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const OptionChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<OptionChip> createState() => _OptionChipState();
}

class _OptionChipState extends State<OptionChip> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  void _onFocus() => setState(() {});

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    inMutuallyExclusiveGroup: true,
    checked: widget.selected,
    focusable: true,
    focused: _focus.hasFocus,
    label: widget.label,
    onTap: widget.onSelected,
    child: ExcludeSemantics(
      child: ChoiceChip(
        focusNode: _focus,
        label: Text(widget.label),
        selected: widget.selected,
        onSelected: (_) => widget.onSelected(),
      ),
    ),
  );
}
