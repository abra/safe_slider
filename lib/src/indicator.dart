import 'dart:math';

import 'package:flutter/material.dart' hide ElasticOutCurve;

import 'elastic_curve.dart';
import 'safe_slider_defaults.dart';

enum DragDirection { left, right, down }

class Indicator extends StatefulWidget {
  const Indicator({
    super.key,
    required this.strokeWidth,
    required this.activeColor,
    required this.warningColor,
    required this.label,
    required this.link,
    required this.height,
    required this.width,
    required this.thumbSize,
    required this.onDragged,
    required this.onWarningChanged,
  });

  final double strokeWidth;
  final Color activeColor;
  final Color warningColor;
  final String label;
  final LayerLink link;
  final double height;
  final double width;
  final double thumbSize;
  final ValueChanged<double> onDragged;
  final ValueChanged<Color> onWarningChanged;

  @override
  State<Indicator> createState() => _IndicatorState();
}

class _IndicatorState extends State<Indicator> {
  late Color _activeColor;
  late double _strokeWidth;
  late double _indicatorHeight;
  late double _indicatorWidth;
  late double _trackWidth;
  late final double _thumbRadius;
  late final double _maxStretchWidth;
  late final double _maxStretchHeight;
  bool _isUnlocked = false;
  bool _horizontalAllowed = true;
  bool _verticalAllowed = true;
  final GlobalKey _textKey = GlobalKey();
  double _labelHorizontalPadding = 0;
  double _labelVerticalPadding = 0;
  AlignmentGeometry _labelAlignment = Alignment.center;
  double _containerPaddingLeft = 0;
  double _containerPaddingRight = 0;
  DragDirection? _dragDirection;
  Offset _panOrigin = Offset.zero;
  late Offset _thumbOffset;
  double? _indicatorLeft;
  double? _indicatorRight;

  @override
  void initState() {
    super.initState();
    _activeColor = widget.activeColor;
    _strokeWidth = widget.strokeWidth;
    _indicatorHeight = widget.thumbSize;
    _indicatorWidth = widget.thumbSize;
    _maxStretchHeight = widget.height * SafeSliderDefaults.maxStretchRatio;
    _maxStretchWidth = widget.height * SafeSliderDefaults.maxStretchRatio;
    _thumbRadius = widget.thumbSize / 2;
    _trackWidth = widget.width;
    _thumbOffset = Offset(_thumbRadius, 0);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateLabelPadding());

