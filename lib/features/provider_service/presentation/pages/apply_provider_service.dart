import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/provider_service/domain/entities/provider_service_entity.dart';
import 'package:petcare/features/provider_service/presentation/view_model/provider_service_view_model.dart';
import 'package:petcare/app/l10n/app_localizations.dart';

class ApplyProviderServiceScreen extends ConsumerStatefulWidget {
  final String? initialServiceType;
  final bool lockServiceType;

  const ApplyProviderServiceScreen({
    super.key,
    this.initialServiceType,
    this.lockServiceType = false,
  });

  @override
  ConsumerState<ApplyProviderServiceScreen> createState() =>
      _ApplyProviderServiceScreenState();
}

class _ApplyProviderServiceScreenState
    extends ConsumerState<ApplyProviderServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _registrationController = TextEditingController();
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();
  String? _selectedServiceType;

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
      final List<XFile> files = await _picker.pickMultiImage();
      if (files.isNotEmpty) {
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
    if (_selectedServiceType == null || _selectedServiceType!.isEmpty) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.tr('pleaseSelectServiceType')),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final entity = ProviderServiceEntity(
      serviceType: _selectedServiceType!,
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
      final l10nSnack = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10nSnack.tr('applicationSubmitted'))),
      );
      Navigator.pop(context, true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.error!)));
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedServiceType = widget.initialServiceType;
  }

  @override
  void dispose() {
    _registrationController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(providerServiceProvider);
    final session = ref.watch(userSessionServiceProvider);
    final providerType = (session.getProviderType() ?? '').toLowerCase();
    final serviceOptions = _serviceOptionsForProvider(providerType, l10n);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tr('applyForProviderService'))),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedServiceType,
                decoration: InputDecoration(
                  labelText: l10n.tr('serviceType'),
                  border: OutlineInputBorder(),
                ),
                items: serviceOptions
                    .map(
                      (option) => DropdownMenuItem<String>(
                        value: option.value,
                        child: Text(option.label),
                      ),
                    )
                    .toList(),
                onChanged: widget.lockServiceType
                    ? null
                    : (value) {
                        setState(() {
                          _selectedServiceType = value;
                        });
                      },
                validator: (value) => value == null || value.isEmpty
                    ? l10n.tr('selectServiceType')
                    : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _registrationController,
                decoration: InputDecoration(
                  labelText: _selectedServiceType == 'vet'
                      ? '${l10n.tr('medicalRegistrationNumber')} *'
                      : l10n.tr('registrationNumber'),
                ),
                validator: (value) {
                  if (_selectedServiceType == 'vet') {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.tr('registrationNumberRequired');
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(labelText: l10n.tr('bio')),
                maxLines: 3,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _experienceController,
                decoration: InputDecoration(labelText: l10n.tr('experience')),
                maxLines: 2,
              ),
              SizedBox(height: 16),
              if (_selectedServiceType == 'vet') ...[
                ElevatedButton.icon(
                  onPressed: () => _pickImageFor(
                    (p) => setState(() => _medicalLicensePath = p),
                  ),
                  icon: Icon(Icons.attach_file),
                  label: Text(
                    _medicalLicensePath == null
                        ? '${l10n.tr('pickMedicalLicense')} *'
                        : l10n.tr('medicalSelected'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                  ),
                ),
                SizedBox(height: 8),
              ],
              if (_selectedServiceType == 'groomer') ...[
                ElevatedButton.icon(
                  onPressed: () => _pickImageFor(
                    (p) => setState(() => _certificationPath = p),
                  ),
                  icon: Icon(Icons.attach_file),
                  label: Text(
                    _certificationPath == null
                        ? '${l10n.tr('pickCertification')} *'
                        : l10n.tr('certSelected'),
                  ),
                ),
                SizedBox(height: 8),
              ],
              if (_selectedServiceType == 'shop_owner') ...[
                ElevatedButton.icon(
                  onPressed: () => _pickImageFor(
                    (p) => setState(() => _businessRegPath = p),
                  ),
                  icon: Icon(Icons.document_scanner),
                  label: Text(
                    _businessRegPath == null
                        ? '${l10n.tr('pickBusinessRegistration')} *'
                        : l10n.tr('businessSelected'),
                  ),
                ),
                SizedBox(height: 8),
              ],
              if (_selectedServiceType == 'boarding') ...[
                ElevatedButton.icon(
                  onPressed: () =>
                      _pickImageFor((p) => setState(() {}), multiple: true),
                  icon: Icon(Icons.photo_library),
                  label: Text(
                    _facilityImages.isEmpty
                        ? '${l10n.tr('pickFacilityImages')} *'
                        : '${_facilityImages.length} ${l10n.tr('imagesCount')}',
                  ),
                ),
                SizedBox(height: 8),
              ],
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
                        child: Text(l10n.tr('submitApplication')),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceTypeOption {
  final String value;
  final String label;

  const _ServiceTypeOption({required this.value, required this.label});
}

List<_ServiceTypeOption> _serviceOptionsForProvider(
  String providerType,
  AppLocalizations l10n,
) {
  switch (providerType) {
    case 'vet':
      return [
        _ServiceTypeOption(value: 'vet', label: l10n.tr('veterinaryServices')),
        _ServiceTypeOption(value: 'boarding', label: l10n.tr('boarding')),
      ];
    case 'shop':
      return [
        _ServiceTypeOption(value: 'shop_owner', label: l10n.tr('shopOwner')),
      ];
    case 'babysitter':
      return [
        _ServiceTypeOption(value: 'groomer', label: l10n.tr('grooming')),
        _ServiceTypeOption(value: 'boarding', label: l10n.tr('boarding')),
      ];
    default:
      return [
        _ServiceTypeOption(value: 'vet', label: l10n.tr('veterinaryServices')),
        _ServiceTypeOption(value: 'groomer', label: l10n.tr('grooming')),
        _ServiceTypeOption(value: 'boarding', label: l10n.tr('boarding')),
        _ServiceTypeOption(value: 'shop_owner', label: l10n.tr('shopOwner')),
      ];
  }
}
