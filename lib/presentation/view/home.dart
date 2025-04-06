import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qubic_ai/core/di/locator.dart';
import 'package:qubic_ai/core/utils/extensions/extensions.dart';
import 'package:qubic_ai/core/utils/helper/network_status.dart';
import 'package:qubic_ai/presentation/bloc/chat/chat_bloc.dart';

import '../../core/themes/colors.dart';
import '../../core/utils/constants/images.dart';
import '../../core/utils/helper/custom_toast.dart';
import '../bloc/search/search_bloc.dart';
import 'chat.dart';
import 'history.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _chcecInternetConnection();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  void _chcecInternetConnection() async {
    if (!await NetworkManager.isConnected()) {
      showCustomToast(
        context,
        message: "No internet connection",
        durationInMilliseconds: 5000,
        color: ColorManager.error,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final _chatBloc = sl<ChatBloc>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      // ignore: deprecated_member_use
      onPopInvoked: (bool didPop) async {
        if (didPop) return;

        if (_currentTabIndex == 1) {
          setState(() {
            _tabController.index = 0;
          });
        } else if (_currentTabIndex == 0) {
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: ColorManager.dark,
              title: Text(
                'Logout',
                style: context.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              content: Text(
                'Are you sure you want to logout?',
                style: context.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                _buildDialogActions(context),
              ],
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: TabBar(
            indicatorColor: ColorManager.white,
            controller: _tabController,
            tabs: [
              _buildTab("Qubic AI", ImageManager.logo),
              _buildTab("History", ImageManager.history),
            ],
          ),
        ),
        body: BlocBuilder<ChatBloc, ChatState>(
          bloc: _chatBloc,
          builder: (context, state) {
            return TabBarView(
              controller: _tabController,
              children: [
                ChatScreen(
                  chatId: _chatBloc.getSessionId(),
                  chatBloc: _chatBloc,
                ),
                BlocProvider(
                  create: (_) => sl<SearchBloc>(),
                  child: const HistoryScreen(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDialogActions(context) => Row(
        spacing: 10,
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
          ),
          Expanded(
            child: BounceIn(
              child: ElevatedButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text('Logout'),
              ),
            ),
          ),
        ],
      );

  Tab _buildTab(String title, String icon) => Tab(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(icon, width: 20, height: 20),
            const SizedBox(width: 8),
            Text(title, style: context.textTheme.bodySmall),
          ],
        ),
      );
}
