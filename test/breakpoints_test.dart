import 'package:breakpoint_builder/breakpoint_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sizeFor uses the thresholds', () {
    const b = Breakpoints();
    expect(b.sizeFor(375), ScreenSize.mobile);
    expect(b.sizeFor(600), ScreenSize.tablet);
    expect(b.sizeFor(1023), ScreenSize.tablet);
    expect(b.sizeFor(1440), ScreenSize.desktop);
    expect(const Breakpoints(tablet: 500, desktop: 900).sizeFor(950),
        ScreenSize.desktop);
  });

  test('ResponsiveValue falls back to smaller sizes', () {
    const v = ResponsiveValue(mobile: 1, tablet: 2);
    expect(v.forSize(ScreenSize.mobile), 1);
    expect(v.forSize(ScreenSize.tablet), 2);
    expect(v.forSize(ScreenSize.desktop), 2);
    expect(const ResponsiveValue(mobile: 'm').forSize(ScreenSize.desktop), 'm');
  });

  Future<void> pumpAt(WidgetTester tester, double width, Widget child) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: child));
  }

  final builder = BreakpointBuilder(
    mobile: (_) => const Text('mobile'),
    tablet: (_) => const Text('tablet'),
    desktop: (_) => const Text('desktop'),
  );

  testWidgets('builds the mobile layout', (tester) async {
    await pumpAt(tester, 400, builder);
    expect(find.text('mobile'), findsOneWidget);
  });

  testWidgets('builds the desktop layout', (tester) async {
    await pumpAt(tester, 1300, builder);
    expect(find.text('desktop'), findsOneWidget);
  });

  testWidgets('parent width mode and context helpers', (tester) async {
    await pumpAt(
      tester,
      1300,
      Row(children: [
        SizedBox(
          width: 300,
          child: BreakpointBuilder(
            useParentWidth: true,
            mobile: (_) => const Text('narrow panel'),
            desktop: (_) => const Text('wide panel'),
          ),
        ),
        Builder(
          builder: (context) =>
              Text(context.responsive(mobile: 'm', desktop: 'screen: desktop')),
        ),
      ]),
    );
    expect(find.text('narrow panel'), findsOneWidget);
    expect(find.text('screen: desktop'), findsOneWidget);
  });
}
