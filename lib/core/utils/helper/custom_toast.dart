import 'package:flutter/material.dart';
import 'package:qubic_ai/core/utils/extensions/extensions.dart';

import '../../themes/colors.dart';

DateTime? _lastSnackBarTime;

void showCustomToast(
  BuildContext context, {
  String? message,
  Color? color,
  int? durationInMilliseconds,
}) {
  final now = DateTime.now();

  if (_lastSnackBarTime != null &&
      now.difference(_lastSnackBarTime!) < const Duration(seconds: 1)) {
    return;
  }

  _lastSnackBarTime = now;

  final overlay = Overlay.of(context);
  late final OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) => TopSnackBar(
      message: message ?? "There was an error, please try again later!",
      color: color ?? ColorManager.purple,
      durationInMilliseconds: durationInMilliseconds ?? 2500,
      onRemove: () => overlayEntry.remove(),
    ),
  );

  overlay.insert(overlayEntry);
}

class TopSnackBar extends StatefulWidget {
  final String message;
  final Color color;
  final int durationInMilliseconds;
  final VoidCallback onRemove;

  const TopSnackBar({
    super.key,
    required this.message,
    required this.color,
    required this.durationInMilliseconds,
    required this.onRemove,
  });

  @override
  State<TopSnackBar> createState() => _TopSnackBarState();
}

class _TopSnackBarState extends State<TopSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();

    _animation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    Future.delayed(Duration(milliseconds: widget.durationInMilliseconds), () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) {
            widget.onRemove();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = context.textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );

    const horizontalPadding = 32.0 * 2;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final availableContainerWidth = screenWidth * 0.8;

    double containerWidth = availableContainerWidth;

    if (textStyle != null) {
      final effectiveTextStyle = textStyle.copyWith(
        fontSize: textStyle.fontSize != null
            ? textStyle.fontSize! * mediaQuery.textScaler.textScaleFactor
            : null,
      );

      // Calculate intrinsic text width (single line)
      final textPainterIntrinsic = TextPainter(
        text: TextSpan(text: widget.message, style: effectiveTextStyle),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      );
      textPainterIntrinsic.layout();
      final intrinsicTextWidth = textPainterIntrinsic.width;
      final intrinsicContainerWidth = intrinsicTextWidth + horizontalPadding;

      if (intrinsicContainerWidth <= availableContainerWidth) {
        containerWidth = intrinsicContainerWidth;
      } else {
        final availableTextWidth = availableContainerWidth - horizontalPadding;
        final textPainterWrapped = TextPainter(
          text: TextSpan(text: widget.message, style: effectiveTextStyle),
          maxLines: 3,
          textDirection: TextDirection.ltr,
        );
        textPainterWrapped.layout(maxWidth: availableTextWidth);
        if (textPainterWrapped.didExceedMaxLines) {
          containerWidth = (intrinsicTextWidth + horizontalPadding).clamp(
            availableContainerWidth,
            screenWidth * 0.9,
          );
        } else {
          containerWidth = availableContainerWidth;
        }
      }

      containerWidth = containerWidth.clamp(0, screenWidth * 0.9);
    }

    return Positioned(
      top: 40,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SlideTransition(
            position: _animation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: containerWidth,
                color: widget.color.withValues(alpha: 0.95),
                child: Text(
                  widget.message,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ).center().withSymmetricPadding(vertical: 16, horizontal: 32),
              ).circular(25),
            ).withAllPadding(8.0),
          ),
        ],
      ),
    );
  }
}
