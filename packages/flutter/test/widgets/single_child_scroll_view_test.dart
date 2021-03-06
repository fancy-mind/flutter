// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

class TestScrollPosition extends ScrollPosition {
  TestScrollPosition({
    ScrollPhysics physics,
    AbstractScrollState state,
    double initialPixels: 0.0,
    ScrollPosition oldPosition,
  }) : super(
    physics: physics,
    state: state,
    initialPixels: initialPixels,
    oldPosition: oldPosition,
  );
}

class TestScrollController extends ScrollController {
  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics, AbstractScrollState state, ScrollPosition oldPosition) {
    return new TestScrollPosition(
      physics: physics,
      state: state,
      initialPixels: initialScrollOffset,
      oldPosition: oldPosition,
    );
  }
}

void main() {
  testWidgets('SingleChildScrollView control test', (WidgetTester tester) async {
    await tester.pumpWidget(new SingleChildScrollView(
      child: new Container(
        height: 2000.0,
        decoration: const BoxDecoration(
          backgroundColor: const Color(0xFF00FF00),
        ),
      ),
    ));

    RenderBox box = tester.renderObject(find.byType(Container));
    expect(box.localToGlobal(Point.origin), equals(Point.origin));

    await tester.scroll(find.byType(SingleChildScrollView), const Offset(-200.0, -200.0));

    expect(box.localToGlobal(Point.origin), equals(const Point(0.0, -200.0)));
  });

  testWidgets('Changing controllers changes scroll position', (WidgetTester tester) async {
    TestScrollController controller = new TestScrollController();

    await tester.pumpWidget(new SingleChildScrollView(
      child: new Container(
        height: 2000.0,
        decoration: const BoxDecoration(
          backgroundColor: const Color(0xFF00FF00),
        ),
      ),
    ));

    await tester.pumpWidget(new SingleChildScrollView(
      controller: controller,
      child: new Container(
        height: 2000.0,
        decoration: const BoxDecoration(
          backgroundColor: const Color(0xFF00FF00),
        ),
      ),
    ));

    ScrollableState scrollable = tester.state(find.byType(Scrollable));
    expect(scrollable.position, const isInstanceOf<TestScrollPosition>());
  });

  testWidgets('Sets PrimaryScrollController when primary', (WidgetTester tester) async {
    ScrollController primaryScrollController = new ScrollController();
    await tester.pumpWidget(new PrimaryScrollController(
      controller: primaryScrollController,
      child: new SingleChildScrollView(
        primary: true,
        child: new Container(
          height: 2000.0,
          decoration: const BoxDecoration(
            backgroundColor: const Color(0xFF00FF00),
          ),
        ),
      ),
    ));

    Scrollable scrollable = tester.widget(find.byType(Scrollable));
    expect(scrollable.controller, primaryScrollController);
  });


  testWidgets('Changing scroll controller inside dirty layout builder does not assert', (WidgetTester tester) async {
    ScrollController controller = new ScrollController();

    await tester.pumpWidget(new Center(
      child: new SizedBox(
        width: 750.0,
        child: new LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return new SingleChildScrollView(
              child: new Container(
                height: 2000.0,
                decoration: const BoxDecoration(
                  backgroundColor: const Color(0xFF00FF00),
                ),
              ),
            );
          },
        ),
      ),
    ));

    await tester.pumpWidget(new Center(
      child: new SizedBox(
        width: 700.0,
        child: new LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return new SingleChildScrollView(
              controller: controller,
              child: new Container(
                height: 2000.0,
                decoration: const BoxDecoration(
                  backgroundColor: const Color(0xFF00FF00),
                ),
              ),
            );
          },
        ),
      ),
    ));
  });

  testWidgets('Vertical SingleChildScrollViews are primary by default', (WidgetTester tester) async {
    SingleChildScrollView view = new SingleChildScrollView(scrollDirection: Axis.vertical);
    expect(view.primary, isTrue);
  });

  testWidgets('Horizontal SingleChildScrollViews are non-primary by default', (WidgetTester tester) async {
    SingleChildScrollView view = new SingleChildScrollView(scrollDirection: Axis.horizontal);
    expect(view.primary, isFalse);
  });

  testWidgets('SingleChildScrollViews with controllers are non-primary by default', (WidgetTester tester) async {
    SingleChildScrollView view = new SingleChildScrollView(
      controller: new ScrollController(),
      scrollDirection: Axis.vertical,
    );
    expect(view.primary, isFalse);
  });

  testWidgets('Nested scrollables have a null PrimaryScrollController', (WidgetTester tester) async {
    const Key innerKey = const Key('inner');
    ScrollController primaryScrollController = new ScrollController();
    await tester.pumpWidget(new PrimaryScrollController(
      controller: primaryScrollController,
      child: new SingleChildScrollView(
        primary: true,
        child: new Container(
          constraints: new BoxConstraints(maxHeight: 200.0),
          child: new ListView(key: innerKey, primary: true),
        ),
      ),
    ));

    Scrollable innerScrollable = tester.widget(
      find.descendant(
        of: find.byKey(innerKey),
        matching: find.byType(Scrollable),
      ),
    );
    expect(innerScrollable.controller, isNull);
  });
}
