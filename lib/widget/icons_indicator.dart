import 'package:flutter/material.dart';
import 'dart:math';

/// An indicator showing the currently selected page of a PageController
class IconsIndicator extends AnimatedWidget {
  IconsIndicator({
    required this.controller,
    required this.iconsList,
    required this.onPageSelected,
    this.color = Colors.white,
  }) : super(listenable: controller);

  /// The PageController that this DotsIndicator is representing.
  final PageController controller;

  /// The number of items managed by the PageController
  final List<IconData> iconsList;

  /// Called when a dot is tapped
  final ValueChanged<int> onPageSelected;

  /// The color of the dots.
  ///
  /// Defaults to `Colors.white`.
  final Color color;

  // The base size of the dots
  static const double _kDotSize = 20.0;

  // The increase in the size of the selected dot
  static const double _kMaxZoom = 2.0;

  // The distance between the center of each dot
  static const double _kDotSpacing = 40.0;

  late BuildContext context;

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((controller.page ?? controller.initialPage) - index).abs(),
      ),
    );
    double zoom = 1.0 + (_kMaxZoom - 1.0) * selectedness;
    return Container(
      width: _kDotSpacing,
      color: Theme.of(context).primaryColor,
      child:
          //Center(
          // child: Material(
          //   color: color,
          //   //type: MaterialType.circle,
          //   child: new Container(
          //     width: _kDotSize * zoom,
          //     height: _kDotSize * zoom,
          //     child: new InkWell(
          //       onTap: () => onPageSelected(index),
          //     ),
          //   ),
          // ),

          //child:
          Material(
        child: Container(
          color: Theme.of(context).primaryColor,
          width: _kDotSize * zoom,
          height: _kDotSize * zoom,
          // padding: const EdgeInsets.only(
          //     right: _kDotSize * zoom,
          //     left: _kDotSize * zoom),
          child: IconButton(
            icon: Icon(iconsList[index], size: _kDotSize * zoom, color: color),
            onPressed: () => onPageSelected(index),
          ),
        ),
      ),
      //),
    );
  }

  Widget build(BuildContext context) {
    this.context = context;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(iconsList.length, _buildDot),
    );
  }
}
