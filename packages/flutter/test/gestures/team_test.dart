// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/gestures.dart';

import 'gesture_tester.dart';

void main() {
  setUp(ensureGestureBinding);

  testGesture('GestureArenaTeam rejection test', (GestureTester tester) {

    GestureArenaTeam team = new GestureArenaTeam();
    HorizontalDragGestureRecognizer horizontalDrag = new HorizontalDragGestureRecognizer()..team = team;
    VerticalDragGestureRecognizer verticalDrag = new VerticalDragGestureRecognizer()..team = team;
    TapGestureRecognizer tap = new TapGestureRecognizer();

    expect(horizontalDrag.team, equals(team));
    expect(verticalDrag.team, equals(team));
    expect(tap.team, isNull);

    List<String> log = <String>[];

    horizontalDrag.onStart = (DragStartDetails details) { log.add('hoizontal-drag-start'); };
    verticalDrag.onStart = (DragStartDetails details) { log.add('vertical-drag-start'); };
    tap.onTap = () { log.add('tap'); };

    void test(Offset delta) {
      Point origin = const Point(10.0, 10.0);
      TestPointer pointer = new TestPointer(5);
      PointerDownEvent down = pointer.down(origin);
      horizontalDrag.addPointer(down);
      verticalDrag.addPointer(down);
      tap.addPointer(down);
      expect(log, isEmpty);
      tester.closeArena(5);
      expect(log, isEmpty);
      tester.route(down);
      expect(log, isEmpty);
      tester.route(pointer.move(origin + delta));
      tester.route(pointer.up());
    }

    test(Offset.zero);
    expect(log, <String>['tap']);
    log.clear();

    test(const Offset(0.0, 30.0));
    expect(log, <String>['vertical-drag-start']);
    log.clear();

    horizontalDrag.dispose();
    verticalDrag.dispose();
    tap.dispose();
  });
}
