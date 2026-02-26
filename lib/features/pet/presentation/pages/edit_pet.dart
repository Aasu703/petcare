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
import 'package:petcare/features/pet/presentation/widgets/pet_form_field_widgets.dart';
import 'package:petcare/shared/widgets/index.dart';

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

  late String _selectedSpecies;
  File? _imageFile;
  final _imagePicker = ImagePicker();

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

    final success = await ref
        .read(petNotifierProvider.notifier)
        .updatePet(params);

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
    final hasNetworkImage = _imageFile == null && resolvedImageUrl != null;

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
                              child: _imageFile != null
                                  ? ClipOval(
                                      child: Image.file(
                                        _imageFile!,
                                        width: 116,
                                        height: 116,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : hasNetworkImage
                                  ? ClipOval(
                                      child: Image.network(
                                        resolvedImageUrl,
                                        width: 116,
                                        height: 116,
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
                                                  width: 22,
                                                  height: 22,
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
                                                const Icon(
                                                  Icons.pets,
                                                  size: 48,
                                                  color: AppColors.primaryColor,
                                                ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.pets,
                                      size: 48,
                                      color: AppColors.primaryColor,
                                    ),
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
                      'Change pet photo',
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
