import 'package:flutter_test/flutter_test.dart';
import 'package:safe_slider/main.dart';
import 'package:safe_slider/safe_slider.dart';

void main() {
  testWidgets('SafeSlider renders and displays initial value',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(SafeSlider), findsOneWidget);
    expect(find.text('0.00'), findsWidgets);
  });
}
