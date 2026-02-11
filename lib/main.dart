import 'package:flutter/material.dart';

import 'safe_slider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        debugShowMaterialGrid: false,
        theme: ThemeData(
          brightness: Brightness.light,
        ),
        home: const HomePage(),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double _topSpacing = 40;
  static const double _sliderSpacing = 80;
  static const double _dividerSpacing = 10;
  static const double _horizontalInset = 60;
  static const double _valueFontSize = 70;
  static const double _dividerThickness = 3;
  static const double _thumbSize = 80;
  static const double _strokeWidth = 3;

  static const _textStyle = TextStyle(
    fontSize: _valueFontSize,
    fontFamily: SafeSliderDefaults.fontFamily,
    color: SafeSliderDefaults.activeColor,
  );

  double _value = 0.0;

  @override
  Widget build(BuildContext context) {
    final sliderWidth = MediaQuery.sizeOf(context).width - _horizontalInset;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Slider'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: _topSpacing),
            Text(
              _value.toStringAsFixed(SafeSliderDefaults.labelDecimalPlaces),
              style: _textStyle,
            ),
            const SizedBox(height: _sliderSpacing),
            SafeSlider(
              value: _value,
              width: sliderWidth,
              strokeWidth: _strokeWidth,
              thumbSize: _thumbSize,
              onChanged: (value) {
                setState(() {
                  _value = value;
                });
              },
            ),
            const SizedBox(height: _dividerSpacing),
            SizedBox(
              width: sliderWidth,
              child: const Divider(
                thickness: _dividerThickness,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
