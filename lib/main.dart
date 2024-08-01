import 'package:flutter/material.dart';

import 'safe_slider.dart';

void main() {
  runApp(const MyApp());
}

const textStyle = TextStyle(
  fontSize: 70,
  fontFamily: 'DroidSansMono',
  color: Color(0xFF323A46),
);

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
  double _value = 0.0;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Safe Slider'),
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                _value.toStringAsFixed(2),
                style: textStyle,
              ),
              const SizedBox(height: 80),
              SafeSlider(
                value: _value,
                width: MediaQuery.of(context).size.width - 60,
                strokeWidth: 3,
                thumbSize: 80,
                onChanged: (value) {
                  setState(() {
                    _value = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width - 60,
                child: const Divider(
                  thickness: 3,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
        ),
      );
}
