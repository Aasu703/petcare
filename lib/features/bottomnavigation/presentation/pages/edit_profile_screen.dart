import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/core/api/api_endpoints.dart';
import 'package:petcare/features/auth/presentation/view_model/profile_view_model.dart';
import 'package:petcare/shared/widgets/index.dart';
import 'package:petcare/shared/utils/snackbar_service.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _localImage;
  String? _existingImageUrl;
  final _imagePicker = ImagePicker();
  bool _didPrefill = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(profileViewModelProvider.notifier).loadProfile(),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _localImage = File(picked.path);
      });
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await ref
        .read(profileViewModelProvider.notifier)
        .updateProfile(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          imageFile: _localImage,
        );

    if (!mounted) return;

    if (success) {
      SnackbarService.success(
        context: context,
        message: 'Profile updated successfully',
      );
      Navigator.pop(context, true);
    } else {
      final error = ref.read(profileViewModelProvider).errorMessage;
      SnackbarService.error(
        context: context,
        message: error ?? 'Failed to update profile',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    if (!_didPrefill && profileState.user != null) {
      final user = profileState.user!;
      _firstNameController.text = _firstNameController.text.isNotEmpty
          ? _firstNameController.text
          : user.FirstName;
      _lastNameController.text = user.LastName;
      _emailController.text = _emailController.text.isNotEmpty
          ? _emailController.text
          : user.email;
      _phoneController.text = user.phoneNumber;
      _existingImageUrl = user.avatar;
      _didPrefill = true;
    }

    final resolvedExistingImageUrl =
        (_existingImageUrl != null && _existingImageUrl!.isNotEmpty)
        ? ApiEndpoints.resolveMediaUrl(_existingImageUrl!)
        : null;
    final hasNetworkImage =
        _localImage == null && resolvedExistingImageUrl != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showImagePicker,
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.borderColor.withValues(
                                  alpha: 0.3,
                                ),
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor: context.surfaceColor,
                              child: _localImage != null
                                  ? ClipOval(
                                      child: Image.file(
                                        _localImage!,
                                        width: 96,
                                        height: 96,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : hasNetworkImage
                                  ? ClipOval(
                                      child: Image.network(
                                        resolvedExistingImageUrl,
                                        width: 96,
                                        height: 96,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (
                                              context,
                                              child,
                                              loadingProgress,
                                            ) => loadingProgress == null
                                            ? child
                                            : const Center(
                                                child: SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: AppColors
                                                            .primaryColor,
                                                      ),
                                                ),
                                              ),
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(
                                                  Icons.person,
                                                  size: 40,
                                                  color: context.textSecondary,
                                                ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 40,
                                      color: context.textSecondary,
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: context.backgroundColor,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 16,
                                color: AppColors.buttonTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FormLabel(
                            text: 'First Name',
                            fontWeight: FontWeight.w500,
                            color: context.textSecondary,
                          ),
                          const SizedBox(height: 8),
                          FormTextField(
                            controller: _firstNameController,
                            hintText: 'Enter your first name',
                            borderRadius: 5,
                            fillColor: context.surfaceColor,
                            hintColor: context.hintColor,
                            borderColor: context.borderColor,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'First name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          FormLabel(
                            text: 'Last Name',
                            fontWeight: FontWeight.w500,
                            color: context.textSecondary,
                          ),
                          const SizedBox(height: 8),
                          FormTextField(
                            controller: _lastNameController,
                            hintText: 'Enter your last name',
                            borderRadius: 5,
                            fillColor: context.surfaceColor,
                            hintColor: context.hintColor,
                            borderColor: context.borderColor,
                          ),
                          const SizedBox(height: 20),
                          FormLabel(
                            text: 'Email',
                            fontWeight: FontWeight.w500,
                            color: context.textSecondary,
                          ),
                          const SizedBox(height: 8),
                          FormTextField(
                            controller: _emailController,
                            hintText: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                            borderRadius: 5,
                            fillColor: context.surfaceColor,
                            hintColor: context.hintColor,
                            borderColor: context.borderColor,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          FormLabel(
                            text: 'Phone',
                            fontWeight: FontWeight.w500,
                            color: context.textSecondary,
                          ),
                          const SizedBox(height: 8),
                          FormTextField(
                            controller: _phoneController,
                            hintText: 'Enter your phone number',
                            keyboardType: TextInputType.phone,
                            borderRadius: 5,
                            fillColor: context.surfaceColor,
                            hintColor: context.hintColor,
                            borderColor: context.borderColor,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: PrimaryButton(
                text: 'SAVE CHANGES',
                onPressed: _submit,
                isLoading: profileState.isLoading,
                height: 56,
                borderRadius: 5,
                backgroundColor: AppColors.buttonPrimaryColor,
                foregroundColor: AppColors.buttonTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
