import 'package:flutter/material.dart';
import 'package:petcare/features/messages/presentation/view_model/chat_view_model.dart';
import 'package:petcare/features/messages/presentation/widgets/chat_message_bubble.dart';

class ChatMessageList extends StatelessWidget {
  final ChatState state;
  final ScrollController scrollController;
  final String currentUserId;
  final String currentUserRole;

  const ChatMessageList({
    super.key,
    required this.state,
    required this.scrollController,
    required this.currentUserId,
    required this.currentUserRole,
  });

  @override
  Widget build(BuildContext context) {
    final messages = state.messages;
    if (state.isLoadingMessages && messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && messages.isEmpty) {
      return Center(child: Text('Error: ${state.error}'));
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMine =
            message.senderId == currentUserId &&
            message.senderRole == currentUserRole;

        return ChatMessageBubble(message: message, isMine: isMine);
      },
    );
  }
}
