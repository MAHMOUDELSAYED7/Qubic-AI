import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:qubic_ai/core/utils/extensions/extensions.dart';
import 'package:qubic_ai/core/utils/helper/custom_toast.dart';

import '../../../core/themes/colors.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/helper/regexp_methods.dart';
import '../../../data/models/hive.dart';
import '../../bloc/chat/chat_bloc.dart';

class SlidableChatCard extends StatelessWidget {
  const SlidableChatCard({
    super.key,
    required ChatBloc chatBloc,
    required this.chatMessages,
    required this.index,
    required this.chatSessions,
  }) : _chatBloc = chatBloc;

  final ChatBloc _chatBloc;
  final List<Message> chatMessages;
  final int index;
  final List<ChatSession> chatSessions;

  @override
  Widget build(BuildContext context) {
    final session = chatSessions[index];
    return ColoredBox(
      color: ColorManager.dark,
      child: Slidable(
        key: ValueKey(session.chatId.toString()),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.33,
          children: [
            SlidableAction(
              onPressed: (_) {
                _chatBloc.add(DeleteChatSessionEvent(session.chatId));
                chatSessions.removeAt(index);
                showCustomToast(
                  context,
                  message: 'Chat deleted',
                  durationInMilliseconds: 1500,
                );
              },
              backgroundColor: ColorManager.purple,
              autoClose: true,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              foregroundColor: ColorManager.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: chatMessages.lastOrNull?.message != null
            ? Card(
                color: ColorManager.black,
                elevation: 0,
                margin: EdgeInsets.zero,
                surfaceTintColor: ColorManager.transparent,
                shape: const BeveledRectangleBorder(),
                child: ListTile(
                  title: Text(
                    chatMessages.last.image == null
                        ? chatMessages.last.message
                        : chatMessages.length >= 2
                            ? chatMessages[chatMessages.length - 2].message
                            : 'Image',
                    textDirection: RegExpManager.getTextDirection(
                      chatMessages.last.message,
                    ),
                    maxLines: 1,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    "Started on ${RegExpManager.formatDateTime(session.createdAt)}",
                    style: context.textTheme.bodySmall
                        ?.copyWith(color: ColorManager.grey),
                  ),
                  onTap: ()=>
                  Navigator.pushNamed(
                    context,
                    RouteManager.chat,
                    arguments: [session.chatId, _chatBloc],
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ).withOnlyPadding(top: 1),
    );
  }
}

