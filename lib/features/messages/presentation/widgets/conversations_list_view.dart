import 'package:flutter/material.dart';
import 'package:petcare/features/messages/presentation/view_model/chat_view_model.dart';
import 'package:petcare/features/messages/presentation/widgets/conversation_tile.dart';

class ConversationsListView extends StatelessWidget {
  final ChatState state;
  final String emptyText;
  final Future<void> Function() onRefresh;
  final ValueChanged<ChatConversation> onConversationTap;

  const ConversationsListView({
    super.key,
    required this.state,
    required this.emptyText,
    required this.onRefresh,
    required this.onConversationTap,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(onRefresh: onRefresh, child: _buildBody());
  }

  Widget _buildBody() {
    if (state.isLoadingConversations && state.conversations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.conversations.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Center(child: Text('Error: ${state.error}')),
        ],
      );
    }

    if (state.conversations.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Center(child: Text(emptyText)),
        ],
      );
    }

    return ListView.separated(
      itemCount: state.conversations.length,
      separatorBuilder: (_, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final conversation = state.conversations[index];
        return ConversationTile(
          conversation: conversation,
          onTap: () => onConversationTap(conversation),
        );
      },
    );
  }
}
