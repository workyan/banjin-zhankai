import 'dart:math' as math;

import 'package:banjin_zhankai/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calculates a conical frustum development from real geometry', () {
    final result = ConeResult.calculate(
      largeDiameter: 1000,
      smallDiameter: 600,
      height: 800,
      thickness: 2,
      segments: 12,
    );

    expect(result.slant, closeTo(824.621, 0.001));
    expect(result.innerRadius, closeTo(1236.932, 0.001));
    expect(result.outerRadius, closeTo(2061.553, 0.001));
    expect(result.angle, closeTo(87.313, 0.001));
    expect(result.area, closeTo(2.0725, 0.001));
  });

  test('calculates all visible engineering templates', () {
    final bend = EngineeringMath.bend({
      'legA': 300,
      'legB': 200,
      'radius': 3,
      'thickness': 2,
      'angle': 90,
      'kFactor': .4,
    });
    expect(bend.metrics.last.$2, closeTo(495.969, .001));

    final eccentric = EngineeringMath.eccentricCone({
      'large': 1000,
      'small': 600,
      'height': 800,
      'offset': 150,
      'segments': 12,
    });
    expect(eccentric.points.reduce(math.min), closeTo(801.561, .001));
    expect(eccentric.points.reduce(math.max), closeTo(873.212, .001));

    final elbow = EngineeringMath.elbow({
      'diameter': 500,
      'radius': 750,
      'angle': 90,
      'pieces': 4,
    });
    expect(elbow.metrics.first.$2, closeTo(1570.796, .001));
    expect(elbow.points.reduce(math.min), closeTo(133.975, .01));
    expect(elbow.points.reduce(math.max), closeTo(267.949, .01));

    final tee = EngineeringMath.tee({
      'mainDiameter': 600,
      'branchDiameter': 400,
      'angle': 90,
      'segments': 12,
    });
    expect(tee.points.reduce(math.min), 0);
    expect(tee.points.reduce(math.max), closeTo(76.393, .01));

    final transition = EngineeringMath.squareRound({
      'width': 800,
      'depth': 600,
      'diameter': 500,
      'height': 700,
      'offsetX': 0,
      'offsetY': 0,
      'segments': 16,
    });
    expect(transition.points.first, closeTo(776.209, .01));
    expect(transition.points.last, closeTo(transition.points.first, .001));
    expect(transition.metrics.last.$2, greaterThan(0));
  });

  testWidgets('shows the expansion workspace', (tester) async {
    await tester.pumpWidget(const SheetMetalApp());

    expect(find.text('最近使用'), findsOneWidget);
    expect(find.text('常用分类'), findsOneWidget);
    expect(find.text('展开'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.viewfinder), findsNothing);
  });

  testWidgets('search field and both all actions are interactive', (
    tester,
  ) async {
    await tester.pumpWidget(const SheetMetalApp());

    await tester.tap(find.text('搜索构件、俗称'));
    await tester.pumpAndSettle();
    expect(find.byType(EditableText), findsOneWidget);
    expect(find.text('参数输入 · 展开数据 · 点位图'), findsWidgets);
    await tester.tap(find.byIcon(CupertinoIcons.chevron_left).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('全部').first);
    await tester.pumpAndSettle();
    expect(find.text('最近使用'), findsOneWidget);
    expect(find.text('同心圆锥台'), findsOneWidget);
    await tester.tap(find.byIcon(CupertinoIcons.chevron_left).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('全部').last);
    await tester.pumpAndSettle();
    expect(find.text('收藏'), findsOneWidget);
    expect(find.text('偏心大小头'), findsOneWidget);
  });

  testWidgets('share uses a valid iOS popover origin', (tester) async {
    const channel = MethodChannel('dev.fluttercommunity.plus/share');
    MethodCall? received;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          received = call;
          return 'dev.fluttercommunity.plus/share/dismissed';
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));

    await shareText(
      tester.element(find.byType(Scaffold)),
      'test calculation result',
    );

    expect(received?.method, 'share');
    final arguments = received?.arguments as Map<Object?, Object?>;
    expect(arguments['text'], 'test calculation result');
    expect(arguments['originWidth'], greaterThan(0));
    expect(arguments['originHeight'], greaterThan(0));
  });

  testWidgets('opens a component and shows its calculation result', (
    tester,
  ) async {
    await tester.pumpWidget(const SheetMetalApp());

    await tester.tap(find.text('同心圆锥台'));
    await tester.pumpAndSettle();
    expect(find.text('大端直径 A'), findsOneWidget);

    await tester.tap(find.text('计算'));
    await tester.pumpAndSettle();
    expect(find.text('母线实长 L'), findsOneWidget);
    expect(find.text('展开图'), findsOneWidget);
  });

  testWidgets('rejects an impossible diameter combination', (tester) async {
    await tester.pumpWidget(const SheetMetalApp());

    await tester.tap(find.text('同心圆锥台'));
    await tester.pumpAndSettle();
    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), '500');
    await tester.enterText(fields.at(1), '600');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    final calculate = find.text('计算');
    await tester.ensureVisible(calculate);
    await tester.tap(calculate);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('大端直径必须大于小端直径'), findsOneWidget);
  });

  for (final entry in <(TemplateType, String)>[
    (TemplateType.bend, '折弯余量 BA'),
    (TemplateType.eccentricCone, '最短素线'),
    (TemplateType.elbow, '圆周展开宽度'),
    (TemplateType.tee, '支管展开宽度'),
    (TemplateType.squareRound, '方口周长'),
  ]) {
    testWidgets('${entry.$1.name} completes its calculation flow', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: GenericCalculatorPage(type: entry.$1)),
      );

      await tester.tap(find.text('计算'));
      await tester.pumpAndSettle();

      expect(find.text(entry.$2), findsOneWidget);
      expect(find.text('展开与点位'), findsOneWidget);
    });
  }
}
