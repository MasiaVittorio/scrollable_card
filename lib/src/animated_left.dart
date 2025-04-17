part of '../scrollable_card.dart';

class _AnimatedLeft extends StatelessWidget {
  const _AnimatedLeft({
    required this.controller,
    required this.child,
    required this.maxWidth,
    required this.translationFraction,
  });

  final AnimationController controller;
  final Widget child;
  final double maxWidth;
  final double translationFraction;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: Material(type: MaterialType.transparency, child: child),
      builder: (context, child) {
        final value = controller.value.clamp(-1.0, 0.0).abs();
        return Transform.translate(
          offset: Offset(
            value.rangeMapLoose(to: (-maxWidth * translationFraction, 0)),
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
