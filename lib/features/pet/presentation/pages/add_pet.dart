import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/core/widget/app_button.dart';
import 'package:petcare/features/pet/domain/usecase/addpet_usecase.dart';
import 'package:petcare/features/pet/presentation/pages/pet_care_screen.dart';
import 'package:petcare/features/pet/presentation/provider/pet_providers.dart';
import 'package:petcare/features/pet/presentation/widgets/pet_form_field_widgets.dart';
import 'package:petcare/shared/widgets/app_snackbar.dart';

class AddPet extends ConsumerStatefulWidget {
  const AddPet({super.key});

  @override
  ConsumerState<AddPet> createState() => _AddPetState();
}

class _AddPetState extends ConsumerState<AddPet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();

  String _selectedSpecies = 'dog';
  File? _imageFile;
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() => _imageFile = File(image.path));
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
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.primaryColor,
              ),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: AppColors.primaryColor,
              ),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final int? age = _ageController.text.isNotEmpty
        ? int.tryParse(_ageController.text)
        : null;
    final double? weight = _weightController.text.isNotEmpty
        ? double.tryParse(_weightController.text)
        : null;

    final params = AddPetUsecaseParams(
      name: _nameController.text.trim(),
      species: _selectedSpecies,
      breed: _breedController.text.trim().isEmpty
          ? null
          : _breedController.text.trim(),
      age: age,
      weight: weight,
      imageUrl: _imageFile?.path,
    );

    final success = await ref.read(petNotifierProvider.notifier).addPet(params);

    if (!mounted) return;

    if (success) {
      AppSnackBar.showSuccess(context, 'Pet added successfully');
      final createdPet = ref.read(petNotifierProvider).recentlyAddedPet;
      if (createdPet != null) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PetCareScreen(pet: createdPet),
          ),
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      final error = ref.read(petNotifierProvider).error;
      AppSnackBar.showError(context, error ?? 'Failed to add pet');
    }
  }

  @override
  Widget build(BuildContext context) {
    final petState = ref.watch(petNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add New Pet',
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
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryColor.withValues(
                                  alpha: 0.3,
                                ),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 58,
                              backgroundColor: AppColors.primaryColor
                                  .withValues(alpha: 0.1),
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : null,
                              child: _imageFile == null
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
                      'Add pet photo',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const PetFormLabel(text: 'Pet Name'),
                          const SizedBox(height: 8),
                          PetFormTextField(
                            controller: _nameController,
                            hintText: 'Enter pet name',
                            prefixIcon: Icons.pets,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Pet name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          const PetFormLabel(text: 'Species'),
                          const SizedBox(height: 8),
                          PetSpeciesSelector(
                            selectedSpecies: _selectedSpecies,
                            onChanged: (value) {
                              setState(() => _selectedSpecies = value);
                            },
                          ),
                          const SizedBox(height: 20),
                          const PetFormLabel(text: 'Breed (Optional)'),
                          const SizedBox(height: 8),
                          PetFormTextField(
                            controller: _breedController,
                            hintText: 'Enter breed',
                            prefixIcon: Icons.category_outlined,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const PetFormLabel(text: 'Age (years)'),
                                    const SizedBox(height: 8),
                                    PetFormTextField(
                                      controller: _ageController,
                                      hintText: '0',
                                      prefixIcon: Icons.cake_outlined,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const PetFormLabel(text: 'Weight (kg)'),
                                    const SizedBox(height: 8),
                                    PetFormTextField(
                                      controller: _weightController,
                                      hintText: '0.0',
                                      prefixIcon: Icons.monitor_weight_outlined,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
              child: AppPrimaryButton(
                text: 'Add Pet',
                onPressed: _submit,
                isLoading: petState.isLoading,
                height: 56,
                borderRadius: 12,
                backgroundColor: AppColors.buttonPrimaryColor,
                foregroundColor: AppColors.buttonTextColor,
                disabledBackgroundColor: AppColors.disabledColor.withValues(
                  alpha: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
