import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/posts/presentation/provider/post_providers.dart';

class PostsScreen extends ConsumerStatefulWidget {
  const PostsScreen({super.key});

  @override
  ConsumerState<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends ConsumerState<PostsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final sessionService = ref.read(userSessionServiceProvider);
    if (sessionService.isLoggedIn() && sessionService.getRole() == 'provider') {
      Future.microtask(
        () => ref.read(postNotifierProvider.notifier).getAllPosts(),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionService = ref.watch(userSessionServiceProvider);
    final state = ref.watch(postNotifierProvider);

    if (!sessionService.isLoggedIn()) {
      return Scaffold(
        appBar: AppBar(title: const Text('Posts')),
        body: const Center(child: Text('Please log in to view posts')),
      );
    }

    if (sessionService.getRole() != 'provider') {
      return Scaffold(
        appBar: AppBar(title: const Text('Posts')),
        body: const Center(
          child: Text('Only providers can view and create posts'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      body: Column(
        children: [
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? Center(child: Text('Error: ${state.error}'))
                : ListView.builder(
                    itemCount: state.posts.length,
                    itemBuilder: (context, index) {
                      final post = state.posts[index];
                      return ListTile(
                        title: Text(post.title),
                        subtitle: Text(post.content),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Enter title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: 'Enter content',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isNotEmpty &&
                        _contentController.text.isNotEmpty) {
                      ref
                          .read(postNotifierProvider.notifier)
                          .createPost(
                            _titleController.text,
                            _contentController.text,
                          );
                      _titleController.clear();
                      _contentController.clear();
                    }
                  },
                  child: const Text('Create Post'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
