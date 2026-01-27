import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/features/pet/domain/entities/pet_entity.dart';
import 'package:petcare/features/pet/presentation/providers/pet_providers.dart';

class AddPet extends ConsumerStatefulWidget {
  const AddPet({super.key});

  @override
  ConsumerState<AddPet> createState() => _AddPetState();
}

class _AddPetState extends ConsumerState<AddPet> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedGender = '';
  String? _imagePath;

  IconData _getIconForGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return Icons.male;
      case 'female':
        return Icons.female;
      default:
        return Icons.pets;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.iconSecondaryColor,
        title: Text(
          'Add Pet',
          style: TextStyle(color: AppColors.textPrimaryColor),
        ),
      ),
      body: Container(
        color: AppColors.iconPrimaryColor,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pet Photo Picker (UI only)
              Center(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // _pickMedia();
                      },
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: AppColors.iconSecondaryColor,
                            child: Icon(
                              Icons.pets,
                              size: 60,
                              color: AppColors.iconPrimaryColor,
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: CircleAvatar(
                              backgroundColor: AppColors.iconPrimaryColor,
                              child: Icon(
                                Icons.camera_alt,
                                color: AppColors.iconSecondaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Pet Name Field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Pet Name',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              // Gender Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.pets, size: 18, color: AppColors.iconPrimaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Gender',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedGender = 'male';
                        });
                      },
                      icon: Icon(
                        Icons.male,
                        color: AppColors.iconSecondaryColor,
                      ),
                      label: const Text('Male'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _selectedGender == 'male'
                            ? AppColors.iconSecondaryColor
                            : Colors.white,
                        foregroundColor: _selectedGender == 'male'
                            ? Colors.white
                            : AppColors.iconSecondaryColor,
                        side: BorderSide(color: AppColors.iconSecondaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedGender = 'female';
                        });
                      },
                      icon: Icon(
                        Icons.female,
                        color: AppColors.iconSecondaryColor,
                      ),
                      label: const Text('Female'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _selectedGender == 'female'
                            ? AppColors.iconSecondaryColor
                            : Colors.white,
                        foregroundColor: _selectedGender == 'female'
                            ? Colors.white
                            : AppColors.iconSecondaryColor,
                        side: BorderSide(color: AppColors.iconSecondaryColor),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Add Pet Button
              ElevatedButton(
                onPressed: () async {
                  final name = _nameController.text.trim();
                  if (name.isEmpty || _selectedGender.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter all fields.')),
                    );
                    return;
                  }
                  final pet = PetEntity(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    gender: _selectedGender,
                    imagePath: _imagePath,
                  );
                  // Add pet using use case/provider
                  ref.read(petListProvider.notifier).addPet(pet);
                  // Optionally, clear fields or navigate
                  _nameController.clear();
                  setState(() {
                    _selectedGender = '';
                  });
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Pet added!')));
                },
                child: const Text('Add Pet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.iconSecondaryColor,
                  foregroundColor: AppColors.textPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text(
          'Media access permission was denied. Please enable it in settings to select a photo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    final hasPermission = await _requestCameraPermission(Permission.camera);
    if (!hasPermission) return;

    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo != null) {
      // Handle the selected photo
      setState(() {
        _selectedMedia.clear();
        _selectedMedia.add(photo);
        _selectedMediaType = 'photo';
      });
      // Upload photo or perform further actions to server
      await ref
          .read(PetViewModelProvider.notifier)
          .uploadPhoto(File(photo.path));
    }
  }
}
