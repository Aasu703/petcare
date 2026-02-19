import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/messages/presentation/pages/chat_conversation_screen.dart';
import 'package:petcare/features/messages/presentation/provider/chat_providers.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  final String title;
  final String emptyText;

  const MessagesScreen({
    super.key,
    this.title = 'Messages',
    this.emptyText = 'No conversations yet',
  });

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  @override
  void initState() {
    super.initState();
    final sessionService = ref.read(userSessionServiceProvider);
    if (sessionService.isLoggedIn()) {
      Future.microtask(
        () => ref.read(chatNotifierProvider.notifier).loadConversations(),
      );
    }
  }

  Future<void> _openConversation({
    required String participantId,
    required String participantRole,
    required String participantName,
    String? participantSubtitle,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatConversationScreen(
          participantId: participantId,
          participantRole: participantRole,
          participantName: participantName,
          participantSubtitle: participantSubtitle,
        ),
      ),
    );

    if (!mounted) return;
    await ref.read(chatNotifierProvider.notifier).loadConversations();
  }

  Future<void> _showContactsSheet() async {
    final notifier = ref.read(chatNotifierProvider.notifier);
    await notifier.loadContacts();
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(chatNotifierProvider);
            final contacts = state.contacts;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Start New Chat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (state.isLoadingContacts)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 22),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (contacts.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'No chat contacts found yet. Contacts appear after bookings.',
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 420),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: contacts.length,
                          itemBuilder: (context, index) {
                            final contact = contacts[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  contact.name.isNotEmpty
                                      ? contact.name
                                            .substring(0, 1)
                                            .toUpperCase()
                                      : '?',
                                ),
                              ),
                              title: Text(contact.name),
                              subtitle: Text(
                                contact.subtitle ?? contact.participantRole,
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                _openConversation(
                                  participantId: contact.participantId,
                                  participantRole: contact.participantRole,
                                  participantName: contact.name,
                                  participantSubtitle: contact.subtitle,
                                );
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionService = ref.watch(userSessionServiceProvider);
    final state = ref.watch(chatNotifierProvider);

    if (!sessionService.isLoggedIn()) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('Please log in to view messages')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: _showContactsSheet,
            icon: const Icon(Icons.add_comment_rounded),
            tooltip: 'New Chat',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(chatNotifierProvider.notifier).loadConversations(),
        child: state.isLoadingConversations && state.conversations.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.error != null && state.conversations.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 80),
                  Center(child: Text('Error: ${state.error}')),
                ],
              )
            : state.conversations.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 80),
                  Center(child: Text(widget.emptyText)),
                ],
              )
            : ListView.separated(
                itemCount: state.conversations.length,
                separatorBuilder: (_, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final conversation = state.conversations[index];
                  final title = conversation.participantName;
                  final subtitle = conversation.lastMessage.trim().isEmpty
                      ? (conversation.participantSubtitle ?? '')
                      : conversation.lastMessage;

                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        title.isNotEmpty
                            ? title.substring(0, 1).toUpperCase()
                            : '?',
                      ),
                    ),
                    title: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      _formatTime(conversation.lastMessageAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    onTap: () {
                      _openConversation(
                        participantId: conversation.participantId,
                        participantRole: conversation.participantRole,
                        participantName: conversation.participantName,
                        participantSubtitle: conversation.participantSubtitle,
                      );
                    },
                  );
                },
              ),
      ),
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
