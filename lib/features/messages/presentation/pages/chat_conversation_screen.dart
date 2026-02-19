import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/features/messages/presentation/provider/chat_providers.dart';

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

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref
          .read(chatNotifierProvider.notifier)
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
        .read(chatNotifierProvider.notifier)
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
    final state = ref.watch(chatNotifierProvider);
    final notifier = ref.read(chatNotifierProvider.notifier);
    final currentUserId = notifier.currentUserId;
    final currentUserRole = notifier.currentUserRole;
    final messages = state.messages;

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
            child: state.isLoadingMessages && messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.error != null && messages.isEmpty
                ? Center(child: Text('Error: ${state.error}'))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMine =
                          message.senderId == currentUserId &&
                          message.senderRole == currentUserRole;

                      return Align(
                        alignment: isMine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          constraints: const BoxConstraints(maxWidth: 320),
                          decoration: BoxDecoration(
                            color: isMine
                                ? const Color(
                                    0xFFF59E0B,
                                  ).withValues(alpha: 0.16)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isMine
                                  ? const Color(
                                      0xFFF59E0B,
                                    ).withValues(alpha: 0.45)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.content,
                                style: const TextStyle(fontSize: 15),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _formatTime(message.createdAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: IconButton(
                      onPressed: state.isSending ? null : _sendMessage,
                      icon: state.isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final local = dateTime.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final suffix = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}
