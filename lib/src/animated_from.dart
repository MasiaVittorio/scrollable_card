part of '../scrollable_card.dart';

class _AnimatedFrom extends StatelessWidget {
  const _AnimatedFrom.right({
    required this.controller,
    required this.child,
    required this.maxWidth,
    required this.translationFraction,
  }) : right = true;
  const _AnimatedFrom.left({
    required this.controller,
    required this.child,
    required this.maxWidth,
    required this.translationFraction,
  }) : right = false;

  final AnimationController controller;
  final Widget child;
  final double maxWidth;
  final double translationFraction;
  final bool right;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: Material(type: MaterialType.transparency, child: child),
      builder: (context, child) {
        final value =
            right
                ? controller.value.clamp(0.0, 1.0).abs()
                : controller.value.clamp(-1.0, 0.0).abs();
        return Transform.translate(
          offset: Offset(
            value.rangeMapLoose(
              to: ((right ? maxWidth : -maxWidth) * translationFraction, 0),
            ),
            0,
          ),
          child: Opacity(
            opacity: value.rangeMap(from: (0.55, 1)),
            child: IgnorePointer(ignoring: value.abs() < 0.9, child: child!),
          ),
        );
      },
    );
  }
}
