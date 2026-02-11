import 'package:flutter/material.dart';

import 'indicator.dart';
import 'safe_slider_defaults.dart';
import 'track_painter.dart';

class SafeSlider extends StatefulWidget {
  const SafeSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = SafeSliderDefaults.activeColor,
    this.inactiveColor = SafeSliderDefaults.inactiveColor,
    this.warningColor = SafeSliderDefaults.warningColor,
    this.thumbSize = SafeSliderDefaults.thumbSize,
    this.strokeWidth = SafeSliderDefaults.strokeWidth,
    this.width,
  });

  final double value;
  final ValueChanged<double> onChanged;
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
  double _thumbPosition = 0.0;
  final LayerLink _layerLink = LayerLink();
  late Color _trackActiveColor;
  late OverlayPortalController _overlayPortalController;

  @override
  void initState() {
    super.initState();
    _trackActiveColor = widget.activeColor;
    _overlayPortalController = OverlayPortalController();
    _overlayPortalController.show();
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
                    label: (_thumbPosition / (width - thumbRadius * 2))
                        .toStringAsFixed(SafeSliderDefaults.labelDecimalPlaces),
                    link: _layerLink,
                    onWarningChanged: (value) {
                      setState(() {
                        _trackActiveColor = value == _trackActiveColor
                            ? widget.activeColor
                            : value;
                      });
                    },
                    onDragged: (value) {
                      widget.onChanged(value);
                      setState(() {
                        _thumbPosition = value * (width - thumbRadius * 2);
                      });
                    },
                    height: height,
                    width: width,
                    thumbSize: height,
                  ),
                  child: CustomPaint(
                    size: Size(width, height),
                    painter: TrackPainter(
                      thumbPosition: _thumbPosition,
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
