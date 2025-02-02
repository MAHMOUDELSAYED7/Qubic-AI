import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:qubic_ai/core/utils/extension/extension.dart';

import '../../../core/di/get_it.dart';
import '../../../core/utils/constants/colors.dart';
import '../../viewmodel/chat/chat_bloc.dart';
import '../../viewmodel/validation/validation_cubit.dart';

class BuildInputField extends StatefulWidget {
  const BuildInputField(
      {super.key,
      required this.generativeAIBloc,
      required this.isLoading,
      required this.chatId,
      required this.isChatHistory});

  final ChatAIBloc generativeAIBloc;
  final bool isLoading;
  final int? chatId;
  final bool isChatHistory;

  @override
  State<BuildInputField> createState() => _BuildInputFieldState();
}

class _BuildInputFieldState extends State<BuildInputField> {
  late TextEditingController _textInputFieldController;

  @override
  void initState() {
    super.initState();
    _textInputFieldController = TextEditingController();
  }

  void _sendMessage() {
    if (_textInputFieldController.text.trim().isNotEmpty) {
      widget.generativeAIBloc.add(
        StreamDataEvent(
          prompt: _textInputFieldController.text.trim(),
          isUser: true,
          chatId: widget.chatId ?? 0,
        ),
      );
      _textInputFieldController.clear();
    }
    setState(() {});
  }

  final _validationCubit = getIt<ValidationCubit>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          right: 9.w,
          left: 9.w,
          bottom: MediaQuery.of(context).viewInsets.bottom + 10.h),
      child: TextField(
        minLines: 1,
        maxLines: 4,
        onChanged: (text) {
          if (text.trim().length == 1 || text.trim().isEmpty) {
            setState(() {});
          }
        },
        style: context.textTheme.bodyMedium,
        controller: _textInputFieldController,
        textDirection:
            _validationCubit.getFieldDirection(_textInputFieldController.text),
        onSubmitted: (_) => !widget.isLoading ? _sendMessage() : null,
        decoration: InputDecoration(
          hintText: 'Message Qubic AI',
          suffixIcon: Padding(
            padding: EdgeInsets.all(5.w),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: widget.isLoading
                    ? ColorManager.white
                    : _textInputFieldController.text.trim().isEmpty
                        ? ColorManager.grey
                        : ColorManager.white,
              ),
              onPressed: () => !widget.isLoading ? _sendMessage() : null,
              icon: widget.isLoading
                  ? const SizedBox(
                      height: 25,
                      width: 25,
                      child: LoadingIndicator(
                        indicatorType: Indicator.lineSpinFadeLoader,
                      ),
                    )
                  : Icon(
                      Icons.arrow_upward_rounded,
                      color: ColorManager.dark,
                      size: 25,
                    ),
            ),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(5.w),
            child: !widget.isChatHistory
                ? IconButton(
                    onPressed: () => widget.generativeAIBloc
                        .add(CreateNewChatSessionEvent()),
                    icon: const Icon(
                      Icons.add,
                      color: ColorManager.white,
                      size: 25,
                    ),
                  )
                : null,
          ),
          enabledBorder: context.inputDecorationTheme.border,
          focusedBorder: context.inputDecorationTheme.border,
        ),
      ),
    );
  }
}
