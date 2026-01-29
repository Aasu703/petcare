import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/core/providers/session_providers.dart';
import 'package:petcare/core/providers/theme_provider.dart';
import 'package:petcare/features/auth/presentation/pages/login.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic>? user;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5050/api/auth/whoami'),
        headers: {
          // 'Authorization': 'Bearer $token', // Add if needed
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          user = data['data'];
        });
      } else {
        print('Failed to load profile: ${response.body}');
        setState(() => user = null);
      }
    } catch (e) {
      print('Error fetching profile: $e');
      setState(() => user = null);
    }
    setState(() => isLoading = false);
  }

  Future<void> pickImage() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        await uploadProfileImage(File(image.path));
      }
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied to access gallery.')),
      );
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> uploadProfileImage(File imageFile) async {
    const String uploadUrl = 'http://10.0.2.2:5050/api/auth/update-profile';
    try {
      final mimeType =
          lookupMimeType(imageFile.path) ?? 'application/octet-stream';
      final request = http.MultipartRequest('PUT', Uri.parse(uploadUrl));
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType.parse(mimeType),
        ),
      );
      // Add headers or authentication if needed
      // request.headers['Authorization'] = 'Bearer <token>';

      final response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image uploaded successfully.')),
        );
        await fetchUserProfile(); // Refresh user data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image. (${response.statusCode})'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
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
    final controller = TextEditingController(text: user?['Firstname'] ?? '');

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
            onPressed: () async {
              Navigator.pop(ctx);
              await updateName(controller.text.trim());
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> updateName(String newName) async {
    const String updateUrl = 'http://10.0.2.2:5050/api/auth/update-profile';
    try {
      final response = await http.put(
        Uri.parse(updateUrl),
        headers: {
          'Content-Type': 'application/json',
          // Add auth header if needed
        },
        body: jsonEncode({'Firstname': newName}),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name updated successfully.')),
        );
        await fetchUserProfile();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update name.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating name: $e')));
    }
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
          ? const Center(child: Text('Failed to load user profile.'))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Image
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: user!['imageUrl'] != null
                            ? NetworkImage(
                                'http://10.0.2.2:5050${user!['imageUrl']}',
                              )
                            : null,
                        child: user!['imageUrl'] == null
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
                    user!['Firstname'] ?? 'User',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Email
                  Text(
                    user!['email'] ?? 'No email',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  // Edit Button
                  TextButton(
                    onPressed: editName,
                    child: const Text('Edit Profile'),
                  ),
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
                        await ref
                            .read(sessionStateProvider.notifier)
                            .clearSession();
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
