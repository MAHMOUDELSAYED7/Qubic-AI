import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as ai;
import 'package:meta/meta.dart';

import '../../../core/utils/helper/network_status.dart';
import '../../../data/models/hive.dart';
import '../../../data/repositories/message_repository.dart';
import '../../../data/source/apis/generative_ai_web_service.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GenerativeAIWebService _webService;
  final MessageRepository _messageRepository;

  ChatBloc(this._webService, this._messageRepository) : super(ChatInitial()) {
    on<PostDataEvent>(_onPostData);
    on<StreamDataEvent>(_onStreamData);
    on<CreateNewChatSessionEvent>(_onCreateNewChatSession);
    on<DeleteChatSessionEvent>(_onDeleteChatSession);
    on<DeleteAllChatsEvent>(_onDeleteAllChats);
    on<ChatListUpdatedEvent>(_onChatListUpdated);
  }

  Future<void> _onCreateNewChatSession(
      CreateNewChatSessionEvent event, Emitter<ChatState> emit) async {
    try {
      final messages = _messageRepository.getMessages(getSessionId()).toList();
      if (messages.isNotEmpty) {
        final newChatId = await _messageRepository.createNewChatSession();
        emit(NewChatSessionCreated(newChatId));
      } else {
        emit(ChatFailure("Already in new chat!"));
      }
    } catch (error) {
      emit(ChatFailure(
          "Failed to create new chat session: ${error.toString()}"));
    }
  }

  int getSessionId() {
    final sessions = _messageRepository.getChatSessions();
    if (sessions.isEmpty) {
      // Create a new chat session if none exists
      return _messageRepository.createNewChatSessionSync();
    }
    return sessions.last.chatId;
  }

  List<Message> getMessages(int chatId) {
    return _messageRepository.getMessages(chatId).reversed.toList();
  }

  List<ChatSession> getChatSessions() {
    return _messageRepository.getChatSessions().reversed.toList();
  }

  Future<void> _onDeleteChatSession(
      DeleteChatSessionEvent event, Emitter<ChatState> emit) async {
    try {
      await _messageRepository.deleteChatSession(event.chatId);
      emit(ChatSessionDeleted(event.chatId));
    } catch (error) {
      emit(ChatFailure("Failed to delete chat session"));
    }
  }

  Future<void> _onDeleteAllChats(
      DeleteAllChatsEvent event, Emitter<ChatState> emit) async {
    try {
      await _messageRepository.deleteAllChats();
      emit(AllChatsDeleted());
    } catch (error) {
      emit(ChatFailure("Failed to delete all chats: ${error.toString()}"));
    }
  }

  Future<void> _onPostData(PostDataEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      if (!await NetworkManager.isConnected()) {
        emit(ChatFailure("No internet connection"));
      }

      await _messageRepository.addMessage(
        chatId: event.chatId,
        isUser: true,
        image: event.image,
        message: event.prompt,
        timestamp: DateTime.now().toString(),
      );
      emit(ChatSendSuccess());
      final messages = _messageRepository.getMessages(event.chatId);

      final contents = messages.map((msg) {
        if (msg == messages.last && event.recognizedText != null) {
          return ai.Content.text(
              "${msg.message}\n\n[Recognized Text]: ${event.recognizedText}");
        } else {
          return ai.Content.text(msg.message);
        }
      }).toList();

      final response = await _webService.postData(contents);
      if (response != null) {
        await _messageRepository.addMessage(
          chatId: event.chatId,
          isUser: false,
          message: response,
          timestamp: DateTime.now().toString(),
        );
        emit(ChatReciveSuccess(response));
      } else {
        emit(ChatFailure("Failed to get a response"));
      }
    } catch (error) {
      log(error.toString());
      emit(ChatFailure("Failed to get a response"));
    }
  }

  Future<void> _onStreamData(
      StreamDataEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    final StringBuffer fullResponse = StringBuffer();

    try {
      if (!await NetworkManager.isConnected()) {
        emit(ChatFailure("No internet connection"));
      }

      await _messageRepository.addMessage(
        chatId: event.chatId,
        isUser: true,
        image: event.image,
        message: event.prompt,
        timestamp: DateTime.now().toString(),
      );
      emit(ChatSendSuccess());

      final messages = _messageRepository.getMessages(event.chatId);

      final contents = messages.map((msg) {
        if (msg == messages.last && event.recognizedText != null) {
          return ai.Content.text(
              "${msg.message}\n\n[Recognized Text]: ${event.recognizedText}");
        } else {
          return ai.Content.text(msg.message);
        }
      }).toList();

      await for (final chunk in _webService.streamData(contents)) {
        if (chunk != null) {
          fullResponse.write(chunk);
          await Future.delayed(Duration(milliseconds: 200));
          emit(ChatStreaming(chunk));
        }
      }
      await Future.delayed(Duration(milliseconds: 500));
      final completeResponse = fullResponse.toString();
      await _messageRepository.addMessage(
        chatId: event.chatId,
        isUser: false,
        message: completeResponse,
        timestamp: DateTime.now().toString(),
      );

      emit(ChatReciveSuccess(completeResponse));
    } catch (error) {
      log(error.toString());
      emit(ChatFailure("Failed to get a response"));
    }
  }

  Future<void> _onChatListUpdated(
      ChatListUpdatedEvent event, Emitter<ChatState> emit) async {
    emit(ChatListUpdated());
  }
}
