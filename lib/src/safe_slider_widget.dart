import 'package:flutter/material.dart';

import 'indicator.dart';
import 'safe_slider_defaults.dart';
import 'track_painter.dart';

class SafeSlider extends StatefulWidget {
  const SafeSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = SafeSliderDefaults.min,
    this.max = SafeSliderDefaults.max,
    this.labelDecimalPlaces = SafeSliderDefaults.labelDecimalPlaces,
    this.activeColor = SafeSliderDefaults.activeColor,
    this.inactiveColor = SafeSliderDefaults.inactiveColor,
    this.warningColor = SafeSliderDefaults.warningColor,
    this.thumbSize = SafeSliderDefaults.thumbSize,
    this.strokeWidth = SafeSliderDefaults.strokeWidth,
    this.width,
  }) : assert(min < max, 'min must be less than max');

  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int labelDecimalPlaces;
  final Color activeColor;
  final Color inactiveColor;
  final Color warningColor;
  final double thumbSize;
  final double strokeWidth;
  final double? width;

  @override
  State<SafeSlider> createState() => _SafeSliderState();
}

class _SafeSliderState extends State<SafeSlider> {
  late double _ratio;
  final LayerLink _layerLink = LayerLink();
  late Color _trackActiveColor;
  late OverlayPortalController _overlayPortalController;

  @override
  void initState() {
    super.initState();
    _ratio = ((widget.value - widget.min) / (widget.max - widget.min))
        .clamp(0.0, 1.0);
    _trackActiveColor = widget.activeColor;
    _overlayPortalController = OverlayPortalController();
    _overlayPortalController.show();
  }

  String _labelValue() {
    final value = widget.min + _ratio * (widget.max - widget.min);
    return value.toStringAsFixed(widget.labelDecimalPlaces);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final width = widget.width ?? constraints.maxWidth;
          final height = widget.thumbSize;
          final thumbRadius = height / 2;
          final strokeWidth = widget.strokeWidth;

          return Center(
            child: SizedBox(
              width: width,
              height: height,
              child: CompositedTransformTarget(
                link: _layerLink,
                child: OverlayPortal(
                  controller: _overlayPortalController,
                  overlayChildBuilder: (context) => Indicator(
                    strokeWidth: strokeWidth,
                    activeColor: widget.activeColor,
                    warningColor: widget.warningColor,
                    label: _labelValue(),
                    link: _layerLink,
                    onWarningChanged: (value) {
                      setState(() {
                        _trackActiveColor = value;
                      });
                    },
                    onDragged: (ratio) {
                      final value =
                          widget.min + ratio * (widget.max - widget.min);
                      widget.onChanged(value);
                      setState(() {
                        _ratio = ratio;
                      });
                    },
                    height: height,
                    width: width,
                    thumbSize: height,
                  ),
                  child: CustomPaint(
                    size: Size(width, height),
                    painter: TrackPainter(
                      thumbPosition: _ratio * (width - thumbRadius * 2),
                      inactiveColor: widget.inactiveColor,
                      activeColor: _trackActiveColor,
                      strokeWidth: strokeWidth,
                      thumbRadius: thumbRadius,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
}
