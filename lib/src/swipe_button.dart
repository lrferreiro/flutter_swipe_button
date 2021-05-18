import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const double _velocity = 1.1;

enum _SwipeButtonType { Swipe, Expand }

class SwipeButton extends StatefulWidget {
  final Widget child;
  final Widget? thumb;

  final Color? activeThumbColor;
  final Color? inactiveThumbColor;
  final EdgeInsets thumbPadding;

  final Color? activeTrackColor;
  final Color? inactiveTrackColor;
  final EdgeInsets trackPadding;

  final BorderRadius? borderRadius;

  final double width;
  final double height;

  final bool enabled;

  final double elevation;

  final Function()? onSwipeStart;
  final Function()? onSwipe;
  final Function()? onSwipeEnd;

  final _SwipeButtonType _swipeButtonType;

  const SwipeButton({
    Key? key,
    required this.child,
    this.thumb,
    this.activeThumbColor,
    this.inactiveThumbColor,
    this.thumbPadding = EdgeInsets.zero,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.trackPadding = EdgeInsets.zero,
    this.borderRadius,
    this.width = double.infinity,
    this.height = 50,
    this.enabled = true,
    this.elevation = 0,
    this.onSwipeStart,
    this.onSwipe,
    this.onSwipeEnd,
  })  : assert(elevation >= 0.0),
        _swipeButtonType = _SwipeButtonType.Swipe,
        super(key: key);

  const SwipeButton.expand({
    Key? key,
    required this.child,
    this.thumb,
    this.activeThumbColor,
    this.inactiveThumbColor,
    this.thumbPadding = EdgeInsets.zero,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.trackPadding = EdgeInsets.zero,
    this.borderRadius,
    this.width = double.infinity,
    this.height = 50,
    this.enabled = true,
    this.elevation = 0,
    this.onSwipeStart,
    this.onSwipe,
    this.onSwipeEnd,
  })  : assert(elevation >= 0.0),
        _swipeButtonType = _SwipeButtonType.Expand,
        super(key: key);

  @override
  _SwipeState createState() => _SwipeState();
}

class _SwipeState extends State<SwipeButton> {
  Offset _offset = Offset.zero;
  double _width = 0;

  bool _swiped = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              _buildTrack(context, constraints),
              _buildThumb(context, constraints),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTrack(BuildContext context, BoxConstraints constraints) {
    final ThemeData theme = Theme.of(context);

    final trackColor = widget.enabled
        ? widget.activeTrackColor ?? theme.backgroundColor
        : widget.inactiveTrackColor ?? theme.disabledColor;

    final borderRadius = widget.borderRadius ?? BorderRadius.circular(150);

    return Container(
      padding: widget.trackPadding,
      child: Container(
        width: constraints.maxWidth,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: trackColor,
        ),
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }

  Widget _buildThumb(BuildContext context, BoxConstraints constraints) {
    final ThemeData theme = Theme.of(context);

    final thumbColor = widget.enabled
        ? widget.activeThumbColor ?? theme.accentColor
        : widget.inactiveThumbColor ?? theme.disabledColor;

    final borderRadius = widget.borderRadius ?? BorderRadius.circular(150);

    final elevation = widget.enabled ? widget.elevation : 0.0;

    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: Container(
        padding: widget.thumbPadding,
        child: GestureDetector(
          onHorizontalDragStart: _onHorizontalDragStart,
          onHorizontalDragUpdate: (details) =>
              _onHorizontalDragUpdate(details, constraints.maxWidth),
          onHorizontalDragEnd: _onHorizontalDragEnd,
          child: Material(
            elevation: elevation,
            borderRadius: borderRadius,
            color: thumbColor,
            clipBehavior: Clip.antiAlias,
            child: Container(
              width:
                  max(widget.height, _width) - widget.thumbPadding.horizontal,
              height: widget.height - widget.thumbPadding.vertical,
              child: widget.thumb ??
                  Icon(
                    Icons.arrow_forward,
                    color: widget.activeTrackColor ?? widget.inactiveTrackColor,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  _onHorizontalDragStart(DragStartDetails details) {
    setState(() {
      _swiped = false;
    });
    widget.onSwipeStart?.call();
  }

  _onHorizontalDragUpdate(DragUpdateDetails details, double width) {
    switch (widget._swipeButtonType) {
      case _SwipeButtonType.Swipe:
        if (_offset.dx + details.delta.dx > 0 && !_swiped && widget.enabled) {
          setState(() {
            double dx = min(
              _offset.dx + details.delta.dx * _velocity,
              width - widget.height,
            );
            _offset = Offset(dx, 0);

            if (_offset.dx == width - widget.height && !_swiped) {
              _swiped = true;
              widget.onSwipe?.call();
            }
          });
        }
        break;
      case _SwipeButtonType.Expand:
        if (_width + details.delta.dx > 0 && !_swiped && widget.enabled) {
          setState(() {
            _width = _width + details.delta.dx * _velocity;

            if (_width >= width - widget.trackPadding.horizontal && !_swiped) {
              _swiped = true;
              widget.onSwipe?.call();
            }
          });
        }
        break;
    }
  }

  _onHorizontalDragEnd(DragEndDetails details) {
    setState(() {
      _offset = Offset.zero;
      _width = 0;
    });
    widget.onSwipeEnd?.call();
  }
}
