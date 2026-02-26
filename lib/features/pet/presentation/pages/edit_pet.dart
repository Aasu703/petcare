import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/core/api/api_endpoints.dart';
import 'package:petcare/features/pet/domain/entities/pet_entity.dart';
import 'package:petcare/features/pet/domain/usecase/update_pet_usecase.dart';
import 'package:petcare/features/pet/presentation/provider/pet_providers.dart';
import 'package:petcare/features/pet/presentation/widgets/common/pet_image_picker.dart';
import 'package:petcare/features/pet/presentation/widgets/common/pet_form_section.dart';
import 'package:petcare/shared/widgets/index.dart';

/// Edit existing pet screen
/// Allows users to update pet profile details
class EditPetScreen extends ConsumerStatefulWidget {
  final PetEntity pet;

  const EditPetScreen({super.key, required this.pet});

  @override
  ConsumerState<EditPetScreen> createState() => _EditPetScreenState();
}

class _EditPetScreenState extends ConsumerState<EditPetScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _breedController;
  late final TextEditingController _ageController;
  late final TextEditingController _weightController;
  final _imagePicker = ImagePicker();

  late String _selectedSpecies;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet.name);
    _breedController = TextEditingController(text: widget.pet.breed ?? '');
    _ageController = TextEditingController(
      text: widget.pet.age?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: widget.pet.weight?.toString() ?? '',
    );
    _selectedSpecies = widget.pet.species;
  }

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

    final params = UpdatePetParams(
      petId: widget.pet.petId ?? '',
      name: _nameController.text.trim(),
      species: _selectedSpecies,
      breed: _breedController.text.trim().isEmpty
          ? null
          : _breedController.text.trim(),
      age: age,
      weight: weight,
      imageUrl: _imageFile?.path ?? widget.pet.imageUrl,
    );

    final success =
        await ref.read(petNotifierProvider.notifier).updatePet(params);

    if (!mounted) return;

    if (success) {
      AppSnackBar.showSuccess(context, 'Pet updated successfully');
      Navigator.pop(context, true);
    } else {
      final error = ref.read(petNotifierProvider).error;
      AppSnackBar.showError(context, error ?? 'Failed to update pet');
    }
  }

  @override
  Widget build(BuildContext context) {
    final petState = ref.watch(petNotifierProvider);
    final imageUrl = widget.pet.imageUrl;
    final resolvedImageUrl = (imageUrl != null && imageUrl.isNotEmpty)
        ? ApiEndpoints.resolveMediaUrl(imageUrl)
        : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit Pet', style: Theme.of(context).textTheme.titleLarge),
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
                      networkImageUrl: resolvedImageUrl,
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
                text: 'Update Pet',
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
