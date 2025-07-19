import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qubic_ai/core/utils/extensions/extensions.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/locator.dart';
import '../../../core/themes/colors.dart';
import '../../../core/utils/helper/custom_toast.dart';
import '../../bloc/chat/chat_bloc.dart';
import '../../bloc/launch_uri/launch_uri_cubit.dart';

class SettingsBottomSheet extends StatefulWidget {
  const SettingsBottomSheet({super.key, required this.chatBloc});

  final ChatBloc chatBloc;

  @override
  State<SettingsBottomSheet> createState() => _SettingsBottomSheetState();
}

class _SettingsBottomSheetState extends State<SettingsBottomSheet> {
  late DraggableScrollableController _controller;
  double _currentSize = 0.7;

  @override
  void initState() {
    _chatBloc = widget.chatBloc;
    super.initState();
    _controller = DraggableScrollableController();
    _controller.addListener(_onSizeChanged);
  }

  late final ChatBloc _chatBloc;

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

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorManager.dark,
        title: Text(
          'Terms of Service for Qubic AI',
          style: context.textTheme.headlineSmall?.copyWith(
            color: ColorManager.white,
          ),
        ),
        content: SingleChildScrollView(
          child: MarkdownBody(
            selectable: true,
            data: '''
**Effective Date**: July 19, 2025

## 1. Acceptance of Terms
By downloading, installing, or using Qubic AI (the "App"), you agree to be bound by these Terms of Service ("Terms"). If you do not agree, please do not use the App. These Terms apply to all users, including children under 13 with parental supervision.

## 2. Description of Service
Qubic AI is a chatbot app developed by Mahmoud El Sayed, available on Android and soon on iOS. The App allows you to interact with a chatbot powered by Google Generative AI (Gemini, via Google AI Studio) for personal and educational purposes. All data, including chats and images, is stored locally on your device in an encrypted database.

## 3. Use of Third-Party Services
The App sends your text queries to Google Generative AI for processing. By using the App, you agree to Google’s [Terms of Service](https://policies.google.com/terms) and [Privacy Policy](https://policies.google.com/privacy) for the processing of your queries. We do not control Google’s services and are not responsible for their performance or data handling.

## 4. Acceptable Use
You agree to use the App responsibly and not to:
- Send illegal, harmful, offensive, or abusive content through the chatbot.
- Attempt to hack, reverse-engineer, or disrupt the App’s functionality.
- Use the App for commercial purposes without our permission.
- Overload the App with excessive queries (e.g., spamming).

## 5. Children’s Use
The App is suitable for children under 13 and complies with the Children’s Online Privacy Protection Act (COPPA) and GDPR requirements for children’s data. Parents or guardians are responsible for supervising their child’s use of the App. No personal information is collected, but queries are processed by Google Generative AI as described in Section 3.

## 6. Intellectual Property
All content, designs, and technology in the App, including the Qubic AI name and logo, are owned by Mahmoud El Sayed. You may not copy, distribute, or reproduce any part of the App without our written consent, except as permitted by law.

## 7. Notifications
The App may send local notifications every 8 hours via a worker. You can disable these notifications in the App’s settings.

## 8. Limitation of Liability
The App is provided "as is" without warranties of any kind. We are not liable for:
- Inaccuracies or errors in chatbot responses.
- App downtime or interruptions.
- Data loss, as all data is stored locally on your device.
- Issues arising from Google Generative AI’s services.

## 9. Termination
We reserve the right to restrict or terminate your access to the App if you violate these Terms, engage in prohibited activities, or misuse the App.

## 10. Governing Law
These Terms are governed by the laws of Egypt. Any disputes will be resolved in the courts of Egypt.

## 11. Changes to These Terms
We may update these Terms from time to time. Changes will be reflected in an updated version within the App, with a revised effective date.

## 12. Contact Us
For questions or concerns about these Terms, contact:  
**Mahmoud El Sayed**  
**Email**: [mahmoudelsayed.dev@gmail.com](mailto:mahmoudelsayed.dev@gmail.com)
          ''',
            styleSheet: MarkdownStyleSheet(
              p: context.textTheme.bodyMedium?.copyWith(
                color: ColorManager.grey,
              ),
              h1: context.textTheme.headlineSmall?.copyWith(
                color: ColorManager.white,
              ),
              h2: context.textTheme.titleLarge?.copyWith(
                color: ColorManager.white,
              ),
              a: TextStyle(
                color: ColorManager.grey,
                decoration: TextDecoration.underline,
                decorationColor: ColorManager.grey,
              ),
            ),
            onTapLink: (text, url, title) async {
              if (url != null) {
                if (url.startsWith('mailto:')) {
                  try {
                    await launchUrl(Uri.parse(url));
                  } catch (e) {
                    showCustomToast(context,
                        color: ColorManager.error,
                        message: 'Failed to open email app');
                  }
                } else if (url.startsWith('https:')) {
                  try {
                    await launchUrl(Uri.parse(url),
                        mode: LaunchMode.externalApplication);
                  } catch (e) {
                    showCustomToast(context,
                        color: ColorManager.error,
                        message: 'Failed to open link');
                  }
                }
              }
            },
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorManager.dark,
        title: Text(
          'Privacy Policy for Qubic AI',
          style: context.textTheme.headlineSmall?.copyWith(
            color: ColorManager.white,
          ),
        ),
        content: SingleChildScrollView(
          child: MarkdownBody(
            selectable: true,
            data: '''
**Effective Date**: July 19, 2025

## Introduction
Qubic AI ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we handle your information when you use our chatbot app, Qubic AI, developed by Mahmoud El Sayed, available on Android and soon on iOS.

## Information We Do Not Collect
We do **not** collect personal information such as your name, email address, phone number, location, or payment details. All data generated through your use of the App, including chats and images, is stored **locally** on your device and is not transmitted to us, except as described below.

## Use of Google Generative AI
To provide chatbot functionality, the App sends your text queries to Google Generative AI (Gemini, via Google AI Studio) for processing. Only the text you input is sent to Google’s servers; no personal identifiers are included. Responses are stored locally on your device. Google’s use of query data is governed by their [privacy policy](https://policies.google.com/privacy).

## Local Data Storage
The App uses an **encrypted local database** on your device to store your chats and images, ensuring your data remains secure and accessible only to you.

## Data Security
We prioritize your data security. The local database employs **encryption** to protect your information from unauthorized access.

## Children’s Privacy
The App is suitable for children under 13. We comply with the **Children’s Online Privacy Protection Act (COPPA)** and **GDPR** requirements for children’s data. Since we do not collect personal information, no parental consent is required. Parents should note that user queries are sent to Google Generative AI as described above.

## Your Rights and Choices
You have full control over your data:
- **Delete Data**: You can delete locally stored chats and images through the App’s interface.
- **Notifications**: You can disable local notifications, scheduled every 8 hours via a worker, in the App’s settings.

## Changes to This Privacy Policy
We may update this Privacy Policy. Changes will be reflected in an updated version within the App, with a revised effective date.

## Contact Us
For questions or concerns about this Privacy Policy, contact:  
**Mahmoud El Sayed**  
**Email**: [mahmoudelsayed.dev@gmail.com](mailto:mahmoudelsayed.dev@gmail.com)
          ''',
            styleSheet: MarkdownStyleSheet(
              p: context.textTheme.bodyMedium?.copyWith(
                color: ColorManager.grey,
              ),
              h1: context.textTheme.headlineSmall?.copyWith(
                color: ColorManager.white,
              ),
              h2: context.textTheme.titleLarge?.copyWith(
                color: ColorManager.white,
              ),
              a: TextStyle(
                color: ColorManager.grey,
                decoration: TextDecoration.underline,
                decorationColor: ColorManager.grey,
              ),
            ),
            onTapLink: (text, url, title) async {
              if (url != null) {
                if (url.startsWith('mailto:')) {
                  try {
                    await launchUrl(Uri.parse(url));
                  } catch (e) {
                    showCustomToast(context,
                        color: ColorManager.error,
                        message: 'Failed to open email app');
                  }
                } else if (url.startsWith('https:')) {
                  try {
                    await launchUrl(Uri.parse(url),
                        mode: LaunchMode.externalApplication);
                  } catch (e) {
                    showCustomToast(context,
                        color: ColorManager.error,
                        message: 'Failed to open link');
                  }
                }
              }
            },
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAboutUs(BuildContext context) {
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
          child: MarkdownBody(
            selectable: true,
            data: '''
**Version**: 1.0.0  
**Updated**: July 19, 2025

## Overview
Qubic AI is an intelligent chatbot application designed to provide engaging, educational, and safe conversational experiences for users of all ages, including children under 13. Developed by Mahmoud El Sayed, Qubic AI leverages advanced AI technology to deliver meaningful interactions while prioritizing user privacy and security. The app is currently available on Android, with iOS support coming soon.

## Key Features
- **AI-Powered Conversations**: Engage with a chatbot powered by Google Generative AI (Gemini, via Google AI Studio) for insightful and educational responses.
- **Local Data Storage**: All chats and images are stored securely in an encrypted local database on your device, ensuring no personal data is collected.
- **Customizable Notifications**: Receive optional local notifications every 8 hours, which can be disabled in the app’s settings.
- **Child-Friendly Design**: Compliant with the Children’s Online Privacy Protection Act (COPPA) and GDPR requirements for children’s data, ensuring a safe experience for young users.
- **Dark Theme Interface**: Enjoy a sleek, modern design optimized for usability and comfort.
- **Regular Updates**: Continuous improvements to enhance functionality and user experience.

## Our Commitment
At Qubic AI, we are dedicated to maintaining a secure and privacy-focused environment. No personal information is collected, and all data remains on your device, except for text queries sent to Google Generative AI for processing, as outlined in our Privacy Policy.

## About the Developer
Qubic AI is crafted with care by Mahmoud El Sayed, an independent developer committed to creating innovative and user-friendly applications. Qubic AI reflects a passion for technology and accessibility.

## Contact Us
For questions, feedback, or support, please reach out:  
**Mahmoud El Sayed**  
**Email**: [mahmoudelsayed.dev@gmail.com](mailto:mahmoudelsayed.dev@gmail.com)

## Learn More
- Review our **Privacy Policy** for details on how we handle your data.
- See our **Terms of Service** for the rules governing the use of Qubic AI.
          ''',
            styleSheet: MarkdownStyleSheet(
              p: context.textTheme.bodyMedium?.copyWith(
                color: ColorManager.grey,
              ),
              h1: context.textTheme.headlineSmall?.copyWith(
                color: ColorManager.white,
              ),
              h2: context.textTheme.titleLarge?.copyWith(
                color: ColorManager.white,
              ),
              a: TextStyle(
                color: ColorManager.grey,
                decoration: TextDecoration.underline,
                decorationColor: ColorManager.grey,
              ),
            ),
            onTapLink: (text, url, title) async {
              if (url != null) {
                if (url.startsWith('mailto:')) {
                  try {
                    await launchUrl(Uri.parse(url));
                  } catch (e) {
                    showCustomToast(context,
                        color: ColorManager.error,
                        message: 'Failed to open email app');
                  }
                } else if (url.startsWith('https:')) {
                  try {
                    await launchUrl(Uri.parse(url),
                        mode: LaunchMode.externalApplication);
                  } catch (e) {
                    showCustomToast(context,
                        color: ColorManager.error,
                        message: 'Failed to open link');
                  }
                }
              }
            },
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Close',
              style: context.textTheme.bodyMedium?.copyWith(
                color: ColorManager.white,
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
      builder: (context) => BlocProvider(
        create: (_) => sl<LaunchUriCubit>(),
        child: Builder(
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
                  _buildEmailLink(context, 'mahmoudelsayed.dev@gmail.com'),
                  SizedBox(height: 12.h),
                  _buildSupportOption(
                    'FAQ',
                    'Check our frequently asked questions',
                    Icons.help_outline,
                    () => context.read<LaunchUriCubit>().openEmailApp(
                          email: 'mahmoudelsayed.dev@gmail.com',
                          subject: 'FAQ - Qubic AI',
                          body: 'Please enter your question for the FAQ:\n\n',
                        ),
                  ),
                  SizedBox(height: 12.h),
                  _buildSupportOption(
                    'Report Bug',
                    'Help us improve by reporting issues',
                    Icons.bug_report,
                    () => context.read<LaunchUriCubit>().openEmailApp(
                          email: 'mahmoudelsayed.dev@gmail.com',
                          subject: 'Bug Report - Qubic AI',
                          body: 'Please describe the bug you encountered:\n\n',
                        ),
                  ),
                  SizedBox(height: 12.h),
                  _buildSupportOption(
                    'Feature Request',
                    'Suggest new features',
                    Icons.lightbulb_outline,
                    () => context.read<LaunchUriCubit>().openEmailApp(
                          email: 'mahmoudelsayed.dev@gmail.com',
                          subject: 'Feature Request - Qubic AI',
                          body:
                              'I would like to suggest the following feature:\n\n',
                        ),
                  ),
                  SizedBox(height: 12.h),
                  _buildSupportOption(
                    'General Support',
                    'Get help with any questions',
                    Icons.support_agent,
                    () => context.read<LaunchUriCubit>().openEmailApp(
                          email: 'mahmoudelsayed.dev@gmail.com',
                          subject: 'Support Request - Qubic AI',
                          body: 'Hello, I need help with:\n\n',
                        ),
                  ),
                ],
              ),
            ),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailLink(BuildContext context, String email) {
    return BlocListener<LaunchUriCubit, LaunchUriState>(
      listener: (context, state) {
        if (state == LaunchUriState.launchFailure) {
          showCustomToast(context,
              color: ColorManager.error, message: 'Failed to open email app');
        }
      },
      child: Padding(
        padding: EdgeInsets.only(top: 12.h, bottom: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.email, color: ColorManager.purple, size: 20.w),
            SizedBox(width: 8.w),
            InkWell(
              onTap: () => context.read<LaunchUriCubit>().openEmailApp(
                    email: email,
                    subject: 'Qubic AI Support',
                    body: 'Hello, I need assistance with:\n\n',
                  ),
              child: Text(
                email,
                style: context.textTheme.bodySmall?.copyWith(
                  color: ColorManager.purple,
                  decoration: TextDecoration.underline,
                  decorationColor: ColorManager.purple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAllChatsDialog() {
    showDialog(
      context: context,
      builder: (context) => BlocListener<ChatBloc, ChatState>(
        bloc: _chatBloc,
        listener: (context, state) {
          if (state is AllChatsDeleted) {
            _chatBloc.add(const CreateNewChatSessionEvent());
            showCustomToast(
              context,
              message: 'All chats deleted successfully',
              color: ColorManager.purple,
            );
          } else if (state is NewChatSessionCreated) {
            _chatBloc.add(const ChatListUpdatedEvent());
          }
        },
        child: AlertDialog(
          backgroundColor: ColorManager.dark,
          title: Text(
            'Delete All Chats',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge,
          ),
          content: SingleChildScrollView(
            child: Text(
              'Are you sure you want to delete all chats? This action cannot be undone.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall,
            ),
          ),
          actions: [
            Row(
              children: [
                SizedBox(width: 5.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: BounceIn(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll<Color>(
                          ColorManager.error!,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        _chatBloc.add(const DeleteAllChatsEvent());
                      },
                      child: const Text('Delete All'),
                    ),
                  ),
                ),
                SizedBox(width: 5.w),
              ],
            ),
          ],
        ),
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
            if (details.delta.dy < 0) {
              if (_controller.size < 1.0) {
                _controller.animateTo(
                  1.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            } else if (details.delta.dy > 0) {
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
                          () => _showTermsOfService(context),
                        ),
                        _buildSettingsItem(
                          'Privacy Policy',
                          'How we handle your data',
                          Icons.privacy_tip,
                          () => _showPrivacyPolicy(context),
                        ),
                        _buildSettingsItem(
                          'About Us',
                          'Learn more about Qubic AI',
                          Icons.info,
                          () => _showAboutUs(context),
                        ),
                        _buildSettingsItem(
                          'Support',
                          'Get help and contact us',
                          Icons.support_agent,
                          _showSupport,
                        ),
                        _buildSettingsItem(
                          'Delete All Chats',
                          'Clear all chat history permanently',
                          Icons.delete_forever,
                          _showDeleteAllChatsDialog,
                          isDestructive: true,
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
      String title, String subtitle, IconData icon, VoidCallback onTap,
      {bool isDestructive = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: isDestructive
            ? ColorManager.error?.withOpacity(0.1)
            : ColorManager.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: isDestructive
                ? ColorManager.error?.withOpacity(0.2)
                : ColorManager.purple.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: isDestructive ? ColorManager.error : ColorManager.purple,
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
