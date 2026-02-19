import 'package:flutter_riverpod/legacy.dart';
import 'package:petcare/core/api/api_client.dart';
import 'package:petcare/core/api/api_endpoints.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';

class ChatConversation {
  final String participantId;
  final String participantRole;
  final String participantName;
  final String? participantImage;
  final String? participantSubtitle;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final String? lastMessageSenderId;
  final String? lastMessageSenderRole;

  const ChatConversation({
    required this.participantId,
    required this.participantRole,
    required this.participantName,
    this.participantImage,
    this.participantSubtitle,
    required this.lastMessage,
    this.lastMessageAt,
    this.lastMessageSenderId,
    this.lastMessageSenderRole,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      participantId: json['participantId']?.toString() ?? '',
      participantRole: json['participantRole']?.toString() ?? 'user',
      participantName: json['participantName']?.toString() ?? 'User',
      participantImage: json['participantImage']?.toString(),
      participantSubtitle: json['participantSubtitle']?.toString(),
      lastMessage: json['lastMessage']?.toString() ?? '',
      lastMessageAt: DateTime.tryParse(json['lastMessageAt']?.toString() ?? ''),
      lastMessageSenderId: json['lastMessageSenderId']?.toString(),
      lastMessageSenderRole: json['lastMessageSenderRole']?.toString(),
    );
  }
}

class ChatMessageItem {
  final String id;
  final String content;
  final String senderId;
  final String senderRole;
  final String receiverId;
  final String receiverRole;
  final DateTime? createdAt;

  const ChatMessageItem({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderRole,
    required this.receiverId,
    required this.receiverRole,
    this.createdAt,
  });

