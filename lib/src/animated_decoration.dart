part of '../scrollable_card.dart';

class _AnimatedDecoration extends StatelessWidget {
  const _AnimatedDecoration({
    required this.controller,
    required this.child,
    required this.unscrolledShape,
    required this.scrolledShape,
    required this.margin,
    required this.scrolledMargin,
    required this.backgroundColor,
    required this.scrolledBackgroundColor,
  });

  final AnimationController controller;
  final ShapeBorder unscrolledShape;
  final ShapeBorder scrolledShape;
  final EdgeInsets margin;
  final EdgeInsets scrolledMargin;
  final Color backgroundColor;
  final Color scrolledBackgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        final value = controller.value.abs();
        final shapeValue =
            ShapeBorder.lerp(unscrolledShape, scrolledShape, value)!;
        return Padding(
          padding: EdgeInsets.lerp(margin, scrolledMargin, value)!,
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: ShapeDecoration(shape: shapeValue),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                shape: shapeValue,
                color:
                    Color.lerp(
                      backgroundColor,
                      scrolledBackgroundColor,
                      value,
                    )!,
              ),
              child: child!,
            ),
          ),
        );
      },
    );
  }
}
