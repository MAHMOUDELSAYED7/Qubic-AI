import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as ai;
import 'package:meta/meta.dart';

import '../../../core/utils/helper/network_status.dart';
import '../../../data/models/hive.dart';
import '../../../data/repositories/message_repository.dart';
import '../../../data/services/apis/generative_ai_web_service.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatAIBloc extends Bloc<ChatAIEvent, ChatAIState> {
  final GenerativeAIWebService _webService;
  final MessageRepository _messageRepository;

  ChatAIBloc(this._webService, this._messageRepository)
      : super(ChatAIInitial()) {
    on<PostDataEvent>(_onPostData);
    on<StreamDataEvent>(_onStreamData);
    on<CreateNewChatSessionEvent>(_onCreateNewChatSession);
    on<DeleteChatSessionEvent>(_onDeleteChatSession);
  }

  Future<void> _onCreateNewChatSession(
      CreateNewChatSessionEvent event, Emitter<ChatAIState> emit) async {
    try {
      final messages = _messageRepository.getMessages(getSessionId()).toList();
      if (messages.isNotEmpty) {
        final newChatId = await _messageRepository.createNewChatSession();
        emit(NewChatSessionCreated(newChatId));
      } else {
        emit(ChatAIFailure("Already in new chat!"));
      }
    } catch (error) {
      emit(ChatAIFailure(
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
      DeleteChatSessionEvent event, Emitter<ChatAIState> emit) async {
    try {
      await _messageRepository.deleteChatSession(event.chatId);
      emit(ChatSessionDeleted(event.chatId));
    } catch (error) {
      emit(ChatAIFailure("Failed to delete chat session"));
    }
  }

  Future<void> _onPostData(
      PostDataEvent event, Emitter<ChatAIState> emit) async {
    emit(ChatAILoading());
    try {
      if (!await NetworkManager.isConnected()) {
        emit(ChatAIFailure("No internet connection"));
      }
      await _messageRepository.addMessage(
        chatId: event.chatId,
        isUser: true,
        message: event.prompt,
        timestamp: DateTime.now().toString(),
      );

      final messages = _messageRepository.getMessages(event.chatId);
      final contents =
          messages.map((msg) => ai.Content.text(msg.message)).toList();

      final response = await _webService.postData(contents);
      if (response != null) {
        await _messageRepository.addMessage(
          chatId: event.chatId,
          isUser: false,
          message: response,
          timestamp: DateTime.now().toString(),
        );
        emit(ChatAISuccess(response));
      } else {
        emit(ChatAIFailure("Failed to get a response"));
      }
    } catch (error) {
      log(error.toString());
      emit(ChatAIFailure("Failed to get a response"));
    }
  }

  Future<void> _onStreamData(
      StreamDataEvent event, Emitter<ChatAIState> emit) async {
    emit(ChatAILoading());
    final StringBuffer fullResponse = StringBuffer();

    try {
      if (!await NetworkManager.isConnected()) {
        emit(ChatAIFailure("No internet connection"));
      }
      await _messageRepository.addMessage(
        chatId: event.chatId,
        isUser: true,
        message: event.prompt,
        timestamp: DateTime.now().toString(),
      );

      final messages = _messageRepository.getMessages(event.chatId);
      final contents =
          messages.map((msg) => ai.Content.text(msg.message)).toList();

      await for (final chunk in _webService.streamData(contents)) {
        if (chunk != null) {
          fullResponse.write(chunk);
          emit(ChatAIStreaming(chunk));
        }
      }

      final completeResponse = fullResponse.toString();
      await _messageRepository.addMessage(
        chatId: event.chatId,
        isUser: false,
        message: completeResponse,
        timestamp: DateTime.now().toString(),
      );

      emit(ChatAISuccess(completeResponse));
    } catch (error) {
      log(error.toString());
      emit(ChatAIFailure("Failed to get a response"));
    }
  }
}
