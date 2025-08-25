import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qubic_ai/core/utils/extensions/extensions.dart';
import 'package:qubic_ai/core/utils/helper/custom_toast.dart';

import '../../../core/themes/colors.dart';
import '../../../core/utils/helper/clipboard.dart';
import '../../../core/utils/helper/regexp_methods.dart';
import '../../../core/utils/helper/url_launcher.dart';
import '../../../core/widgets/code_block_builder.dart';

class UserBubble extends StatefulWidget {
  const UserBubble({
    super.key,
    required this.message,
    required this.time,
    this.image,
  });

  final String message;
  final String time;
  final String? image;

  @override
  State<UserBubble> createState() => _UserBubbleState();
}

class _UserBubbleState extends State<UserBubble> {
  bool _isShowDateTime = false;
  bool _isCopyMessage = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showDate,
      onDoubleTap: _showDate,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildMessageCard(),
          SizedBox(height: 5.h),
          _buildInfoRow(),
        ],
      ).withOnlyPadding(right: 12.w, top: 7.h, bottom: 7.h),
    );
  }

  void _copyToClipboard() {
    ClipboardManager.copyToClipboard(widget.message);
    showCustomToast(context, message: "Copied to clipboard");
    _isCopyMessage = true;
    setState(() {});
    Future.delayed(const Duration(milliseconds: 2500), () {
      _isCopyMessage = false;
      setState(() {});
    });
  }

  void _showDate() {
    _isShowDateTime = !_isShowDateTime;
    setState(() {});
  }

  Future<void> _showImage() async {
    if (widget.image == null || !File(widget.image!).existsSync()) {
      showCustomToast(context,
          message: "Image not found", color: ColorManager.error);
      return;
    }

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ZoomIn(
          duration: const Duration(milliseconds: 200),
          child: InteractiveViewer(
            child: Image.file(
              File(widget.image!),
              fit: BoxFit.contain,
            ),
          ).withSymmetricPadding(horizontal: 14).center(),
        );
      },
    );
  }

  Widget _buildMessageCard() => Container(
        constraints: BoxConstraints(maxWidth: context.width / 1.3),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            topLeft: Radius.circular(16),
          ),
          color: ColorManager.dark,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.image != null) ...[
              if (File(widget.image!).existsSync()) ...[
                Image.file(
                  File(widget.image!),
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                )
                    .circular(8)
                    .withWidth(double.infinity)
                    .center()
                    .onTapAndLongPress(
                      onTap: _showImage,
                      onLongPress: _showImage,
                    )
                    .withOnlyPadding(bottom: 8),
              ] else ...[
                const Icon(
                  Icons.broken_image_rounded,
                  size: 35,
                ).withSquareSize(200).center()
              ]
            ],
            TextSelectionTheme(
              data: context.theme.textSelectionTheme,
              child: SelectionArea(
                child: _buildMarkdownBody(),
              ),
            ),
          ],
        ),
      );

  Widget _buildMarkdownBody() => MarkdownBody(
        data: widget.message,
        styleSheet: MarkdownStyleSheet.fromTheme(context.theme).copyWith(
          p: context.textTheme.bodySmall?.copyWith(
            color: ColorManager.white,
          ),
          strong: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: ColorManager.white,
          ),
          em: context.textTheme.bodySmall?.copyWith(
            fontStyle: FontStyle.italic,
            color: ColorManager.white,
          ),
          code: context.textTheme.bodySmall?.copyWith(
            backgroundColor: Colors.grey[800],
            color: ColorManager.white,
          ),
          tableBody: context.textTheme.bodySmall?.copyWith(
            color: ColorManager.white,
            fontSize: 12,
          ),
          tableHead: context.textTheme.bodySmall?.copyWith(
            color: ColorManager.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          tablePadding: EdgeInsets.zero,
          tableCellsPadding:
              const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        ),
        onTapLink: (text, href, title) {
          if (href != null) {
            UrlManager.launch(href);
          }
        },
        builders: {
          'pre': PreBlockBuilder(),
          'code': InlineCodeBuilder(),
        },
      );

  Widget _buildInfoRow() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 10),
            curve: Curves.ease,
            opacity: _isShowDateTime ? 1 : 0,
            child: AnimatedContainer(
              curve: Curves.ease,
              duration: const Duration(milliseconds: 250),
              height: _isShowDateTime ? 18.h : 0.0,
              padding: EdgeInsets.only(right: 16.w),
              child: Row(
                children: [
                  if (widget.message.isNotEmpty)
                    GestureDetector(
                      onTap: _isCopyMessage ? null : _copyToClipboard,
                      child: Icon(
                        _isCopyMessage
                            ? Icons.done_rounded
                            : Icons.copy_all_rounded,
                        size: 20,
                        color: ColorManager.white,
                      ),
                    ),
                  SizedBox(width: 15.w),
                  Text(
                    RegExpManager.formatDateTime(widget.time),
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          Text(
            "You",
            style: context.textTheme.bodySmall,
          ),
        ],
      );
}
