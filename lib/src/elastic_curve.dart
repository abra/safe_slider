import 'dart:math';

import 'package:flutter/animation.dart';

import 'safe_slider_defaults.dart';

class ElasticOutCurve extends Curve {
  const ElasticOutCurve({
    this.period = SafeSliderDefaults.elasticPeriod,
    this.bounceFactor = SafeSliderDefaults.elasticBounceFactor,
  });

  final double period;
  final double bounceFactor;

  @override
  double transformInternal(double t) {
    final double s = period / 4.0;
    return bounceFactor *
            pow(2.0, -10 * t) *
            sin((t - s) * (pi * 2.0) / period) +
        1.0;
  }
}
