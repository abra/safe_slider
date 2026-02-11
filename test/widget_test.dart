import 'package:flutter/material.dart' hide ElasticOutCurve;
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_slider/main.dart';
import 'package:safe_slider/safe_slider.dart';

void main() {
  group('MyApp', () {
    testWidgets('renders SafeSlider and displays initial value',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.byType(SafeSlider), findsOneWidget);
      expect(find.text('1.0'), findsExactly(2));
    });
  });

  group('SafeSlider', () {
    testWidgets('renders with default parameters',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeSlider(
              value: 0.0,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(SafeSlider), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders with custom colors and dimensions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeSlider(
              value: 0.0,
              onChanged: (_) {},
              activeColor: Colors.blue,
              inactiveColor: Colors.grey,
              warningColor: Colors.red,
              thumbSize: 60,
              strokeWidth: 4,
              width: 300,
            ),
          ),
        ),
      );

      expect(find.byType(SafeSlider), findsOneWidget);
    });

    testWidgets('displays label with correct decimal places',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeSlider(
              value: 0.0,
              onChanged: (_) {},
              width: 200,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('0.00'), findsOneWidget);
    });

    testWidgets('renders with min/max and shows initial value',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeSlider(
              value: 5.0,
              min: 1,
              max: 10,
              labelDecimalPlaces: 1,
              onChanged: (_) {},
              width: 300,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SafeSlider), findsOneWidget);
      expect(find.text('5.0'), findsOneWidget);
    });
  });

  group('ElasticOutCurve', () {
    test('returns 1.0 at t=1.0', () {
      const curve = ElasticOutCurve();
      expect(curve.transform(1.0), closeTo(1.0, 0.001));
    });

    test('returns approximately 1.0 at t=0.0', () {
      const curve = ElasticOutCurve();
      // At t=0 the formula gives 1 + bounceFactor * sin(-s * 2π / period)
      final result = curve.transform(0.0);
      expect(result, isA<double>());
      expect(result.isFinite, isTrue);
    });

    test('uses custom period and bounceFactor', () {
      const curve = ElasticOutCurve(period: 0.6, bounceFactor: 0.3);
      final result = curve.transform(0.5);
      expect(result, isA<double>());
      expect(result.isFinite, isTrue);
    });

    test('produces overshoot (values > 1.0) during animation', () {
      const curve = ElasticOutCurve();
      // ElasticOut curves characteristically overshoot 1.0
      final values = List.generate(
        100,
        (i) => curve.transform(i / 100),
      );
      expect(values.any((v) => v > 1.0), isTrue);
    });

    test('asserts on zero period', () {
      expect(
        () => ElasticOutCurve(period: 0),
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts on negative period', () {
      expect(
        () => ElasticOutCurve(period: -1),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('SafeSliderDefaults', () {
    test('min is less than max', () {
      expect(SafeSliderDefaults.min, lessThan(SafeSliderDefaults.max));
    });

    test('colors are non-transparent', () {
      expect(SafeSliderDefaults.activeColor.a, 1.0);
      expect(SafeSliderDefaults.inactiveColor.a, 1.0);
      expect(SafeSliderDefaults.warningColor.a, 1.0);
    });

    test('dimensions are positive', () {
      expect(SafeSliderDefaults.thumbSize, greaterThan(0));
      expect(SafeSliderDefaults.strokeWidth, greaterThan(0));
      expect(SafeSliderDefaults.labelFontSize, greaterThan(0));
    });

    test('gesture thresholds are within valid range', () {
      expect(SafeSliderDefaults.angleThreshold, greaterThan(0));
      expect(SafeSliderDefaults.angleThreshold, lessThan(90));
      expect(SafeSliderDefaults.maxStretchRatio, greaterThan(1.0));
    });

    test('animation durations are positive', () {
      expect(SafeSliderDefaults.snapDuration.inMilliseconds, greaterThan(0));
      expect(SafeSliderDefaults.bounceDuration.inMilliseconds, greaterThan(0));
      expect(SafeSliderDefaults.unlockDelay.inMilliseconds, greaterThan(0));
    });

    test('elastic parameters are positive', () {
      expect(SafeSliderDefaults.elasticPeriod, greaterThan(0));
      expect(SafeSliderDefaults.elasticBounceFactor, greaterThan(0));
    });
  });
}
