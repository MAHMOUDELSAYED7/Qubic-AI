part of 'chat_bloc.dart';

@immutable
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class PostDataEvent extends ChatEvent {
  final String prompt;
  final int chatId;
  final bool isUser;
  final String? image;
  final String? recognizedText;

  const PostDataEvent({
    required this.prompt,
    required this.chatId,
    required this.isUser,
    this.image,
    this.recognizedText,
  });

  @override
  List<Object?> get props => [prompt, chatId, isUser, image, recognizedText];
}

class StreamDataEvent extends ChatEvent {
  final String prompt;
  final int chatId;
  final bool isUser;
  final String? image;
  final String? recognizedText;

  const StreamDataEvent({
    required this.prompt,
    required this.chatId,
    required this.isUser,
    this.image,
    this.recognizedText,
  });

  @override
  List<Object?> get props => [prompt, chatId, isUser, image, recognizedText];
}

class CreateNewChatSessionEvent extends ChatEvent {
  const CreateNewChatSessionEvent();

  @override
  List<Object?> get props => [];
}

class DeleteChatSessionEvent extends ChatEvent {
  final int chatId;

  const DeleteChatSessionEvent(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class DeleteAllChatsEvent extends ChatEvent {
  const DeleteAllChatsEvent();

  @override
  List<Object?> get props => [];
}
