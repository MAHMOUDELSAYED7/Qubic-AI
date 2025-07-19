import 'package:flutter/material.dart';
import 'package:qubic_ai/core/utils/extensions/extensions.dart';

import '../themes/colors.dart';

class BuildFloatingActionButton extends StatelessWidget {
  const BuildFloatingActionButton({super.key, this.onPressed, this.iconData});

  final void Function()? onPressed;
  final IconData? iconData;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      shape: const CircleBorder(),
      splashColor: ColorManager.white.withOpacity(0.3),
      elevation: 2,
      onPressed: onPressed,
      backgroundColor: ColorManager.purple,
      child: Icon(
        iconData ?? Icons.arrow_downward,
        color: ColorManager.white,
      ),
    ).withOnlyPadding(bottom: 10);
  }
}
