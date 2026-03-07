import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petcare/app/l10n/app_localizations.dart';
import 'package:petcare/app/theme/app_colors.dart';

/// Pet image picker with camera/gallery options
/// Displays a circular avatar with add photo functionality
class PetImagePicker extends StatelessWidget {
  final File? imageFile;
  final String? networkImageUrl;
  final VoidCallback onTap;

  const PetImagePicker({
    super.key,
    this.imageFile,
    this.networkImageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: 0.3),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 58,
                  backgroundColor: AppColors.primaryColor.withValues(
                    alpha: 0.1,
                  ),
                  backgroundImage: _getBackgroundImage(),
                  child: _getBackgroundImage() == null
                      ? const Icon(
                          Icons.pets,
                          size: 48,
                          color: AppColors.primaryColor,
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.backgroundColor,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 20,
                    color: AppColors.buttonTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          imageFile != null || networkImageUrl != null
              ? l10n.tr('changePetPhoto')
              : l10n.tr('addPetPhoto'),
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  ImageProvider? _getBackgroundImage() {
    if (imageFile != null) {
      return FileImage(imageFile!);
    } else if (networkImageUrl != null && networkImageUrl!.isNotEmpty) {
      return NetworkImage(networkImageUrl!);
    }
    return null;
  }
}

/// Image picker bottom sheet modal
/// Provides camera and gallery options
class ImagePickerModal {
  static void show(
    BuildContext context, {
    required Function(ImageSource) onSourceSelected,
  }) {
    final l10n = AppLocalizations.of(context);
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
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.primaryColor,
              ),
              title: Text(l10n.tr('chooseFromGallery')),
              onTap: () {
                Navigator.pop(context);
                onSourceSelected(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: AppColors.primaryColor,
              ),
              title: Text(l10n.tr('takePhoto')),
              onTap: () {
                Navigator.pop(context);
                onSourceSelected(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