  factory ChatMessageItem.fromJson(Map<String, dynamic> json) {
    return ChatMessageItem(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderRole: json['senderRole']?.toString() ?? 'user',
      receiverId: json['receiverId']?.toString() ?? '',
      receiverRole: json['receiverRole']?.toString() ?? 'provider',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

class ChatContact {
  final String participantId;
  final String participantRole;
  final String name;
  final String? imageUrl;
  final String? subtitle;

  const ChatContact({
    required this.participantId,
    required this.participantRole,
    required this.name,
    this.imageUrl,
    this.subtitle,
  });

  factory ChatContact.fromJson(Map<String, dynamic> json) {
    return ChatContact(
      participantId: json['participantId']?.toString() ?? '',
      participantRole: json['participantRole']?.toString() ?? 'user',
      name: json['name']?.toString() ?? 'User',
      imageUrl: json['imageUrl']?.toString(),
      subtitle: json['subtitle']?.toString(),
    );
  }
}

class ChatState {
  final bool isLoadingConversations;
  final bool isLoadingMessages;
  final bool isLoadingContacts;
  final bool isSending;
  final List<ChatConversation> conversations;
  final List<ChatMessageItem> messages;
  final List<ChatContact> contacts;
  final String? error;
  final String? currentParticipantId;
  final String? currentParticipantRole;

  const ChatState({
    this.isLoadingConversations = false,
    this.isLoadingMessages = false,
    this.isLoadingContacts = false,
    this.isSending = false,
    this.conversations = const [],
    this.messages = const [],
    this.contacts = const [],
    this.error,
    this.currentParticipantId,
    this.currentParticipantRole,
  });

  ChatState copyWith({
    bool? isLoadingConversations,
    bool? isLoadingMessages,
    bool? isLoadingContacts,
    bool? isSending,
    List<ChatConversation>? conversations,
    List<ChatMessageItem>? messages,
    List<ChatContact>? contacts,
    String? error,
    bool clearError = false,
    String? currentParticipantId,
    String? currentParticipantRole,
  }) {
    return ChatState(
      isLoadingConversations:
          isLoadingConversations ?? this.isLoadingConversations,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      isLoadingContacts: isLoadingContacts ?? this.isLoadingContacts,
      isSending: isSending ?? this.isSending,
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      contacts: contacts ?? this.contacts,
      error: clearError ? null : (error ?? this.error),
      currentParticipantId: currentParticipantId ?? this.currentParticipantId,
      currentParticipantRole:
          currentParticipantRole ?? this.currentParticipantRole,
    );
  }
}

final chatViewModelProvider = StateNotifierProvider<ChatViewModel, ChatState>((
  ref,
) {
  return ChatViewModel(
    apiClient: ref.read(apiClientProvider),
    sessionService: ref.read(userSessionServiceProvider),
  );
});

final chatNotifierProvider = chatViewModelProvider;

class ChatViewModel extends StateNotifier<ChatState> {
  final ApiClient _apiClient;
  final UserSessionService _sessionService;

  ChatViewModel({
    required ApiClient apiClient,
    required UserSessionService sessionService,
  }) : _apiClient = apiClient,
       _sessionService = sessionService,
       super(const ChatState());

  String get currentUserId => _sessionService.getUserId() ?? '';
  String get currentUserRole => _sessionService.getRole() ?? 'user';

  List<dynamic> _extractList(dynamic data, {String? listKey}) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      if (listKey != null && data[listKey] is List) {
        return data[listKey] as List<dynamic>;
      }
      final payload = data['data'];
      if (payload is List) return payload;
      if (payload is Map<String, dynamic>) {
        if (listKey != null && payload[listKey] is List) {
          return payload[listKey] as List<dynamic>;
        }
        if (payload['items'] is List) return payload['items'] as List<dynamic>;
      }
      if (data['items'] is List) return data['items'] as List<dynamic>;
    }
    return const [];
  }

  Future<void> loadConversations({int page = 1, int limit = 50}) async {
    state = state.copyWith(isLoadingConversations: true, clearError: true);
    try {
      final response = await _apiClient.get(
        ApiEndpoints.chatConversations,
        queryParameters: {'page': page, 'limit': limit},
      );
      final list = _extractList(response.data, listKey: 'conversations');
      final conversations = list
          .whereType<Map>()
          .map(
            (item) => ChatConversation.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .where((item) => item.participantId.isNotEmpty)
          .toList();

      state = state.copyWith(
        isLoadingConversations: false,
        conversations: conversations,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingConversations: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadContacts() async {
    state = state.copyWith(isLoadingContacts: true, clearError: true);
    try {
      final response = await _apiClient.get(ApiEndpoints.chatContacts);
      final list = _extractList(response.data);
      final contacts = list
          .whereType<Map>()
          .map(
            (item) => ChatContact.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .where((item) => item.participantId.isNotEmpty)
          .toList();

      state = state.copyWith(isLoadingContacts: false, contacts: contacts);
    } catch (e) {
      state = state.copyWith(isLoadingContacts: false, error: e.toString());
    }
  }

  Future<void> loadConversationMessages({
    required String participantId,
    required String participantRole,
    int page = 1,
    int limit = 100,
  }) async {
    state = state.copyWith(
      isLoadingMessages: true,
      clearError: true,
      currentParticipantId: participantId,
      currentParticipantRole: participantRole,
    );
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.chatMessages}/$participantId',
        queryParameters: {
          'participantRole': participantRole,
          'page': page,
          'limit': limit,
        },
      );
      final list = _extractList(response.data, listKey: 'messages');
      final messages =
          list
              .whereType<Map>()
              .map(
                (item) => ChatMessageItem.fromJson(
                  item.map((key, value) => MapEntry(key.toString(), value)),
                ),
              )
              .toList()
            ..sort((a, b) {
              final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
              final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
              return aTime.compareTo(bTime);
            });

      state = state.copyWith(isLoadingMessages: false, messages: messages);
    } catch (e) {
      state = state.copyWith(isLoadingMessages: false, error: e.toString());
    }
  }

  Future<bool> sendMessage({
    required String participantId,
    required String participantRole,
    required String content,
  }) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return false;

    state = state.copyWith(isSending: true, clearError: true);
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.chatMessages}/$participantId',
        queryParameters: {'participantRole': participantRole},
        data: {'content': trimmed},
      );

      final data = response.data;
      Map<String, dynamic>? payload;
      if (data is Map<String, dynamic>) {
        if (data['data'] is Map<String, dynamic>) {
          payload = data['data'] as Map<String, dynamic>;
        } else {
          payload = data;
        }
      }

      final newMessage = payload != null
          ? ChatMessageItem.fromJson(payload)
          : ChatMessageItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              content: trimmed,
              senderId: currentUserId,
              senderRole: currentUserRole,
              receiverId: participantId,
              receiverRole: participantRole,
              createdAt: DateTime.now(),
            );

      final updatedMessages = [...state.messages, newMessage];
      final existingConversationIndex = state.conversations.indexWhere(
        (item) =>
            item.participantId == participantId &&
            item.participantRole == participantRole,
      );

      final updatedConversations = [...state.conversations];
      if (existingConversationIndex >= 0) {
        final existing = updatedConversations.removeAt(
          existingConversationIndex,
        );
        updatedConversations.insert(
          0,
          ChatConversation(
            participantId: existing.participantId,
            participantRole: existing.participantRole,
            participantName: existing.participantName,
            participantImage: existing.participantImage,
            participantSubtitle: existing.participantSubtitle,
            lastMessage: newMessage.content,
            lastMessageAt: newMessage.createdAt ?? DateTime.now(),
            lastMessageSenderId: newMessage.senderId,
            lastMessageSenderRole: newMessage.senderRole,
          ),
        );
      }

      state = state.copyWith(
        isSending: false,
        messages: updatedMessages,
        conversations: updatedConversations.isEmpty
            ? state.conversations
            : updatedConversations,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
      return false;
    }
  }
}
