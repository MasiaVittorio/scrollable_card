// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sid_base/sid_base.dart';

part 'src/animated_body.dart';
part 'src/animated_decoration.dart';
part 'src/animated_from.dart';
part 'src/rest_body.dart';

typedef ScrolledBuilder =
    Widget Function(BuildContext context, VoidCallback unscroll);
typedef UnscrolledBuilder =
    Widget Function(
      BuildContext context,
      VoidCallback scrollFromRight,
      VoidCallback scrollFromLeft,
    );

class ScrollableCard extends StatefulWidget {
  const ScrollableCard({
    super.key,
    this.backgroundColor,
    this.scrolledBackgroundColor,
    this.shape = const RoundedRectangleBorder(),
    this.scrolledShape = const RoundedRectangleBorder(),
    required this.builder,
    this.fromRightBuilder,
    this.fromLeftBuilder,
    this.scrolledMargin = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.translationFraction = 0.25,
  });

  final Color? backgroundColor;
  final Color? scrolledBackgroundColor;
  final ShapeBorder shape;
  final ShapeBorder scrolledShape;
  final UnscrolledBuilder builder;
  final ScrolledBuilder? fromRightBuilder;
  final ScrolledBuilder? fromLeftBuilder;
  final EdgeInsets margin;
  final EdgeInsets scrolledMargin;
  final double translationFraction;

  @override
  State<ScrollableCard> createState() => _ScrollableCardState();
}

enum _CloseTo { center, scrollFromRight, scrollFromLeft }

enum _Going { fastFromLeft, fastFromRight, slow }

enum _Started { center, scrollFromRight, scrollFromLeft }

class _ScrollableCardState extends State<ScrollableCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    lowerBound: -1,
    upperBound: 1,
    value: 0,
    duration: Durations.long1,
  );

  bool get allowFromRight => widget.fromRightBuilder != null;
  bool get allowFromLeft => widget.fromLeftBuilder != null;

  void finishScrollFromRight() {
    if (!mounted) return;
    if (!allowFromRight) return;
    controller.animateTo(
      1.0,
      curve: Easings.emphasized,
      duration: Durations.medium3,
    );
  }

  void finishScrollFromLeft() {
    if (!mounted) return;
    if (!allowFromLeft) return;
    controller.animateTo(
      -1.0,
      curve: Easings.emphasized,
      duration: Durations.long1,
    );
  }

  void unscroll() {
    if (!mounted) return;
    controller.animateBack(
      0.0,
      curve: Easings.emphasized,
      duration: Durations.long1,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  double lastStartingValue = 0.0;
  Offset lastStartingOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;
    final Color backgroundColor =
        widget.backgroundColor ?? theme.colorScheme.surfaceContainerLow;
    final Color scrolledBackgroundColor =
        widget.scrolledBackgroundColor ??
        theme.colorScheme.surfaceContainerHighest;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;

        return ConstrainedBox(
          constraints: constraints,
          child: _AnimatedDecoration(
            controller: controller,
            unscrolledShape: widget.scrolledShape,
            scrolledShape: widget.scrolledShape,
            margin: widget.margin,
            scrolledMargin: widget.scrolledMargin,
            backgroundColor: backgroundColor,
            scrolledBackgroundColor: scrolledBackgroundColor,
            child: GestureDetector(
              onPanStart: onPanStart,
              onPanUpdate: (details) => onPanUpdate(details, maxWidth),
              onPanEnd: onPanEnd,
              child: Container(
                color: Colors.transparent, // important for the gesture detector
                child: Stack(
                  children: [
                    _AnimatedBody(
                      controller: controller,
                      maxWidth: maxWidth,
                      translationFraction: widget.translationFraction,
                      child: _RestBody(
                        width: maxWidth - widget.margin.horizontal,
                        collapsedContent: widget.builder(
                          context,
                          finishScrollFromRight,
                          finishScrollFromLeft,
                        ),
                      ),
                    ),
                    if (widget.fromRightBuilder case ScrolledBuilder builder)
                      Positioned.fill(
                        child: _AnimatedFrom.right(
                          translationFraction: widget.translationFraction,
                          controller: controller,
                          maxWidth: maxWidth,
                          child: builder(context, unscroll),
                        ),
                      ),
                    if (widget.fromLeftBuilder case ScrolledBuilder builder)
                      Positioned.fill(
                        child: _AnimatedFrom.left(
                          translationFraction: widget.translationFraction,
                          controller: controller,
                          maxWidth: maxWidth,
                          child: builder(context, unscroll),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void onPanStart(DragStartDetails details) {
    lastStartingOffset = details.localPosition;
    lastStartingValue = controller.value;
  }

  void onPanUpdate(DragUpdateDetails details, double maxWidth) {
    final Offset delta = details.localPosition - lastStartingOffset;
    final dx = delta.dx;
    final df = dx / maxWidth;
    final sign = -df.sign;
    final tdf = 1 - pow(2, -df.abs() * 10);
    final stdf = tdf * sign;
    controller.value = (lastStartingValue + stdf).clamp(
      allowFromLeft ? -1 : 0,
      allowFromRight ? 1 : 0,
    );
  }

  void onPanEnd(DragEndDetails details) {
    final double vx = details.velocity.pixelsPerSecond.dx;
    final _Started started = switch (lastStartingValue) {
      < -0.1 => _Started.scrollFromLeft,
      > 0.1 => _Started.scrollFromRight,
      _ => _Started.center,
    };

    const threshold = 750.0;
    final _Going going = switch (vx) {
      < -threshold => _Going.fastFromRight,
      > threshold => _Going.fastFromLeft,
      _ => _Going.slow,
    };
    final _CloseTo closeTo = switch (controller.value) {
      < -0.75 => _CloseTo.scrollFromLeft,
      > 0.75 => _CloseTo.scrollFromRight,
      _ => _CloseTo.center,
    };
    switch ((started, going, closeTo)) {
      case (
            _Started.scrollFromRight || _Started.center,
            _Going.fastFromRight,
            _,
          ) ||
          (
            _Started.center || _Started.scrollFromRight,
            _Going.slow,
            _CloseTo.scrollFromRight,
          ):
        finishScrollFromRight();
        return;
      case (
            _Started.scrollFromLeft || _Started.center,
            _Going.fastFromLeft,
            _,
          ) ||
          (
            _Started.center || _Started.scrollFromLeft,
            _Going.slow,
            _CloseTo.scrollFromLeft,
          ):
        finishScrollFromLeft();
        return;
      case (_, _Going.slow, _CloseTo.center) ||
          (_Started.scrollFromRight, _Going.fastFromLeft, _) ||
          (_Started.scrollFromLeft, _Going.fastFromRight, _) ||
          (_Started.scrollFromRight, _Going.slow, _CloseTo.scrollFromLeft) ||
          (_Started.scrollFromLeft, _Going.slow, _CloseTo.scrollFromRight):
        unscroll();
        return;
    }
  }
}
