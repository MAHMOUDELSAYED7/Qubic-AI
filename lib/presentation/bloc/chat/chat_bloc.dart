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

  ChatBloc(this._webService, this._messageRepository)
      : super(ChatInitial()) {
    on<PostDataEvent>(_onPostData);
    on<StreamDataEvent>(_onStreamData);
    on<CreateNewChatSessionEvent>(_onCreateNewChatSession);
    on<DeleteChatSessionEvent>(_onDeleteChatSession);
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
    return _messageRepository.getChatSessions().last.chatId;
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

  Future<void> _onPostData(
      PostDataEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      if (!await NetworkManager.isConnected()) {
        emit(ChatFailure("No internet connection"));
      }

      // Save ONLY the original prompt to the database
      await _messageRepository.addMessage(
        chatId: event.chatId,
        isUser: true,
        image: event.image,
        message: event.prompt, // Original text only
        timestamp: DateTime.now().toString(),
      );

      // Get all messages (including the one we just added)
      final messages = _messageRepository.getMessages(event.chatId);

      // Prepare AI content: Combine recognizedText with the latest message
      final contents = messages.map((msg) {
        if (msg == messages.last && event.recognizedText != null) {
          return ai.Content.text(
              "${msg.message}\n\n[Recognized Text]: ${event.recognizedText}");
        } else {
          return ai.Content.text(msg.message);
        }
      }).toList();

      // Send to AI
      final response = await _webService.postData(contents);
      if (response != null) {
        await _messageRepository.addMessage(
          chatId: event.chatId,
          isUser: false,
          message: response,
          timestamp: DateTime.now().toString(),
        );
        emit(ChatSuccess(response));
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

      // Save ONLY the original prompt to the database
      await _messageRepository.addMessage(
        chatId: event.chatId,
        isUser: true,
        image: event.image,
        message: event.prompt, // Original text only
        timestamp: DateTime.now().toString(),
      );

      // Get all messages (including the one we just added)
      final messages = _messageRepository.getMessages(event.chatId);

      // Prepare AI content: Combine recognizedText with the latest message
      final contents = messages.map((msg) {
        if (msg == messages.last && event.recognizedText != null) {
          return ai.Content.text(
              "${msg.message}\n\n[Recognized Text]: ${event.recognizedText}");
        } else {
          return ai.Content.text(msg.message);
        }
      }).toList();

      // Stream response
      await for (final chunk in _webService.streamData(contents)) {
        if (chunk != null) {
          fullResponse.write(chunk);
          emit(ChatStreaming(chunk));
        }
      }

      // Save AI response
      final completeResponse = fullResponse.toString();
      await _messageRepository.addMessage(
        chatId: event.chatId,
        isUser: false,
        message: completeResponse,
        timestamp: DateTime.now().toString(),
      );

      emit(ChatSuccess(completeResponse));
    } catch (error) {
      log(error.toString());
      emit(ChatFailure("Failed to get a response"));
    }
  }
}
