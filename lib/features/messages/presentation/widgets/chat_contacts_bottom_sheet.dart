import 'package:flutter/material.dart';
import 'package:petcare/app/l10n/app_localizations.dart';
import 'package:petcare/features/messages/presentation/view_model/chat_view_model.dart';

class ChatContactsBottomSheet extends StatelessWidget {
  final ChatState state;
  final ValueChanged<ChatContact> onContactTap;

  const ChatContactsBottomSheet({
    super.key,
    required this.state,
    required this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final contacts = state.contacts;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.tr('startNewChat'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (state.isLoadingContacts)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 22),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (contacts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(l10n.tr('noContactsYet')),
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
                              ? contact.name.substring(0, 1).toUpperCase()
                              : '?',
                        ),
                      ),
                      title: Text(contact.name),
                      subtitle: Text(
                        contact.subtitle ?? contact.participantRole,
                      ),
                      onTap: () => onContactTap(contact),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
