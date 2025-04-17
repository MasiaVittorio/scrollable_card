part of '../scrollable_card.dart';

class _AnimatedBody extends StatelessWidget {
  const _AnimatedBody({
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
      child: child,
      builder: (context, child) {
        final double value = controller.value;
        return Transform.translate(
          offset: Offset(
            -value.rangeMapLoose(to: (0, maxWidth * translationFraction)),
            0,
          ),
          child: Opacity(
            opacity: (1 - value.abs()).rangeMap(from: (0.45, 1)),
            child: IgnorePointer(ignoring: value.abs() > 0.1, child: child!),
          ),
        );
      },
    );
  }
}
