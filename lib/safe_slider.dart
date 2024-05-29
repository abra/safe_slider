import 'dart:math';

import 'package:flutter/material.dart';

class SafeSlider extends StatefulWidget {
  const SafeSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.min = 0.0,
    this.max = 1.0,
    this.activeColor = const Color(0xFF323A46),
    this.inactiveColor = const Color(0xFFE1E1E1),
    this.warningColor = const Color(0xFFFF5959),
    this.thumbSize = 50.0,
    this.strokeWidth = 2.0,
    this.width,
  }) : assert(min <= max);

  final double value;
  final ValueChanged<double> onChanged;
  final String? label;
  final double min;
  final double max;
  final Color activeColor;
  final Color inactiveColor;
  final Color warningColor;
  final double thumbSize;
  final double strokeWidth;
  final double? width;

  @override
  State<SafeSlider> createState() => _SafeSliderState();
}

class _SafeSliderState extends State<SafeSlider> with TickerProviderStateMixin {
  double _dragPosition = 0.0;
  final LayerLink _layerLink = LayerLink();
  late double _width;
  late double _height;
  late double _strokeWidth;
  late double _padding;
  late Color _activeColor;
  late Color _inactiveColor;
  late Color _warningColor;
  late OverlayPortalController _overlayPortalController;

  @override
  void initState() {
    super.initState();
    // Initialize colors and overlay portal controller
    _activeColor = widget.activeColor;
    _inactiveColor = widget.inactiveColor;
    _warningColor = widget.warningColor;
    _overlayPortalController = OverlayPortalController();
    _overlayPortalController.show();
  }

