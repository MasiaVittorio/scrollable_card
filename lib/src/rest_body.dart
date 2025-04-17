part of '../scrollable_card.dart';

class _RestBody extends StatelessWidget {
  const _RestBody({required this.width, required this.collapsedContent});

  final double width;
  final Widget collapsedContent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(type: MaterialType.transparency, child: collapsedContent),
    );
  }
}
