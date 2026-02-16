import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/messages/presentation/provider/message_providers.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final sessionService = ref.read(userSessionServiceProvider);
    if (sessionService.isLoggedIn()) {
      Future.microtask(
        () => ref.read(messageNotifierProvider.notifier).getMyMessages(),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionService = ref.watch(userSessionServiceProvider);
    final state = ref.watch(messageNotifierProvider);

    if (!sessionService.isLoggedIn()) {
      return Scaffold(
        appBar: AppBar(title: const Text('Messages')),
        body: const Center(child: Text('Please log in to view messages')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: Column(
        children: [
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? Center(child: Text('Error: ${state.error}'))
                : ListView.builder(
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return ListTile(
                        title: Text(message.content),
                        subtitle: Text(message.createdAt?.toString() ?? ''),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      ref
                          .read(messageNotifierProvider.notifier)
                          .createMessage(_messageController.text);
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
