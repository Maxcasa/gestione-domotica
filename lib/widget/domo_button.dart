import 'package:flutter/material.dart';

// factory ElevatedButton.icon({
//   Key? key,
//   required VoidCallback? onPressed,
//   VoidCallback? onLongPress,
//   ValueChanged<bool>? onHover,
//   ValueChanged<bool>? onFocusChange,
//   ButtonStyle? style,
//   FocusNode? focusNode,
//   bool? autofocus,
//   Clip? clipBehavior,
//   required Widget icon,
//   required Widget label,
// }) = _ElevatedButtonWithIcon;

class DomoButtonWithIcon extends ElevatedButton {
  DomoButtonWithIcon({
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHover,
    ValueChanged<bool>? onFocusChange,
    ButtonStyle? style,
    FocusNode? focusNode,
    bool? autofocus,
    Clip? clipBehavior,
    required Widget icon,
    //required Widget label,
  }) : super(
          key: key,
          onPressed: onPressed,
          onLongPress: onLongPress,
          onHover: onHover,
          onFocusChange: onFocusChange,
          style: style,
          focusNode: focusNode,
          autofocus: autofocus ?? false,
          clipBehavior: clipBehavior ?? Clip.none,
          child: _DomodButtonChild(icon: icon),
        );
}

class _DomodButtonChild extends StatelessWidget {
  const _DomodButtonChild({Key? key, required this.icon}) : super(key: key);

  final Widget icon;

  @override
  Widget build(BuildContext context) {
    // final double scale = MediaQuery.maybeOf(context)?.textScaleFactor ?? 1;
    // final double gap = scale <= 1 ? 8 : lerpDouble(8, 4, math.min(scale - 1, 1))!;
    return icon;
  }
}
