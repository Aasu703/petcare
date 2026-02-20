import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/features/messages/presentation/view_model/chat_view_model.dart';
import 'package:petcare/features/messages/presentation/widgets/chat_message_input_bar.dart';
import 'package:petcare/features/messages/presentation/widgets/chat_message_list.dart';

class ChatConversationScreen extends ConsumerStatefulWidget {
  final String participantId;
  final String participantRole;
  final String participantName;
  final String? participantSubtitle;

  const ChatConversationScreen({
    super.key,
    required this.participantId,
    required this.participantRole,
    required this.participantName,
    this.participantSubtitle,
  });

  @override
  ConsumerState<ChatConversationScreen> createState() =>
      _ChatConversationScreenState();
}

class _ChatConversationScreenState
    extends ConsumerState<ChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref
          .read(chatViewModelProvider.notifier)
          .loadConversationMessages(
            participantId: widget.participantId,
            participantRole: widget.participantRole,
          );
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final sent = await ref
        .read(chatViewModelProvider.notifier)
        .sendMessage(
          participantId: widget.participantId,
          participantRole: widget.participantRole,
          content: text,
        );

    if (!sent) return;

    _messageController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatViewModelProvider);
    final notifier = ref.read(chatViewModelProvider.notifier);
    final currentUserId = notifier.currentUserId;
    final currentUserRole = notifier.currentUserRole;

    if (state.messages.length > _lastMessageCount) {
      _lastMessageCount = state.messages.length;
      _scrollToBottom();
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.participantName),
            if (widget.participantSubtitle != null &&
                widget.participantSubtitle!.trim().isNotEmpty)
              Text(
                widget.participantSubtitle!,
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatMessageList(
              state: state,
              scrollController: _scrollController,
              currentUserId: currentUserId,
              currentUserRole: currentUserRole,
            ),
          ),
          ChatMessageInputBar(
            controller: _messageController,
            isSending: state.isSending,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}
