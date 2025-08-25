import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qubic_ai/core/utils/extensions/extensions.dart';
import 'package:qubic_ai/core/utils/helper/custom_toast.dart';
import 'package:qubic_ai/core/utils/helper/regexp_methods.dart';

import '../../../core/themes/colors.dart';
import '../../../core/utils/helper/clipboard.dart';
import '../../../core/utils/helper/url_launcher.dart';
import '../../../core/widgets/code_block_builder.dart';

class AIBubble extends StatefulWidget {
  const AIBubble(
      {super.key, required this.message, required this.time, this.isStreaming});

  final String message;
  final String time;
  final bool? isStreaming;

  @override
  State<AIBubble> createState() => _AIBubbleState();
}

class _AIBubbleState extends State<AIBubble> {
  bool _isShowDateTime = false;
  bool _isCopyMessage = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: (widget.message.isNotEmpty)
          ? GestureDetector(
              onTap: _showDate,
              onDoubleTap: _showDate,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMessageCard(),
                  SizedBox(height: 5.h),
                  _buildInfoRow(),
                ],
              ).withOnlyPadding(left: 12.w, top: 7.h, bottom: 7.h),
            )
          : const SizedBox.shrink(),
    );
  }

  void _showDate() {
    _isShowDateTime = !_isShowDateTime;
    setState(() {});
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

  Widget _buildMessageCard() => AnimatedContainer(
        duration: Duration(milliseconds: widget.isStreaming == true ? 300 : 0),
        constraints: BoxConstraints(maxWidth: context.width / 1.2),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: const Radius.circular(16),
              bottomRight: const Radius.circular(16),
              topLeft: const Radius.circular(16),
              bottomLeft: widget.isStreaming == true
                  ? const Radius.circular(16)
                  : Radius.zero),
          color: ColorManager.dark,
          boxShadow: widget.isStreaming == true
              ? [
                  const BoxShadow(
                    color: ColorManager.purple,
                    blurRadius: 30,
                    offset: Offset(0, 0),
                  ),
                ]
              : null,
        ),
        child: TextSelectionTheme(
          data: context.theme.textSelectionTheme,
          child: SelectionArea(
            child: _buildMarkdownBody(),
          ),
        ),
      );

  Widget _buildInfoRow() => Row(
        children: [
          Text(
            "AI",
            style: context.textTheme.bodySmall,
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            curve: Curves.ease,
            opacity: _isShowDateTime ? 1 : 0,
            child: AnimatedContainer(
              curve: Curves.ease,
              duration: const Duration(milliseconds: 250),
              height: _isShowDateTime ? 18.h : 0.0,
              padding: EdgeInsets.only(left: 16.w),
              child: Row(
                children: [
                  Text(
                    RegExpManager.formatDateTime(widget.time),
                    style: context.textTheme.bodySmall,
                  ),
                  SizedBox(width: 15.w),
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
                ],
              ),
            ),
          ),
        ],
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
          'pre': PreBlockBuilder(context),
          'code': InlineCodeBuilder(),
        },
      );
}
