import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qubic_ai/core/utils/extensions/extensions.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/themes/colors.dart';

class SettingsBottomSheet extends StatefulWidget {
  const SettingsBottomSheet({super.key});

  @override
  State<SettingsBottomSheet> createState() => _SettingsBottomSheetState();
}

class _SettingsBottomSheetState extends State<SettingsBottomSheet> {
  late DraggableScrollableController _controller;
  double _currentSize = 0.7;

  @override
  void initState() {
    super.initState();
    _controller = DraggableScrollableController();
    _controller.addListener(_onSizeChanged);
  }

  void _onSizeChanged() {
    setState(() {
      _currentSize = _controller.size;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onSizeChanged);
    _controller.dispose();
    super.dispose();
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorManager.dark,
        title: Text(
          'Terms of Service',
          style: context.textTheme.headlineSmall?.copyWith(
            color: ColorManager.white,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            'Welcome to Qubic AI. By using our app, you agree to the following terms:\n\n'
            '1. Use of Service: You may use our AI chat service for personal and educational purposes.\n\n'
            '2. Data Privacy: We respect your privacy and handle your data according to our Privacy Policy.\n\n'
            '3. Acceptable Use: You agree not to use the service for illegal activities or harmful content.\n\n'
            '4. Service Availability: We strive to provide reliable service but cannot guarantee 100% uptime.\n\n'
            '5. Intellectual Property: All content and technology remain our property.\n\n'
            '6. Termination: We reserve the right to terminate accounts that violate these terms.\n\n'
            'For full terms, please visit our website.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: ColorManager.grey,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: context.textTheme.bodyMedium?.copyWith(
                color: ColorManager.purple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorManager.dark,
        title: Text(
          'Privacy Policy',
          style: context.textTheme.headlineSmall?.copyWith(
            color: ColorManager.white,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            'Your privacy is important to us. This policy explains how we collect, use, and protect your information:\n\n'
            '1. Information We Collect:\n'
            '   - Chat messages and conversations\n'
            '   - Usage analytics and app performance data\n'
            '   - Device information\n\n'
            '2. How We Use Your Information:\n'
            '   - To provide and improve our AI chat service\n'
            '   - To personalize your experience\n'
            '   - To analyze usage patterns\n\n'
            '3. Data Security:\n'
            '   - We use encryption to protect your data\n'
            '   - Your conversations are stored securely\n'
            '   - We do not sell your personal information\n\n'
            '4. Your Rights:\n'
            '   - You can request data deletion\n'
            '   - You can export your chat history\n'
            '   - You can opt out of analytics\n\n'
            'For complete privacy policy, visit our website.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: ColorManager.grey,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: context.textTheme.bodyMedium?.copyWith(
                color: ColorManager.purple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutUs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorManager.dark,
        title: Text(
          'About Qubic AI',
          style: context.textTheme.headlineSmall?.copyWith(
            color: ColorManager.white,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Qubic AI is your intelligent conversation companion, designed to help you with various tasks and provide meaningful interactions.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: ColorManager.grey,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Version: 1.0.0',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: ColorManager.white,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Built with Flutter',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: ColorManager.white,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Features:',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: ColorManager.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '• AI-powered conversations\n'
                '• Chat history management\n'
                '• Dark theme design\n'
                '• Secure data handling\n'
                '• Regular updates and improvements',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: ColorManager.grey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: context.textTheme.bodyMedium?.copyWith(
                color: ColorManager.purple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorManager.dark,
        title: Text(
          'Support',
          style: context.textTheme.headlineSmall?.copyWith(
            color: ColorManager.white,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Need help? We\'re here to support you!',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: ColorManager.grey,
                ),
              ),
              SizedBox(height: 16.h),
              _buildSupportOption(
                'Email Support',
                'support@qubicai.com',
                Icons.email,
                () => _launchURL('mailto:support@qubicai.com'),
              ),
              SizedBox(height: 12.h),
              _buildSupportOption(
                'FAQ',
                'Check our frequently asked questions',
                Icons.help_outline,
                () => _launchURL('https://qubicai.com/faq'),
              ),
              SizedBox(height: 12.h),
              _buildSupportOption(
                'Report Bug',
                'Help us improve by reporting issues',
                Icons.bug_report,
                () => _launchURL('mailto:bugs@qubicai.com'),
              ),
              SizedBox(height: 12.h),
              _buildSupportOption(
                'Feature Request',
                'Suggest new features',
                Icons.lightbulb_outline,
                () => _launchURL('mailto:features@qubicai.com'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: context.textTheme.bodyMedium?.copyWith(
                color: ColorManager.purple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOption(
      String title, String subtitle, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Row(
          children: [
            Icon(icon, color: ColorManager.purple, size: 24.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: ColorManager.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: ColorManager.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: ColorManager.grey, size: 16.w),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: 0.7,
      minChildSize: 0.7,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        return GestureDetector(
          onPanUpdate: (details) {
            // Allow dragging from anywhere to expand/collapse the sheet
            if (details.delta.dy < 0) {
              // Dragging up - expand to full screen
              if (_controller.size < 1.0) {
                _controller.animateTo(
                  1.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            } else if (details.delta.dy > 0) {
              // Dragging down - collapse to 70%
              if (_controller.size > 0.7) {
                _controller.animateTo(
                  0.7,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            }
          },
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: ColorManager.dark,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(_currentSize >= 0.95 ? 0 : 20.r),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar - only show when not full screen
                  if (_currentSize < 0.95) ...[
                    Container(
                      margin: EdgeInsets.only(top: 10.h),
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: ColorManager.grey,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ] else ...[
                    SizedBox(height: 14.h),
                  ],
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.all(16.w),
                    decoration: _currentSize >= 0.95
                        ? BoxDecoration(
                            color: ColorManager.dark,
                          )
                        : null,
                    child: Row(
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          style: context.textTheme.headlineSmall?.copyWith(
                                color: ColorManager.white,
                                fontWeight: FontWeight.bold,
                                fontSize: _currentSize >= 0.95 ? 18.sp : 20.sp,
                              ) ??
                              const TextStyle(),
                          child: const Text('Settings'),
                        ),
                        const Spacer(),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: Icon(
                                Icons.close,
                                color: ColorManager.grey,
                                size: _currentSize >= 0.95 ? 20.w : 24.w,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      children: [
                        _buildSettingsItem(
                          'Terms of Service',
                          'Read our terms and conditions',
                          Icons.description,
                          _showTermsOfService,
                        ),
                        _buildSettingsItem(
                          'Privacy Policy',
                          'How we handle your data',
                          Icons.privacy_tip,
                          _showPrivacyPolicy,
                        ),
                        _buildSettingsItem(
                          'About Us',
                          'Learn more about Qubic AI',
                          Icons.info,
                          _showAboutUs,
                        ),
                        _buildSettingsItem(
                          'Support',
                          'Get help and contact us',
                          Icons.support_agent,
                          _showSupport,
                        ),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsItem(
      String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: ColorManager.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: ColorManager.purple.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: ColorManager.purple,
            size: 24.w,
          ),
        ),
        title: Text(
          title,
          style: context.textTheme.bodyLarge?.copyWith(
            color: ColorManager.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: context.textTheme.bodySmall?.copyWith(
            color: ColorManager.grey,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: ColorManager.grey,
          size: 16.w,
        ),
        onTap: onTap,
      ),
    );
  }
}
