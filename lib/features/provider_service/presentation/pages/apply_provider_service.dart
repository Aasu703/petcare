import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/features/provider_service/domain/entities/provider_service_entity.dart';
import 'package:petcare/features/provider_service/presentation/view_model/provider_service_view_model.dart';

class ApplyProviderServiceScreen extends ConsumerStatefulWidget {
  const ApplyProviderServiceScreen({super.key});

  @override
  ConsumerState<ApplyProviderServiceScreen> createState() =>
      _ApplyProviderServiceScreenState();
}

class _ApplyProviderServiceScreenState
    extends ConsumerState<ApplyProviderServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceTypeController = TextEditingController();
  final _registrationController = TextEditingController();
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();

  String? _medicalLicensePath;
  String? _certificationPath;
  String? _businessRegPath;
  List<String> _facilityImages = [];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageFor(
    Function(String) setter, {
    bool multiple = false,
  }) async {
    if (multiple) {
      final List<XFile>? files = await _picker.pickMultiImage();
      if (files != null && files.isNotEmpty) {
        setState(() {
          _facilityImages = files.map((e) => e.path).toList();
        });
      }
      return;
    }

    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) setter(file.path);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final entity = ProviderServiceEntity(
      serviceType: _serviceTypeController.text.trim(),
      registrationNumber: _registrationController.text.trim().isEmpty
          ? null
          : _registrationController.text.trim(),
      bio: _bioController.text.trim().isEmpty
          ? null
          : _bioController.text.trim(),
      experience: _experienceController.text.trim().isEmpty
          ? null
          : _experienceController.text.trim(),
    );

    await ref
        .read(providerServiceProvider.notifier)
        .applyForService(
          entity,
          medicalLicensePath: _medicalLicensePath,
          certificationPath: _certificationPath,
          facilityImagePaths: _facilityImages,
          businessRegistrationPath: _businessRegPath,
        );

    final state = ref.read(providerServiceProvider);
    if (state.error == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Application submitted')));
      Navigator.pop(context, true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.error!)));
    }
  }

  @override
  void dispose() {
    _serviceTypeController.dispose();
    _registrationController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(providerServiceProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Apply for Provider Service')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _serviceTypeController,
                decoration: InputDecoration(labelText: 'Service Type'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter service type'
                    : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _registrationController,
                decoration: InputDecoration(labelText: 'Registration Number'),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(labelText: 'Bio'),
                maxLines: 3,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _experienceController,
                decoration: InputDecoration(labelText: 'Experience'),
                maxLines: 2,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImageFor(
                        (p) => setState(() => _medicalLicensePath = p),
                      ),
                      icon: Icon(Icons.attach_file),
                      label: Text(
                        _medicalLicensePath == null
                            ? 'Pick Medical License'
                            : 'Medical Selected',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImageFor(
                        (p) => setState(() => _certificationPath = p),
                      ),
                      icon: Icon(Icons.attach_file),
                      label: Text(
                        _certificationPath == null
                            ? 'Pick Certification'
                            : 'Cert Selected',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () =>
                    _pickImageFor((p) => setState(() => _businessRegPath = p)),
                icon: Icon(Icons.document_scanner),
                label: Text(
                  _businessRegPath == null
                      ? 'Pick Business Registration'
                      : 'Business Selected',
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () =>
                    _pickImageFor((p) => setState(() {}), multiple: true),
                icon: Icon(Icons.photo_library),
                label: Text(
                  _facilityImages.isEmpty
                      ? 'Pick Facility Images'
                      : '${_facilityImages.length} images',
                ),
              ),
              SizedBox(height: 24),
              state.isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 12,
                        ),
                        child: Text('Submit Application'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
