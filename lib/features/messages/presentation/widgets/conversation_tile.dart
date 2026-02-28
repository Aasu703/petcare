import 'package:flutter/material.dart';
import 'package:petcare/features/messages/presentation/view_model/chat_view_model.dart';

class ConversationTile extends StatelessWidget {
  final ChatConversation conversation;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = conversation.participantName;
    final subtitle = conversation.lastMessage.trim().isEmpty
        ? (conversation.participantSubtitle ?? '')
        : conversation.lastMessage;

    return ListTile(
      leading: CircleAvatar(
        child: Text(
          title.isNotEmpty ? title.substring(0, 1).toUpperCase() : '?',
        ),
      ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Text(
        _formatTime(conversation.lastMessageAt),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: onTap,
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final local = dateTime.toLocal();
    final isToday =
        now.year == local.year &&
        now.month == local.month &&
        now.day == local.day;
    if (isToday) {
      final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
      final minute = local.minute.toString().padLeft(2, '0');
      final suffix = local.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $suffix';
    }
    return '${local.month}/${local.day}/${local.year.toString().substring(2)}';
  }
}
