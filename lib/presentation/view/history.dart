import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qubic_ai/core/themes/colors.dart';
import 'package:qubic_ai/core/utils/extensions/extensions.dart';

import '../../core/di/locator.dart';
import '../../core/utils/constants/images.dart';
import '../../core/widgets/empty_body.dart';
import '../../core/widgets/floating_action_button.dart';
import '../bloc/chat/chat_bloc.dart';
import '../bloc/search/search_bloc.dart';
import '../viewmodel/search_viewmodel.dart';
import 'widgets/search_field.dart';
import 'widgets/settings_bottom_sheet.dart';
import 'widgets/slidable_chat_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late SearchViewModel _viewModel;
  late ChatBloc _chatBloc;
  late SearchBloc _searchBloc;
  late ScrollController _scrollController;
  bool _showScrollButton = false;
  bool _showSettingsButton = true;

  @override
  void initState() {
    super.initState();
    _chatBloc = sl<ChatBloc>();
    _searchBloc = sl<SearchBloc>();
    _viewModel = SearchViewModel(
      searchController: TextEditingController(),
      searchBloc: _searchBloc,
      chatAIBloc: _chatBloc,
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final isAtBottom = _scrollController.position.pixels <= 100;
    if (!isAtBottom && !_showScrollButton) {
      setState(() {
        _showScrollButton = true;
        _showSettingsButton = false;
      });
    } else if (isAtBottom && _showScrollButton) {
      setState(() {
        _showScrollButton = false;
        _showSettingsButton = true;
      });
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SettingsBottomSheet(),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(
            scale: animation,
            child: child,
          );
        },
        child: _showScrollButton
            ? BuildFloatingActionButton(
                key: const ValueKey('scroll_button'),
                onPressed: _scrollToTop,
                iconData: Icons.arrow_upward,
              )
            : _showSettingsButton
                ? FloatingActionButton.small(
                    key: const ValueKey('settings_button'),
                    onPressed: _openSettings,
                    backgroundColor: ColorManager.purple,
                    child: Icon(
                      Icons.settings,
                      color: ColorManager.white,
                    ),
                  ).withOnlyPadding(bottom: 10)
                : null,
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        bloc: _chatBloc,
        builder: (context, chatState) {
          return BlocBuilder<SearchBloc, SearchState>(
            bloc: _searchBloc,
            builder: (context, searchState) {
              final filteredSessions = searchState is SearchResults
                  ? searchState.filteredSessions
                  : _chatBloc.getChatSessions();
              return CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: SearchField(
                      searchController: _viewModel.searchController,
                      onChanged: _viewModel.handleSearchChange,
                      onClear: _viewModel.clearSearch,
                    ),
                  ),
                  if (filteredSessions.length <= 1)
                    SliverFillRemaining(
                      child: const EmptyBodyCard(
                        title: "No matching chats found",
                        image: ImageManager.history,
                      ).center().withOnlyPadding(bottom: 10.h),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final session = filteredSessions[index];
                          final chatMessages =
                              _chatBloc.getMessages(session.chatId);
                          return SlidableChatCard(
                            index: index,
                            chatSessions: filteredSessions,
                            chatBloc: _chatBloc,
                            chatMessages: chatMessages,
                          );
                        },
                        childCount: filteredSessions.length,
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
