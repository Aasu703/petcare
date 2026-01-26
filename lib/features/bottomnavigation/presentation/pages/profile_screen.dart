import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/core/providers/session_providers.dart';
import 'package:petcare/core/providers/theme_provider.dart';
import 'package:petcare/features/auth/presentation/pages/login.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String firstName;
  final String email;

  const ProfileScreen({super.key, this.firstName = 'User', this.email = ''});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late String name;
  File? profileImage;

  @override
  void initState() {
    super.initState();
    name = widget.firstName;
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        profileImage = File(image.path);
      });
    }
  }

  void _toggleTheme() {
    final themeMode = ref.read(themeModeProvider);
    ref
        .read(themeModeProvider.notifier)
        .setTheme(
          themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
        );
  }

  void editName() {
    final controller = TextEditingController(text: name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter your name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                name = controller.text.trim();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              ref.watch(themeModeProvider) == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            tooltip: ref.watch(themeModeProvider) == ThemeMode.light
                ? 'Switch to Dark Mode'
                : 'Switch to Light Mode',
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Image
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: profileImage != null
                      ? FileImage(profileImage!)
                      : null,
                  child: profileImage == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.iconPrimaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Name
            Text(
              name,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 4),

            // Email
            Text(
              widget.email.isNotEmpty ? widget.email : 'No email',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),

            const SizedBox(height: 12),

            // Edit Button
            TextButton(onPressed: editName, child: const Text('Edit Profile')),

            const SizedBox(height: 30),

            // Simple Menu
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.pets),
                    title: Text('My Pets'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text('Appointments'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                ),
                onPressed: () async {
                  await ref.read(sessionStateProvider.notifier).clearSession();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const Login()),
                    (_) => false,
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
