import 'package:flutter/material.dart';
import 'package:petcare/features/messages/presentation/pages/messages_screen.dart';

class ProviderMessagesScreen extends StatelessWidget {
  const ProviderMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MessagesScreen(
      title: 'Vet & Pet Owner Messages',
      emptyText: 'No messages yet. Start the conversation with pet owners.',
    );
  }
}
