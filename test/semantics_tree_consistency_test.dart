import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matriks/app.dart';

/// The Windows (and other desktop) accessibility bridge builds its tree from
/// each node's traversal-order children and rejects an update that names a
/// node no parent lists; after one rejection every later update fails too,
/// and a screen reader keeps seeing a stale screen. A Slider's value
/// indicator OverlayPortal produced such a node whenever the slider was
/// hidden (collapsed drawer, background tab, covered route), so lessons
/// never reached Narrator. These tests replay the app's semantics updates
/// the way that bridge applies them.

final _updates = <Map<int, List<int>>>[];

class _Recorder implements ui.SemanticsUpdateBuilder {
  final _nodes = <int, List<int>>{};

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #updateNode) {
      final args = invocation.namedArguments;
      _nodes[args[#id] as int] = (args[#childrenInTraversalOrder] as Int32List)
          .toList();
    }
    return null;
  }

  @override
  ui.SemanticsUpdate build() {
    _updates.add(_nodes);
    return ui.SemanticsUpdateBuilder().build();
  }
}

class _RecordingBinding extends AutomatedTestWidgetsFlutterBinding {
  @override
  ui.SemanticsUpdateBuilder createSemanticsUpdateBuilder() => _Recorder();
}

/// Nodes an update sent that are unreachable from the root afterwards.
List<String> _orphans() {
  final tree = <int, List<int>>{};
  final orphans = <String>[];
  for (final (index, update) in _updates.indexed) {
    tree.addAll(update);
    final reachable = <int>{};
    void walk(int id) {
      if (!reachable.add(id)) return;
      for (final child in tree[id] ?? const <int>[]) {
        walk(child);
      }
    }

    walk(0);
    for (final id in update.keys) {
      if (!reachable.contains(id)) orphans.add('update $index: node $id');
    }
    tree.removeWhere((id, _) => !reachable.contains(id));
  }
  return orphans;
}

void main() {
  _RecordingBinding();

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  setUp(_updates.clear);

  testWidgets('Every semantics update keeps each node in the tree', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    tester.view.physicalSize = const Size(1280, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MatrixEducatorApp());
    await settle(tester);

    // Settings: the speed slider sits in a drawer that expands.
    await tester.tap(find.text('Settings'));
    await settle(tester);
    await tester.tap(find.text('More options'));
    await settle(tester);
    await tester.tap(find.text('More options'));
    await settle(tester);

    // Transformations: its slider stays alive in a background tab.
    await tester.tap(find.text('Transformations'));
    await settle(tester);
    await tester.tap(find.text('Topics').first);
    await settle(tester);

    // A lesson, whose Details drawer holds the scrub slider.
    await tester.tap(find.text('1 · Create zeros'));
    await settle(tester);
    final details = find.byKey(const ValueKey('operation-inspector'));
    await tester.ensureVisible(details);
    await tester.tap(details);
    await settle(tester);
    // The step list covers the lesson with its drawer open.
    await tester.tap(find.byKey(const ValueKey('choose-lesson-step')));
    await settle(tester);
    await tester.tapAt(const Offset(10, 10));
    await settle(tester);
    await tester.tap(details);
    await settle(tester);
    await tester.tap(find.byTooltip('Back'));
    await settle(tester);

    // A lesson started from the input screen.
    await tester.tap(find.text('Matrix Addition'));
    await settle(tester);
    await tester.tap(find.text('Solve'));
    await settle(tester);
    await tester.tap(find.byTooltip('Back'));
    await settle(tester);

    expect(_updates, isNotEmpty);
    expect(_orphans(), isEmpty);
    semantics.dispose();
  });
}
