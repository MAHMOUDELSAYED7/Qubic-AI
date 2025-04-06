import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/themes/colors.dart';
import '../../core/utils/constants/images.dart';
import '../../core/utils/helper/custom_toast.dart';
import '../bloc/chat/chat_bloc.dart';
import '../viewmodel/chat_viewmodel.dart';
import 'widgets/build_chat_list_view.dart';
import '../../core/widgets/empty_body.dart';
import '../../core/widgets/floating_action_button.dart';
import 'widgets/input_field.dart';

class ChatScreen extends StatefulWidget {
  final int chatId;
  final bool isChatHistory;
  final ChatBloc chatBloc;

  const ChatScreen({
    super.key,
    required this.chatId,
    this.isChatHistory = false,
    required this.chatBloc,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatViewModel _viewModel;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _viewModel = ChatViewModel(
      chatBloc: widget.chatBloc,
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isButtonVisible = false;

  void _scrollListener() {
    final isAtBottom = _scrollController.position.pixels <= 100;
    if (!isAtBottom && !_isButtonVisible) {
      setState(() => _isButtonVisible = true);
    } else if (isAtBottom && _isButtonVisible) {
      setState(() => _isButtonVisible = false);
    }
  }

  void _scrollToEnd([int? duration]) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: duration ?? 600),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      bloc: widget.chatBloc,
      listener: (context, state) {
        if (state is ChatLoading) {
          _viewModel.isLoading = true;
          _isButtonVisible = false;
        }
        if (state is ChatFailure) {
          _viewModel.isLoading = false;
          showCustomToast(context,
              message: state.error, color: ColorManager.error);
        }
        if (state is ChatStreaming) {
          _viewModel.prompt += state.streamedText;
          _viewModel.isLoading = true;
          _isButtonVisible = false;
        }
        if (state is ChatReciveSuccess) {
          _viewModel.isLoading = false;
          _viewModel.prompt = "";
          _isButtonVisible = false;
          _scrollToEnd(100);
        }
        if (state is ChatSendSuccess) {
          _isButtonVisible = false;
          _scrollToEnd(100);
        }
        if (state is NewChatSessionCreated) {
          _isButtonVisible = false;
          _viewModel.isLoading = false;
          _scrollToEnd(100);
          showCustomToast(context, message: "New Chat Created Successfully!");
        }
      },
      builder: (context, state) {
        final messages = widget.chatBloc.getMessages(widget.chatId);
        final messagesLength =
            state is ChatStreaming ? messages.length + 1 : messages.length;
        return Scaffold(
          appBar: widget.isChatHistory
              ? AppBar(
                  title: const Text("Chat History"),
                  centerTitle: true,
                  backgroundColor: ColorManager.purple,
                )
              : null,
          resizeToAvoidBottomInset: false,
          floatingActionButton: _isButtonVisible
              ? BuildFloatingActionButton(onPressed: _scrollToEnd)
              : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          body: Padding(
            padding: const EdgeInsets.all(5),
            child: messages.isEmpty
                ? const EmptyBodyCard(
                    image: ImageManager.chat,
                    title: "Start Chatting with Qubic AI.",
                  )
                : BuildChatListViewBuilder(
                    state: state,
                    scrollController: _scrollController,
                    messagesLength: messagesLength,
                    prompt: _viewModel.prompt,
                    messages: messages,
                  ),
          ),
          bottomNavigationBar: BuildInputField(
            chatBloc: widget.chatBloc,
            chatId: widget.chatId,
            isChatHistory: widget.isChatHistory,
            isLoading: _viewModel.isLoading,
          ),
        );
      },
    );
  }
}
