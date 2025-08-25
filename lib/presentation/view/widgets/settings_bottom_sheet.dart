import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qubic_ai/core/utils/extensions/extensions.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/locator.dart';
import '../../../core/service/app_settings.dart';
import '../../../core/service/notification_manager.dart';
import '../../../core/service/workmanger.dart';
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
  late final ChatBloc _chatBloc;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    _chatBloc = widget.chatBloc;
    super.initState();
    _controller = DraggableScrollableController();
    _controller.addListener(_onSizeChanged);
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final enabled = await AppSettingsService.instance.getNotificationsEnabled();
    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  Future<void> _toggleNotifications(bool enabled) async {
    if (enabled) {
      final hasPermission =
          await NotificationManager.instance.requestPermissionFromSettings();

      if (hasPermission) {
        await AppSettingsService.instance.setNotificationsEnabled(true);
        WorkManagerService.enableNotifications();
        showCustomToast(
          context,
          message: 'Notifications enabled',
          color: ColorManager.purple,
        );
        setState(() {
          _notificationsEnabled = true;
        });
      } else {
        final isPermanentlyDenied =
            await NotificationManager.instance.isPermissionPermanentlyDenied();

        if (isPermanentlyDenied) {
          _showPermissionBlockedDialog();
        }

        setState(() {
          _notificationsEnabled = false;
        });
      }
    } else {
      await AppSettingsService.instance.setNotificationsEnabled(false);
      WorkManagerService.disableNotifications();
      showCustomToast(
        context,
        message: 'Notifications disabled',
        color: ColorManager.grey,
      );
      setState(() {
        _notificationsEnabled = false;
      });
    }
  }

  void _showPermissionBlockedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ColorManager.dark,
          title: Text(
            'Permission Required',
            style: context.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          content: Text(
            'Notification permission is blocked. Please enable it in your device settings to receive notifications.',
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            _buildPermissionDialogActions(context),
          ],
        );
      },
    );
  }

  Widget _buildPermissionDialogActions(BuildContext context) => Row(
        children: [
          SizedBox(width: 5.w),
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: BounceIn(
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await NotificationManager.instance.openSystemSettings();
                },
                child: const Text('Open'),
              ),
            ),
          ),
          SizedBox(width: 5.w),
        ],
      );

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
      builder: (context) => FractionallySizedBox(
        widthFactor: 1.1,
        child: AlertDialog(
          backgroundColor: ColorManager.dark,
          title: Text(
            'Terms of Service for Qubic AI',
            style: context.textTheme.titleMedium?.copyWith(
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
                h1: context.textTheme.titleMedium?.copyWith(
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
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FractionallySizedBox(
        widthFactor: 1.1,
        child: AlertDialog(
          backgroundColor: ColorManager.dark,
          title: Text(
            'Privacy Policy for Qubic AI',
            style: context.textTheme.titleMedium?.copyWith(
              color: ColorManager.white,
            ),
          ),
          content: SingleChildScrollView(
            child: MarkdownBody(
              selectable: true,
              data: '''
**Effective Date**: July 19, 2025

## Introduction
Qubic AI (“Qubic AI,” “we,” “our,” or “us”) respects your privacy. This Privacy Policy explains how the Qubic AI mobile application (the “App”) handles information. The App is developed by Mahmoud El Sayed and is available on Android, with iOS planned.

## What We Do Not Collect
- We do not require you to create an account.
- We do not collect your name, email, phone number, location, contacts, or payment details.
- We do not use analytics or advertising SDKs.

## Data You Provide And How It’s Used
- **Chat content you type**: When you use the chatbot, the text you type is sent to Google Generative AI (Gemini via Google AI Studio) to generate a response.
- **Text recognized from images (OCR)**: If you choose to use the Camera or select an Image, the App can extract text on-device using Google ML Kit Text Recognition. Only the recognized text (not the image) may be sent to Google Generative AI as part of your chat prompt if you proceed to send it.
- We do **not** send your images to our servers or to Google Generative AI. Images remain on your device unless you share them yourself.

## Third-Party Processing (Google Generative AI)
- The App uses the google_generative_ai SDK to send your chat text and any OCR-extracted text to Google for processing and to return responses to you.
- No personal identifiers are included by the App unless you include them in your message.
- Google’s handling of your input is governed by Google’s [Privacy Policy](https://policies.google.com/privacy) and [Terms](https://policies.google.com/terms).

## On-Device OCR (Google ML Kit)
- The App uses Google ML Kit Text Recognition on-device to extract text from images you select or capture. By design, this processing occurs locally on your device; the App does not send images to any server for OCR.

## Local Storage And Retention
- **Local storage**: Your chats (text and timestamps) and settings are stored locally on your device using Hive (app-private storage).
- **Security at rest**: Your data is protected by the operating system’s app sandbox. The App does not currently apply its own encryption to the local database.
  - **Tip for users**: Enable device-level encryption and screen lock for additional protection.
- **Retention**: Your data remains on your device until you delete it within the App or uninstall the App.
- **Backups**: Depending on your OS settings, system backups (e.g., Android backups) may include App data.

## Notifications And Background Processing
- The App can schedule local reminder notifications approximately every 8 hours using WorkManager.
- You can disable notifications in the App’s settings at any time.
- To support reliable delivery, the App may request:
  - POST_NOTIFICATIONS (to show notifications).
  - SCHEDULE_EXACT_ALARM/USE_EXACT_ALARM (for precise alarms on supported Android versions).
  - RECEIVE_BOOT_COMPLETED (to restore scheduled tasks after device reboot).
  - WAKE_LOCK and VIBRATE (to deliver notifications reliably).
- No personal information is collected for notifications.

## Network And Links
- The App needs INTERNET and ACCESS_NETWORK_STATE to check connectivity and communicate with Google Generative AI.
- The App may open external links (e.g., support email or web pages) using your device’s email client or browser when you tap them. No data is sent automatically without you tapping a link.
- The App configuration allows cleartext (HTTP) connections, but the App is intended to use HTTPS endpoints for security.

## Children’s Privacy (All Ages)
- The App is designed for a general audience and can be used by all ages, including children under 13.
- We do not knowingly collect personal information from children.
- **Important**: Because the chatbot sends user-provided text to Google Generative AI, children should not include personal information (e.g., real names, addresses, phone numbers) in messages. We encourage parents and guardians to supervise use and discuss safe online behavior.
- If you believe a child has provided personal information in chat text, you can delete the local chat in the App. We do not control Google’s systems; please review Google’s [Privacy Policy](https://policies.google.com/privacy) for questions regarding data processed by Google.

## Your Choices And Controls
- **Delete data**: You can delete individual chats or all chats within the App.
- **Notifications**: You can disable reminder notifications in the App’s settings.
- **Connectivity**: If there is no internet connection, the App will not be able to request responses from Google Generative AI.

## Data Sharing
- We do not sell or share your personal information with third parties for marketing.
- We transmit your chat text and optionally OCR-extracted text to Google solely to obtain AI responses. We do not have access to or control over Google’s use of that data beyond what is described in Google’s policies.

## Security
- We take reasonable steps to protect your information, including using the OS app sandbox and HTTPS for network requests where applicable.
- **Note**: The App’s local database is not currently encrypted by the App itself. Consider enabling device encryption and screen lock. We continuously review opportunities to enhance data protection.

## International Processing
- Google may process your chat inputs on servers located in different countries. See Google’s [Privacy Policy](https://policies.google.com/privacy) for details.

## Changes To This Privacy Policy
- We may update this Privacy Policy. Updates will be made available within the App and on our website with a revised effective date.

## Contact Us
For questions or concerns about this Privacy Policy:  
- Mahmoud El Sayed  
- **Email**: [mahmoudelsayed.dev@gmail.com](mailto:mahmoudelsayed.dev@gmail.com)

## Appendix: Android Permissions And Why We Ask
- **INTERNET, ACCESS_NETWORK_STATE**: To check connectivity and send your chat text to Google Generative AI.
- **POST_NOTIFICATIONS**: To display local reminder notifications.
- **SCHEDULE_EXACT_ALARM, USE_EXACT_ALARM**: To schedule precise reminders on supported Android versions.
- **RECEIVE_BOOT_COMPLETED**: To restore scheduled reminders after device reboot.
- **WAKE_LOCK, VIBRATE**: To ensure notifications are delivered reliably.
- **Foreground service**: May be requested by the system for reliable background work on some devices.
- **Camera/Photos**: Using the system Camera or Photo Picker when you choose to add an image. The App does not read your media library without your action, and images are not sent to Google Generative AI; only OCR-extracted text is optionally included in your chat if you submit it.

## Third-Party SDKs Used
- **google_generative_ai**: Sends your chat text to Google for AI responses.
- **google_mlkit_text_recognition**: On-device OCR (no images sent to servers).
- **workmanager**: Schedules periodic local reminders.
- **flutter_local_notifications**: Displays local notifications.
- **connectivity_plus**: Checks network connectivity.
- **url_launcher**: Opens email client or browser when you tap a link.

## No Analytics Or Ads
- The App does not include analytics or advertising SDKs.
            ''',
              styleSheet: MarkdownStyleSheet(
                p: context.textTheme.bodyMedium?.copyWith(
                  color: ColorManager.grey,
                ),
                h1: context.textTheme.titleMedium?.copyWith(
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
                      showCustomToast(
                        context,
                        color: ColorManager.error,
                        message: 'Failed to open email app',
                      );
                    }
                  } else if (url.startsWith('https:')) {
                    try {
                      await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (e) {
                      showCustomToast(
                        context,
                        color: ColorManager.error,
                        message: 'Failed to open link',
                      );
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
      ),
    );
  }

  void _showAboutUs(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FractionallySizedBox(
        widthFactor: 1.1,
        child: AlertDialog(
          backgroundColor: ColorManager.dark,
          title: Text(
            'About Qubic AI',
            style: context.textTheme.titleMedium?.copyWith(
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
                h1: context.textTheme.titleMedium?.copyWith(
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
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSupport() {
    showDialog(
      context: context,
      builder: (context) => FractionallySizedBox(
        widthFactor: 1.1,
        child: BlocProvider(
          create: (_) => sl<LaunchUriCubit>(),
          child: Builder(
            builder: (context) => AlertDialog(
              backgroundColor: ColorManager.dark,
              title: Text(
                'Support',
                style: context.textTheme.titleMedium?.copyWith(
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
                            body:
                                'Please describe the bug you encountered:\n\n',
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
      builder: (context) => FractionallySizedBox(
        child: BlocListener<ChatBloc, ChatState>(
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
                        child: const Text('Delete'),
                      ),
                    ),
                  ),
                  SizedBox(width: 5.w),
                ],
              ),
            ],
          ),
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
                        _buildNotificationToggle(),
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

  Widget _buildNotificationToggle() {
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
            Icons.notifications,
            color: ColorManager.purple,
            size: 24.w,
          ),
        ),
        title: Text(
          'Notifications',
          style: context.textTheme.bodyLarge?.copyWith(
            color: ColorManager.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'Receive reminders every 8 hours',
          style: context.textTheme.bodySmall?.copyWith(
            color: ColorManager.grey,
          ),
        ),
        trailing: Switch(
          value: _notificationsEnabled,
          onChanged: _toggleNotifications,
          activeColor: ColorManager.purple,
          activeTrackColor: ColorManager.purple.withOpacity(0.3),
          inactiveThumbColor: ColorManager.grey,
          inactiveTrackColor: ColorManager.grey.withOpacity(0.3),
        ),
      ),
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
