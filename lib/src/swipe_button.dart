import 'dart:math';

import 'package:flutter/material.dart';

const double _velocity = 1.1;

enum _SwipeButtonType {
  swipe,
  expand,
}

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

  final double elevationThumb;
  final double elevationTrack;

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
    this.elevationThumb = 0,
    this.elevationTrack = 0,
    this.onSwipeStart,
    this.onSwipe,
    this.onSwipeEnd,
  })  : assert(elevationThumb >= 0.0),
        assert(elevationTrack >= 0.0),
        _swipeButtonType = _SwipeButtonType.swipe,
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
    this.elevationThumb = 0,
    this.elevationTrack = 0,
    this.onSwipeStart,
    this.onSwipe,
    this.onSwipeEnd,
  })  : assert(elevationThumb >= 0.0),
        assert(elevationTrack >= 0.0),
        _swipeButtonType = _SwipeButtonType.expand,
        super(key: key);

  @override
  State<SwipeButton> createState() => _SwipeState();
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
    return SizedBox(
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
    final elevationTrack = widget.enabled ? widget.elevationTrack : 0.0;

    return Padding(
      padding: widget.trackPadding,
      child: Material(
        elevation: elevationTrack,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
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
      ),
    );
  }

  Widget _buildThumb(BuildContext context, BoxConstraints constraints) {
    final ThemeData theme = Theme.of(context);

    final thumbColor = widget.enabled
        ? widget.activeThumbColor ?? theme.colorScheme.secondary
        : widget.inactiveThumbColor ?? theme.disabledColor;

    final borderRadius = widget.borderRadius ?? BorderRadius.circular(150);

    final elevationThumb = widget.enabled ? widget.elevationThumb : 0.0;

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
            elevation: elevationThumb,
            borderRadius: borderRadius,
            color: thumbColor,
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
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
      case _SwipeButtonType.swipe:
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
      case _SwipeButtonType.expand:
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