    return Center(
      child: CompositedTransformFollower(
        link: widget.link,
        child: Container(
          padding: EdgeInsets.only(
            left: _containerPaddingLeft,
            right: _containerPaddingRight,
          ),
          width: widget.width,
          child: GestureDetector(
            onPanStart: _onPanDragStart,
            onPanEnd: _onPanDragEnd,
            onPanUpdate: _onPanDragUpdate,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: _indicatorLeft,
                  right: _indicatorRight,
                  child: AnimatedContainer(
                    duration: SafeSliderDefaults.snapDuration,
                    height: _indicatorHeight,
                    width: _indicatorWidth,
                    padding: EdgeInsets.symmetric(
                      horizontal: _labelHorizontalPadding,
                      vertical: _labelVerticalPadding,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_thumbRadius),
                      border: Border.all(
                        color: _activeColor,
                        width: _strokeWidth,
                      ),
                      color: SafeSliderDefaults.thumbFillColor,
                    ),
                    child: AnimatedAlign(
                      alignment: _labelAlignment,
                      duration: SafeSliderDefaults.bounceDuration,
                      curve: const ElasticOutCurve(),
                      child: FittedBox(
                        child: Text(
                          key: _textKey,
                          widget.label,
                          style: TextStyle(
                            color: _activeColor,
                            fontSize: SafeSliderDefaults.labelFontSize,
                            fontFamily: SafeSliderDefaults.fontFamily,
                            fontWeight: SafeSliderDefaults.labelFontWeight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateLabelPadding() {
    final keyContext = _textKey.currentContext;
    if (keyContext == null) return;
    final box = keyContext.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final hPadding =
        (((widget.thumbSize - box.size.width) / 2) - _strokeWidth).clamp(0.0, double.infinity);
    final vPadding =
        (((widget.thumbSize - box.size.height) / 2) - _strokeWidth).clamp(0.0, double.infinity);
    if (hPadding != _labelHorizontalPadding ||
        vPadding != _labelVerticalPadding) {
      setState(() {
        _labelHorizontalPadding = hPadding;
        _labelVerticalPadding = vPadding;
      });
    }
  }

  void _onPanDragEnd(DragEndDetails details) {
    setState(() {
      if (!_isUnlocked) {
        _activeColor = widget.activeColor;
        widget.onWarningChanged(widget.activeColor);
      }
      _indicatorWidth = _thumbRadius * 2;
      _indicatorHeight = _thumbRadius * 2;
      _horizontalAllowed = true;
      _verticalAllowed = true;
      _panOrigin = Offset.zero;
      _dragDirection = null;
      _containerPaddingLeft = 0;
      _containerPaddingRight = 0;
      _isUnlocked = false;
    });
  }

  void _onPanDragStart(DragStartDetails details) {
    setState(() {
      _panOrigin = details.localPosition;
    });
  }

  void _setWarningColor() {
    if (_activeColor != widget.warningColor) {
      _activeColor = widget.warningColor;
      widget.onWarningChanged(widget.warningColor);
    }
  }

  void _onPanDragUpdate(DragUpdateDetails details) {
    if (_isUnlocked) {
      _handleActiveDrag(details);
    } else {
      _handleLockedDrag(details);
    }
  }

  void _handleActiveDrag(DragUpdateDetails details) {
    final offset = _thumbOffset;
    final percentage =
        (offset.dx - _thumbRadius) / (_trackWidth - (_thumbRadius * 2));
    widget.onDragged(percentage);
    setState(() {
      final unclamped = Offset(offset.dx + details.delta.dx, 0);
      _thumbOffset = Offset(
        unclamped.dx.clamp(_thumbRadius, _trackWidth - _thumbRadius),
        unclamped.dy,
      );
      _indicatorLeft = offset.dx - _thumbRadius;
      _indicatorRight = _trackWidth - offset.dx - _thumbRadius;
    });
  }

  DragDirection? _detectDirection(Offset current) {
    if (_panOrigin.dx < current.dx && _horizontalAllowed) {
      return DragDirection.right;
    } else if (_panOrigin.dx > current.dx && _horizontalAllowed) {
      return DragDirection.left;
    } else if (_panOrigin.dy < current.dy && _verticalAllowed) {
      return DragDirection.down;
    }
    return null;
  }

  void _handleLockedDrag(DragUpdateDetails details) {
    final offset = _thumbOffset;
    final currentPosition = details.localPosition;

    final dy = currentPosition.dy - _panOrigin.dy;
    final dx = currentPosition.dx - _panOrigin.dx;
    final horizontalAngle = (atan(dy / dx) * (180 / pi)).abs();
    final verticalAngle = (atan(dx / dy) * (180 / pi)).abs();

    if (horizontalAngle > SafeSliderDefaults.angleThreshold) {
      _horizontalAllowed = false;
    }
    if (verticalAngle > SafeSliderDefaults.angleThreshold) {
      _verticalAllowed = false;
    }

    // Determine initial drag direction
    _dragDirection ??= _detectDirection(currentPosition);

    setState(() {
      switch (_dragDirection) {
        case DragDirection.right when _horizontalAllowed:
          _setWarningColor();
          _labelAlignment = Alignment.centerRight;
          _indicatorRight = null;
          _indicatorLeft = offset.dx - _thumbRadius;
          _indicatorWidth = (_indicatorWidth + details.delta.dx)
              .clamp(widget.thumbSize, _trackWidth - _indicatorLeft!);
          if (_indicatorWidth >= _maxStretchWidth ||
              _indicatorLeft! + _indicatorWidth >= _trackWidth) {
            _horizontalAllowed = false;
            _verticalAllowed = false;
            _labelAlignment = Alignment.centerLeft;
          }

        case DragDirection.left when _horizontalAllowed:
          _setWarningColor();
          _labelAlignment = Alignment.centerLeft;
          _indicatorLeft = null;
          _indicatorRight = _trackWidth - offset.dx - _thumbRadius;
          _indicatorWidth = (_indicatorWidth - details.delta.dx)
              .clamp(widget.thumbSize, _trackWidth - _indicatorRight!);
          if (_indicatorWidth >= _maxStretchWidth ||
              _indicatorRight! + _indicatorWidth >= _trackWidth) {
            _horizontalAllowed = false;
            _verticalAllowed = false;
            _labelAlignment = Alignment.centerRight;
          }

        case DragDirection.down when _verticalAllowed:
          _labelAlignment = Alignment.bottomCenter;
          _indicatorHeight = (_indicatorHeight + details.delta.dy)
              .clamp(widget.thumbSize, _maxStretchHeight);
          if (_indicatorHeight == _maxStretchHeight) {
            _verticalAllowed = false;
            _horizontalAllowed = false;
            Future<void>.delayed(SafeSliderDefaults.labelBounceDelay, () {
              if (mounted) {
                setState(() {
                  _labelAlignment = Alignment.topCenter;
                });
              }
            });
            Future<void>.delayed(SafeSliderDefaults.unlockDelay, () {
              if (mounted) _isUnlocked = true;
            });
          }

        default:
          break;
      }
    });
  }
}
