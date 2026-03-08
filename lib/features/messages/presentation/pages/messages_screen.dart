import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/app/l10n/app_localizations.dart';
import 'package:petcare/core/services/storage/recent_activity_service.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/messages/presentation/pages/chat_conversation_screen.dart';
import 'package:petcare/features/messages/presentation/view_model/chat_view_model.dart';
import 'package:petcare/features/messages/presentation/widgets/chat_contacts_bottom_sheet.dart';
import 'package:petcare/features/messages/presentation/widgets/conversations_list_view.dart';

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
  Timer? _refreshTimer;

  Future<void> _trackChatOpen(String participantName) async {
    final userId = ref.read(userSessionServiceProvider).getUserId();
    if (userId == null || userId.isEmpty) return;
    await ref
        .read(recentActivityServiceProvider)
        .pushActivity(
          userId: userId,
          title: 'Chat',
          subtitle: 'Opened chat with $participantName',
          kind: 'chat',
        );
  }

  @override
  void initState() {
    super.initState();
    final sessionService = ref.read(userSessionServiceProvider);
    if (sessionService.isLoggedIn()) {
      Future.microtask(
        () => ref.read(chatViewModelProvider.notifier).loadConversations(),
      );

      // Refresh conversations list every 5 seconds
      _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (mounted) {
          ref.read(chatViewModelProvider.notifier).loadConversations();
        }
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _openConversation({
    required String participantId,
    required String participantRole,
    required String participantName,
    String? participantSubtitle,
  }) async {
    await _trackChatOpen(participantName);
    if (!mounted) return;
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
    await ref.read(chatViewModelProvider.notifier).loadConversations();
  }

  Future<void> _showContactsSheet() async {
    final notifier = ref.read(chatViewModelProvider.notifier);
    await notifier.loadContacts();
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(chatViewModelProvider);
            return ChatContactsBottomSheet(
              state: state,
              onContactTap: (contact) {
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sessionService = ref.watch(userSessionServiceProvider);
    final state = ref.watch(chatViewModelProvider);

    if (!sessionService.isLoggedIn()) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.tr('messages'))),
        body: Center(child: Text(l10n.tr('pleaseLoginMessages'))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('messages')),
        actions: [
          IconButton(
            onPressed: _showContactsSheet,
            icon: const Icon(Icons.add_comment_rounded),
            tooltip: l10n.tr('newChat'),
          ),
        ],
      ),
      body: ConversationsListView(
        state: state,
        emptyText: widget.emptyText,
        onRefresh: () =>
            ref.read(chatViewModelProvider.notifier).loadConversations(),
        onConversationTap: (conversation) {
          _openConversation(
            participantId: conversation.participantId,
            participantRole: conversation.participantRole,
            participantName: conversation.participantName,
            participantSubtitle: conversation.participantSubtitle,
          );
        },
      ),
    );
  }
}
