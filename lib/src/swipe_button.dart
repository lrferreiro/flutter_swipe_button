import 'dart:math';

import 'package:flutter/material.dart';

const double _defaultHeight = 50;
const double _defaultPadding = 6;

class SwipeButton extends StatefulWidget {
  final Widget child;
  final Icon? icon;
  final Color? color;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final double? innerPadding;
  final double? height;
  final Function()? onSwipe;

  const SwipeButton({
    Key? key,
    required this.child,
    this.icon,
    this.onSwipe,
    this.color,
    this.borderRadius,
    this.innerPadding,
    this.backgroundColor,
    this.height,
  }) : super(key: key);

  @override
  _SwipeState createState() => _SwipeState();
}

class _SwipeState extends State<SwipeButton> {
  Offset _offset = Offset.zero;
  bool _swiped = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: EdgeInsets.all(widget.innerPadding ?? _defaultPadding),
          width: constraints.maxWidth,
          height: widget.height ?? _defaultHeight,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(150),
            color: widget.backgroundColor ?? Color(0xFF212121),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Center(
                child: widget.child,
              ),
              Positioned(
                left: _offset.dx,
                top: _offset.dy,
                child: GestureDetector(
                  onHorizontalDragStart: (details) {
                    setState(() {
                      _swiped = false;
                    });
                  },
                  onHorizontalDragUpdate: (details) {
                    if (_offset.dx + details.delta.dx > 0 && !_swiped) {
                      setState(() {
                        double dx = min(
                          _offset.dx + details.delta.dx,
                          constraints.maxWidth -
                              (widget.height ?? _defaultHeight),
                        );
                        _offset = Offset(dx, 0);

                        if (_offset.dx ==
                                constraints.maxWidth -
                                    (widget.height ?? _defaultHeight) &&
                            !_swiped) {
                          _swiped = true;
                          widget.onSwipe?.call();
                        }
                      });
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    setState(() {
                      _offset = Offset.zero;
                    });
                  },
                  child: Container(
                    width: (widget.height ?? _defaultHeight) -
                        (widget.innerPadding ?? _defaultPadding) * 2,
                    height: (widget.height ?? _defaultHeight) -
                        (widget.innerPadding ?? _defaultPadding) * 2,
                    decoration: BoxDecoration(
                      borderRadius:
                          widget.borderRadius ?? BorderRadius.circular(150),
                      color: widget.color ?? Color(0xFFEEEEEE),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Center(
                      child: widget.icon ??
                          Icon(
                            Icons.arrow_forward,
                            color: widget.backgroundColor ?? Color(0xFF212121),
                          ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
