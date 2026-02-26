import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/features/pet/domain/usecase/addpet_usecase.dart';
import 'package:petcare/features/pet/presentation/pages/pet_care_screen.dart';
import 'package:petcare/features/pet/presentation/provider/pet_providers.dart';
import 'package:petcare/features/pet/presentation/widgets/common/pet_image_picker.dart';
import 'package:petcare/features/pet/presentation/widgets/common/pet_form_section.dart';
import 'package:petcare/shared/widgets/index.dart';

/// Add new pet screen
/// Allows users to create a new pet profile with image, name, species, and details
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
  final _imagePicker = ImagePicker();

  String _selectedSpecies = 'dog';
  File? _imageFile;

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
    ImagePickerModal.show(
      context,
      onSourceSelected: _pickImage,
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
                    // Image Picker
                    PetImagePicker(
                      imageFile: _imageFile,
                      onTap: _showImagePicker,
                    ),
                    const SizedBox(height: 32),

                    // Form Section
                    PetFormSection(
                      formKey: _formKey,
                      nameController: _nameController,
                      breedController: _breedController,
                      ageController: _ageController,
                      weightController: _weightController,
                      selectedSpecies: _selectedSpecies,
                      onSpeciesChanged: (value) {
                        setState(() => _selectedSpecies = value);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Action Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: PrimaryButton(
                text: 'Add Pet',
                onPressed: _submit,
                isLoading: petState.isLoading,
                height: 56,
                borderRadius: 12,
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