  @override
  void dispose() {
    super.dispose();
    _overlayPortalController.hide();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          _width = widget.width ?? constraints.maxWidth;
          _height = widget.thumbSize;
          _padding = _height / 2;
          _strokeWidth = widget.strokeWidth;

          return Center(
            child: SizedBox(
              width: _width,
              height: _height,
              child: CompositedTransformTarget(
                link: _layerLink,
                child: OverlayPortal(
                  controller: _overlayPortalController,
                  overlayChildBuilder: (context) => _IndicatorContainer(
                    strokeWidth: _strokeWidth,
                    activeColor: widget.activeColor,
                    inactiveColor: widget.inactiveColor,
                    warningColor: widget.warningColor,
                    label: (_dragPosition / (_width - _padding * 2))
                        .toStringAsFixed(2),
                    link: _layerLink,
                    onPrevented: (value) {
                      // Update drag position and call onChanged callback
                      setState(() {
                        if (value == _activeColor) {
                          _activeColor = widget.activeColor;
                        } else {
                          _activeColor = value;
                        }
                      });
                    },
                    onDragged: (value) {
                      // Update drag position and call onChanged callback
                      widget.onChanged(value);
                      setState(() {
                        _dragPosition = (value * (_width - _padding * 2));
                      });
                    },
                    height: _height,
                    width: _width,
                    size: _height,
                  ),
                  child: CustomPaint(
                    size: Size(_width, _height),
                    painter: _TrackPainter(
                      sliderPosition: _dragPosition,
                      inactiveColor: _inactiveColor,
                      activeColor: _activeColor,
                      strokeWidth: _strokeWidth,
                      padding: _padding,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
}

class _TrackPainter extends CustomPainter {
  _TrackPainter({
    required this.sliderPosition,
    required this.inactiveColor,
    required this.activeColor,
    required this.strokeWidth,
    required this.padding,
  })  : activePartPaint = Paint()
          ..color = activeColor
          ..style = PaintingStyle.fill
          ..strokeWidth = strokeWidth,
        inactivePartPaint = Paint()
          ..color = inactiveColor
          ..style = PaintingStyle.fill
          ..strokeWidth = strokeWidth;

  final double sliderPosition;
  final Paint activePartPaint;
  final Paint inactivePartPaint;
  final double strokeWidth;
  final double padding;
  final Color inactiveColor;
  final Color activeColor;

  // Draw left padding of the track
  void _drawLeftPadding(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(padding, size.height / 2),
      activePartPaint,
    );
  }

  // Draw right padding of the track
  void _drawRightPadding(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(size.width - padding, size.height / 2),
      Offset(size.width, size.height / 2),
      inactivePartPaint,
    );
  }

  // Draw active part of the track
  void _drawActivePart(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(padding, size.height / 2),
      Offset(sliderPosition + padding, size.height / 2),
      activePartPaint,
    );
  }

  // Draw inactive part of the track
  void _drawInactivePart(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(sliderPosition + padding, size.height / 2),
      Offset(size.width - padding, size.height / 2),
      inactivePartPaint,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Draw different parts of the track
    _drawLeftPadding(canvas, size);
    _drawActivePart(canvas, size);
    _drawInactivePart(canvas, size);
    _drawRightPadding(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

enum Direction {
  left,
  right,
  up,
  down,
}

class _IndicatorContainer extends StatefulWidget {
  const _IndicatorContainer({
    required this.strokeWidth,
    required this.activeColor,
    required this.inactiveColor,
    required this.warningColor,
    required this.label,
    required this.link,
    required this.height,
    required this.width,
    required this.size,
    required this.onDragged,
    required this.onPrevented,
  });

  final double strokeWidth;
  final Color activeColor;
  final Color inactiveColor;
  final Color warningColor;
  final String label;
  final LayerLink link;
  final double height;
  final double width;
  final double size;
  final ValueChanged<double> onDragged;
  final ValueChanged<Color> onPrevented;

  @override
  State<_IndicatorContainer> createState() => _IndicatorContainerState();
}

class _IndicatorContainerState extends State<_IndicatorContainer> {
  late Color _activeColor;
  late double _strokeWidth;
  late double _indicatorHeight;
  late double _indicatorWidth;
  late double _width;
  late final double _padding;
  late final double _maxWidth;
  late final double _maxHeight;
  bool _canDrag = false;
  bool _isHorizontalDrag = true;
  bool _isVerticalDrag = true;
  GlobalKey textKey = GlobalKey();
  double _labelHorizontalPadding = 0;
  double _labelVerticalPadding = 0;
  AlignmentGeometry _labelAlignment = Alignment.center;
  AlignmentGeometry _indicatorAlignment = Alignment.centerLeft;
  double _leftPadding = 0;
  double _rightPadding = 0;
  Direction? _direction;
  Offset _startPosition = const Offset(0, 0);
  final double _maxStretchRatio = 1.8;
  late Offset _offset;
  double? _left;
  double? _right;

  @override
  void initState() {
    super.initState();
    // Initialize indicator properties and calculate label padding
    _activeColor = widget.activeColor;
    _strokeWidth = widget.strokeWidth;
    _indicatorHeight = widget.size;
    _indicatorWidth = widget.size;
    _maxHeight = widget.height * _maxStretchRatio;
    _maxWidth = widget.height * _maxStretchRatio;
    _padding = widget.size / 2;
    _width = widget.width;
    _offset = Offset(_padding, 0);
  }

  @override
  Widget build(BuildContext context) {
    _calculateLabelPadding();

    return Center(
      child: CompositedTransformFollower(
        // Subtract padding to center the indicator with the thumb
        link: widget.link,
        child: Container(
          padding: EdgeInsets.only(
            left: _leftPadding,
            right: _rightPadding,
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
                  left: _left,
                  right: _right,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: _indicatorHeight,
                    width: _indicatorWidth,
                    padding: EdgeInsets.symmetric(
                      horizontal: _labelHorizontalPadding,
                      vertical: _labelVerticalPadding,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_padding),
                      border: Border.all(
                        color: _activeColor,
                        width: _strokeWidth,
                      ),
                      color: Colors.white,
                    ),
                    child: AnimatedAlign(
                      alignment: _labelAlignment,
                      duration: const Duration(milliseconds: 1100),
                      curve: Curves.elasticOut,
                      child: FittedBox(
                        child: Text(
                          key: textKey,
                          widget.label,
                          style: TextStyle(
                            color: _activeColor,
                            fontSize: 18,
                            fontFamily: 'DroidSansMono',
                            fontWeight: FontWeight.w700,
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

  void _calculateLabelPadding() {
    final keyContext = textKey.currentContext;

    if (keyContext != null) {
      final RenderBox box = keyContext.findRenderObject() as RenderBox;
      _labelHorizontalPadding =
          ((widget.size - box.size.width) / 2) - _strokeWidth;
      _labelVerticalPadding =
          ((widget.size - box.size.height) / 2) - _strokeWidth;
    }
  }

  void _onPanDragEnd(DragEndDetails details) {
    setState(() {
      // Reset indicator properties after drag ends
      if (!_canDrag) {
        _activeColor = widget.activeColor;
        widget.onPrevented(widget.activeColor);
      }
      _indicatorWidth = _padding * 2;
      _indicatorHeight = _padding * 2;
      _isHorizontalDrag = true;
      _isVerticalDrag = true;
      _startPosition = const Offset(0, 0);
      _direction = null;
      _leftPadding = 0;
      _rightPadding = 0;
      _canDrag = false;
    });
  }

  void _onPanDragStart(DragStartDetails details) {
    setState(() {
      // Store start position of the drag
      _startPosition = Offset(
        details.localPosition.dx,
        details.localPosition.dy,
      );
      if (_isVerticalDrag) {
        _indicatorAlignment = Alignment.topLeft;
      } else {
        _indicatorAlignment = Alignment.centerLeft;
      }
    });
  }

  void _onPanDragUpdate(DragUpdateDetails details) {
    if (_canDrag) {
      final offset = _offset;
      // Handle drag update when dragging is allowed
      final percentage = (offset.dx - _padding) / (_width - (_padding * 2));
      widget.onDragged(percentage);
      _offset = Offset(offset.dx + details.delta.dx, 0);
      _left = offset.dx - _padding;
      _right = _width - offset.dx - _padding;
      setState(() {
        _offset = Offset(
          _offset.dx.clamp(_padding, _width - _padding),
          _offset.dy,
        );
      });
    } else {
      final offset = _offset;
      // Handle drag update when dragging is not allowed (stretching)
      Offset currentPosition = Offset(
        details.localPosition.dx,
        details.localPosition.dy,
      );

      // Calculate the angle between the current position and the start position
      final dy = currentPosition.dy - _startPosition.dy;
      final dx = currentPosition.dx - _startPosition.dx;
      final horizontalAngle = (atan(dy / dx) * (180 / pi)).abs();
      final verticalAngle = (atan(dx / dy) * (180 / pi)).abs();

      // If the angle is greater than 20 degrees, we can't drag the indicator
      if (horizontalAngle > 25) {
        setState(() {
          _isHorizontalDrag = false;
        });
      }
      if (verticalAngle > 25) {
        setState(() {
          _isVerticalDrag = false;
        });
      }

      // Remove a padding to determine the offset relative to zero
      final isRightDirection =
          _startPosition.dx - _padding < currentPosition.dx - _padding &&
              _direction == null &&
              _isHorizontalDrag;
      final isLeftDirection =
          _startPosition.dx - _padding > currentPosition.dx - _padding &&
              _direction == null &&
              _isHorizontalDrag;
      final isDownDirection = _startPosition.dy < currentPosition.dy &&
          _direction == null &&
          _isVerticalDrag;

      // Determining the direction of the indicator offset with your finger
      if (isRightDirection) {
        setState(() {
          _direction = Direction.right;
          _indicatorAlignment = Alignment.centerLeft;
          _leftPadding = 0;
          _rightPadding = 0;
        });
      } else if (isLeftDirection) {
        setState(() {
          _direction = Direction.left;
          _indicatorAlignment = Alignment.centerRight;
          _leftPadding = 0;
          _rightPadding = 0;
        });
      } else if (isDownDirection) {
        setState(() {
          _direction = Direction.down;
        });
      }

      // If the indicator is moving right
      if (_direction == Direction.right && _isHorizontalDrag) {
        // If the indicator is in the warning color
        if (_activeColor != widget.warningColor) {
          _activeColor = widget.warningColor;
          widget.onPrevented(widget.warningColor);
        }
        setState(() {
          _labelAlignment = Alignment.centerRight;

          _right = null;
          _left = offset.dx - _padding;

          _indicatorWidth = (_indicatorWidth + details.delta.dx)
              .clamp(widget.size, _width - _left!);

          final widthExceeded = _indicatorWidth >= _maxWidth ||
              _left! + _indicatorWidth >= _width;

          if (widthExceeded) {
            _isHorizontalDrag = false;
            _isVerticalDrag = false;
            _labelAlignment = Alignment.centerLeft;
          }
        });
      }
      // If the indicator is moving left
      else if (_direction == Direction.left && _isHorizontalDrag) {
        if (_activeColor != widget.warningColor) {
          _activeColor = widget.warningColor;
          widget.onPrevented(widget.warningColor);
        }
        setState(() {
          _labelAlignment = Alignment.centerLeft;

          _left = null;
          _right = _width - offset.dx - _padding;

          _indicatorWidth = (_indicatorWidth - details.delta.dx)
              .clamp(widget.size, _width - _right!);

          final widthExceeded = _indicatorWidth >= _maxWidth ||
              _right! + _indicatorWidth >= _width;

          if (widthExceeded) {
            _isHorizontalDrag = false;
            _isVerticalDrag = false;
            _labelAlignment = Alignment.centerRight;
          }
        });
      }
      // If the indicator is moving down
      else if (_direction == Direction.down && _isVerticalDrag) {
        setState(() {
          _labelAlignment = Alignment.bottomCenter;
          _indicatorHeight = (_indicatorHeight + details.delta.dy)
              .clamp(widget.size, _maxHeight);
          if (_indicatorHeight == _maxHeight) {
            _isVerticalDrag = false;
            _isHorizontalDrag = false;
            _labelAlignment = Alignment.topCenter;
            Future<void>.delayed(const Duration(milliseconds: 300), () {
              _canDrag = true;
            });
          }
        });
      }
    }
  }
}
