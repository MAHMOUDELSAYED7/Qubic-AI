import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:qubic_ai/core/di/locator.dart';
import 'package:qubic_ai/core/service/text_recognition.dart';
import 'package:qubic_ai/core/utils/extensions/extensions.dart';

import '../../../core/service/image_packer.dart';
import '../../../core/themes/colors.dart';
import '../../../core/utils/helper/custom_toast.dart';
import '../../../core/utils/helper/regexp_methods.dart';
import '../../bloc/chat/chat_bloc.dart';
import '../../bloc/input/input_field_bloc.dart';
import '../../bloc/search/search_bloc.dart';
import '../../viewmodel/input_field_viewmodel.dart';

class BuildInputField extends StatefulWidget {
  const BuildInputField({
    super.key,
    required this.chatBloc,
    required this.isLoading,
    required this.chatId,
    required this.isChatHistory,
  });

  final ChatBloc chatBloc;
  final bool isLoading;
  final int? chatId;
  final bool isChatHistory;

  @override
  State<BuildInputField> createState() => _BuildInputFieldState();
}

class _BuildInputFieldState extends State<BuildInputField> {
  late InputFieldBloc _inputFieldBloc;
  late SearchBloc _searchBloc;
  late InputFieldViewModel _viewModel;
  late GlobalKey _popupMenuKey;

  @override
  void initState() {
    super.initState();
    _searchBloc = sl<SearchBloc>();
    _inputFieldBloc = sl<InputFieldBloc>();
    _viewModel = InputFieldViewModel(
      inputFieldBloc: _inputFieldBloc,
      chatBloc: widget.chatBloc,
      imagePickerService: sl<ImagePickerService>(),
      textRecognitionService: sl<TextRecognitionService>(),
    );
    _popupMenuKey = GlobalKey();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InputFieldBloc, InputFieldState>(
      bloc: _inputFieldBloc,
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.selectedImage != null) _buildImageCard(state),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(
                  right: 9, left: 9, bottom: context.viewInsetsBottom + 8),
              decoration: BoxDecoration(
                color: ColorManager.grey.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(30),
                border: _viewModel.textController.text.isNotEmpty
                    ? Border.all(
                        color: ColorManager.purple,
                        strokeAlign: BorderSide.strokeAlignInside)
                    : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildMenuButton(),
                  _buildTextField(),
                  _buildSendMessageButton(state),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMenuBox() {
    final menuItems = [
      _buildMenuItem("Camera", Icons.add_a_photo_outlined),
      _buildMenuItem("Image", Icons.add_photo_alternate_outlined),
      if (!widget.isChatHistory) _buildMenuItem("Chat", Icons.add_box_outlined),
    ];

    PopupMenu(
      context: context,
      config: const MenuConfig(
        itemWidth: 110,
        arrowHeight: 12,
        backgroundColor: Color(0xFF1F1F1F),
        lineColor: ColorManager.white,
        highlightColor: ColorManager.purple,
        type: MenuType.list,
      ),
      items: menuItems,
      onClickMenu: (item) async {
        bool? res = true;
        if (item.menuTitle == 'Camera') {
          res = await _viewModel.pickImage(ImageSource.camera);
        } else if (item.menuTitle == 'Image') {
          res = await _viewModel.pickImage(ImageSource.gallery);
        } else if (item.menuTitle == 'Chat') {
          widget.chatBloc.add(const CreateNewChatSessionEvent());
          _searchBloc.add(SearchQueryChanged(''));
        }
        if (res == null) {
          showCustomToast(context,
              message: 'Image not found',
              color: ColorManager.error,
              durationInMilliseconds: 3000);
        } else if (!res) {
          showCustomToast(context,
              message: 'No text extracted from the image',
              color: ColorManager.error);
        }
      },
    ).show(widgetKey: _popupMenuKey);
  }

  MenuItem _buildMenuItem(String title, IconData icon) {
    return MenuItem(
      title: title,
      textStyle: context.textTheme.bodySmall
          ?.copyWith(fontWeight: FontWeight.w500, fontSize: 11.spMin),
      image: FadeIn(child: Icon(icon, color: ColorManager.white, size: 22)),
    );
  }

  Widget _buildTextField() => Expanded(
        child: TextField(
          minLines: 1,
          maxLines: 8,
          style: context.textTheme.bodyMedium?.copyWith(fontSize: 15.spMin),
          controller: _viewModel.textController,
          textDirection:
              RegExpManager.getFieldDirection(_viewModel.textController.text),
          decoration: const InputDecoration(
            contentPadding:
                EdgeInsets.only(left: 10, right: 10, top: 18, bottom: 18),
            hintText: 'Message Qubic AI',
          ),
        ),
      );

  Widget _buildMenuButton() => BounceIn(
        child: IconButton(
          key: _popupMenuKey,
          onPressed: _showMenuBox,
          icon: const Icon(
            Icons.add,
            color: ColorManager.white,
            size: 25,
          ),
        ).withOnlyPadding(left: 5, top: 5, bottom: 5),
      );

  Widget _buildSendMessageButton(InputFieldState state) => BounceIn(
        child: IconButton(
          style: IconButton.styleFrom(
            enableFeedback: !widget.isLoading || state.selectedImage != null,
            overlayColor: _viewModel.textController.text.trim().isEmpty &&
                    state.selectedImage == null
                ? Colors.transparent
                : null,
            backgroundColor: widget.isLoading
                ? ColorManager.white
                : _viewModel.textController.text.trim().isEmpty &&
                        state.selectedImage == null
                    ? ColorManager.white.withValues(alpha: 0.5)
                    : ColorManager.white,
          ),
          onPressed: () => !widget.isLoading
              ? _viewModel.sendMessage(
                  chatId: widget.chatId,
                  isChatHistory: widget.isChatHistory,
                )
              : null,
          icon: widget.isLoading
              ? LoadingIndicator(
                  indicatorType: Indicator.ballBeat,
                ).withSize(width: 25, height: 25)
              : Icon(
                  Icons.arrow_upward_rounded,
                  color: ColorManager.dark,
                  size: 25,
                ),
        ).withAllPadding(5),
      );

  Widget _buildImageCard(InputFieldState state) => Stack(
        children: [
          Image.file(
            File(state.selectedImage!),
            fit: BoxFit.cover,
            width: 150,
            height: 100,
          ).circular(12),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: ColorManager.black.withValues(alpha: 0.4),
              ),
              icon: const Icon(
                Icons.close,
                color: ColorManager.white,
                size: 20,
              ),
              onPressed: () => _inputFieldBloc.add(
                  UpdateImageEvent(selectedImage: null, recognizedText: null)),
            ),
          ),
        ],
      ).withOnlyPadding(bottom: 8);
}
