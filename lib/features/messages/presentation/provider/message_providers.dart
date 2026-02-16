import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:petcare/features/messages/domain/entities/message_entity.dart';
import 'package:petcare/features/messages/domain/usecases/create_message_usecase.dart';
import 'package:petcare/features/messages/domain/usecases/get_all_messages_usecase.dart';
import 'package:petcare/features/messages/domain/usecases/get_my_messages_usecase.dart';
import 'package:petcare/features/messages/data/repositories/message_repository.dart';

// State
class MessageState {
  final bool isLoading;
  final List<MessageEntity> messages;
  final String? error;

  const MessageState({
    this.isLoading = false,
    this.messages = const [],
    this.error,
  });

  MessageState copyWith({
    bool? isLoading,
    List<MessageEntity>? messages,
    String? error,
    bool clearError = false,
  }) {
    return MessageState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Usecase Providers
final getAllMessagesUsecaseProvider = Provider<GetAllMessagesUsecase>((ref) {
  final repository = ref.read(messageRepositoryProvider);
  return GetAllMessagesUsecase(repository: repository);
});

final getMyMessagesUsecaseProvider = Provider<GetMyMessagesUsecase>((ref) {
  final repository = ref.read(messageRepositoryProvider);
  return GetMyMessagesUsecase(repository: repository);
});

final createMessageUsecaseProvider = Provider<CreateMessageUsecase>((ref) {
  final repository = ref.read(messageRepositoryProvider);
  return CreateMessageUsecase(repository: repository);
});

// Notifier
class MessageNotifier extends StateNotifier<MessageState> {
  final GetAllMessagesUsecase _getAllMessagesUsecase;
  final GetMyMessagesUsecase _getMyMessagesUsecase;
  final CreateMessageUsecase _createMessageUsecase;

  MessageNotifier(
    this._getAllMessagesUsecase,
    this._getMyMessagesUsecase,
    this._createMessageUsecase,
  ) : super(const MessageState());

  Future<void> getAllMessages({int page = 1, int limit = 20}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getAllMessagesUsecase(
      GetAllMessagesParams(page: page, limit: limit),
    );

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (messages) =>
          state = state.copyWith(isLoading: false, messages: messages),
    );
  }

  Future<void> getMyMessages() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getMyMessagesUsecase();

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (messages) =>
          state = state.copyWith(isLoading: false, messages: messages),
    );
  }

  Future<void> createMessage(String content) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _createMessageUsecase(content);

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (newMessage) {
        final updatedMessages = [...state.messages, newMessage];
        state = state.copyWith(isLoading: false, messages: updatedMessages);
      },
    );
  }
}

// Provider
final messageNotifierProvider =
    StateNotifierProvider<MessageNotifier, MessageState>((ref) {
      final getAllMessagesUsecase = ref.read(getAllMessagesUsecaseProvider);
      final getMyMessagesUsecase = ref.read(getMyMessagesUsecaseProvider);
      final createMessageUsecase = ref.read(createMessageUsecaseProvider);
      return MessageNotifier(
        getAllMessagesUsecase,
        getMyMessagesUsecase,
        createMessageUsecase,
      );
    });
