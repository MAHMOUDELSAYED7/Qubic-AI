import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qubic_ai/core/utils/extensions/extensions.dart';

import '../../core/themes/colors.dart';
import '../../core/widgets/floating_action_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ScrollController _scrollController;
  bool _showScrollButton = false;
  bool _showSettingsButton = true;

  @override
  void initState() {
    super.initState();
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
    // Add your settings action here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings action pressed!')),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _showScrollButton
          ? BuildFloatingActionButton(
              onPressed: _scrollToTop,
              iconData: Icons.arrow_upward,
            )
          : _showSettingsButton
              ? BuildFloatingActionButton(
                  onPressed: _openSettings,
                  iconData: Icons.settings,
                )
              : null,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            title: Text(
              'Settings',
              style: context.textTheme.headlineSmall,
            ),
            backgroundColor: ColorManager.dark,
            floating: true,
            snap: true,
            automaticallyImplyLeading: false,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildSettingsSection(
                'General',
                [
                  _buildSettingsTile(
                    'Theme',
                    'Dark Mode',
                    Icons.dark_mode,
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    'Language',
                    'English',
                    Icons.language,
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    'Notifications',
                    'Enabled',
                    Icons.notifications,
                    onTap: () {},
                  ),
                ],
              ),
              _buildSettingsSection(
                'Chat Settings',
                [
                  _buildSettingsTile(
                    'Auto-save chats',
                    'Enabled',
                    Icons.save,
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    'Clear chat history',
                    'Delete all conversations',
                    Icons.delete_forever,
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    'Export chats',
                    'Save chats to file',
                    Icons.file_download,
                    onTap: () {},
                  ),
                ],
              ),
              _buildSettingsSection(
                'AI Settings',
                [
                  _buildSettingsTile(
                    'Response speed',
                    'Normal',
                    Icons.speed,
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    'AI Model',
                    'GPT-4',
                    Icons.psychology,
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    'Temperature',
                    'Balanced',
                    Icons.tune,
                    onTap: () {},
                  ),
                ],
              ),
              _buildSettingsSection(
                'Account',
                [
                  _buildSettingsTile(
                    'Profile',
                    'Edit profile information',
                    Icons.person,
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    'Privacy',
                    'Privacy settings',
                    Icons.privacy_tip,
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    'Data & Storage',
                    'Manage your data',
                    Icons.storage,
                    onTap: () {},
                  ),
                ],
              ),
              _buildSettingsSection(
                'Support',
                [
                  _buildSettingsTile(
                    'Help Center',
                    'Get help and support',
                    Icons.help,
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    'Report a bug',
                    'Report issues',
                    Icons.bug_report,
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    'Contact Us',
                    'Get in touch',
                    Icons.support_agent,
                    onTap: () {},
                  ),
                ],
              ),
              _buildSettingsSection(
                'About',
                [
                  _buildSettingsTile(
                    'Version',
                    '1.0.0',
                    Icons.info,
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    'Terms of Service',
                    'Read terms and conditions',
                    Icons.description,
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    'Privacy Policy',
                    'Read privacy policy',
                    Icons.policy,
                    onTap: () {},
                  ),
                ],
              ),
              // Add extra content to make scrolling possible
              ...List.generate(
                8,
                (index) => Container(
                  height: 80.h,
                  margin: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: ColorManager.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      'Additional content ${index + 1}',
                      style: context.textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(
              color: ColorManager.purple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: ColorManager.white,
      ),
      title: Text(
        title,
        style: context.textTheme.bodyLarge,
      ),
      subtitle: Text(
        subtitle,
        style: context.textTheme.bodySmall?.copyWith(
          color: ColorManager.grey,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: ColorManager.grey,
      ),
      onTap: onTap,
    );
  }
}
