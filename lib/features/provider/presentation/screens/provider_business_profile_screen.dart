import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/api/api_client.dart';
import 'package:petcare/core/api/api_endpoints.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/provider/domain/utils/provider_access.dart';
import 'package:petcare/features/provider/presentation/screens/provider_location_picker_screen.dart';

class ProviderBusinessProfileScreen extends ConsumerStatefulWidget {
  const ProviderBusinessProfileScreen({super.key});

  @override
  ConsumerState<ProviderBusinessProfileScreen> createState() =>
      _ProviderBusinessProfileScreenState();
}

class _ProviderBusinessProfileScreenState
    extends ConsumerState<ProviderBusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _certificationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _clinicOrShopController = TextEditingController();
  final _panNumberController = TextEditingController();
  final _locationNoteController = TextEditingController();

  String? _providerType;
  String _certificationDocumentUrl = '';
  bool _uploadingCertificate = false;
  double? _locationLatitude;
  double? _locationLongitude;
  bool _locationVerified = false;
  bool _pawcareVerified = false;
  String _status = 'pending';
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _certificationController.dispose();
    _experienceController.dispose();
    _clinicOrShopController.dispose();
    _panNumberController.dispose();
    _locationNoteController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiClientProvider);
      final response = await api.get(ApiEndpoints.providerMe);
      final data = response.data;
      final profile = data is Map<String, dynamic>
          ? (data['data'] as Map<String, dynamic>? ?? data)
          : <String, dynamic>{};

      _providerType = profile['providerType']?.toString();
      _businessNameController.text = profile['businessName']?.toString() ?? '';
      _addressController.text = profile['address']?.toString() ?? '';
      _phoneController.text = profile['phone']?.toString() ?? '';
      _emailController.text = profile['email']?.toString() ?? '';
      _certificationController.text =
          profile['certification']?.toString() ?? '';
      _certificationDocumentUrl =
          profile['certificationDocumentUrl']?.toString() ?? '';
      _experienceController.text = profile['experience']?.toString() ?? '';
      _clinicOrShopController.text =
          profile['clinicOrShopName']?.toString() ?? '';
      _panNumberController.text = profile['panNumber']?.toString() ?? '';
      final location = profile['location'];
      if (location is Map) {
        final latValue = location['latitude'];
        final lngValue = location['longitude'];
        _locationLatitude = latValue is num ? latValue.toDouble() : null;
        _locationLongitude = lngValue is num ? lngValue.toDouble() : null;
        _locationNoteController.text = location['address']?.toString() ?? '';
      } else {
        _locationLatitude = null;
        _locationLongitude = null;
        _locationNoteController.clear();
      }
      _locationVerified = profile['locationVerified'] == true;
      _pawcareVerified = profile['pawcareVerified'] == true;
      _status = profile['status']?.toString() ?? 'pending';
    } catch (_) {
      final session = ref.read(userSessionServiceProvider);
      _providerType = session.getProviderType();
      _businessNameController.text = session.getFirstName() ?? '';
      _emailController.text = session.getEmail() ?? '';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final isVet = isVetProvider(_providerType);
    final isShop = isShopProvider(_providerType);
    if ((isVet || isShop) &&
        (_locationLatitude == null || _locationLongitude == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please pin your clinic/shop location on map before saving.',
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final api = ref.read(apiClientProvider);
      final payload = <String, dynamic>{
        'businessName': _businessNameController.text.trim(),
        'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'certification': _certificationController.text.trim(),
        'certificationDocumentUrl': _certificationDocumentUrl,
        'experience': _experienceController.text.trim(),
        'clinicOrShopName': _clinicOrShopController.text.trim(),
        'panNumber': _panNumberController.text.trim().toUpperCase(),
        if (_locationLatitude != null && _locationLongitude != null)
          'location': {
            'latitude': _locationLatitude,
            'longitude': _locationLongitude,
            'address': _locationNoteController.text.trim(),
          },
      };

      final response = await api.put(
        ApiEndpoints.providerProfile,
        data: payload,
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] != false) {
        final updated = (data['data'] as Map<String, dynamic>?) ?? payload;
        final location = updated['location'];
        if (location is Map) {
          final latValue = location['latitude'];
          final lngValue = location['longitude'];
          _locationLatitude = latValue is num ? latValue.toDouble() : null;
          _locationLongitude = lngValue is num ? lngValue.toDouble() : null;
          _locationNoteController.text = location['address']?.toString() ?? '';
        }
        _locationVerified = updated['locationVerified'] == true;
        _pawcareVerified = updated['pawcareVerified'] == true;
        _status = updated['status']?.toString() ?? _status;
        _certificationDocumentUrl =
            updated['certificationDocumentUrl']?.toString() ??
            _certificationDocumentUrl;

        final session = ref.read(userSessionServiceProvider);
        await session.saveSession(
          userId: session.getUserId() ?? updated['_id']?.toString() ?? '',
          firstName:
              updated['businessName']?.toString() ??
              _businessNameController.text.trim(),
          email: updated['email']?.toString() ?? _emailController.text.trim(),
          lastName: '',
          role: 'provider',
          providerType:
              updated['providerType']?.toString() ?? session.getProviderType(),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message']?.toString() ?? 'Business profile updated',
            ),
          ),
        );
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVet = isVetProvider(_providerType);
    final isShop = isShopProvider(_providerType);
    final isGroomer = isGroomerProvider(_providerType);
    final hasPinnedLocation =
        _locationLatitude != null && _locationLongitude != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Business Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_pawcareVerified && (isVet || isShop)) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFB7E4C7)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              color: Color(0xFF2E7D32),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isShop
                                    ? 'PawCare Verified Shop'
                                    : 'PawCare Verified Vet',
                                style: const TextStyle(
                                  color: Color(0xFF1B5E20),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ] else if (isVet || isShop) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFE0B2)),
                        ),
                        child: Text(
                          _status == 'pending'
                              ? 'Location verification pending admin review.'
                              : _locationVerified
                              ? 'Location verified'
                              : 'Location not verified yet.',
                          style: const TextStyle(
                            color: Color(0xFF7A4E00),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    _input(
                      controller: _businessNameController,
                      label: 'Business Name',
                      icon: Icons.business_rounded,
                      requiredField: true,
                    ),
                    const SizedBox(height: 12),
                    _input(
                      controller: _addressController,
                      label: 'Address',
                      icon: Icons.location_on_rounded,
                      requiredField: true,
                    ),
                    const SizedBox(height: 12),
                    _input(
                      controller: _phoneController,
                      label: 'Phone',
                      icon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                      requiredField: true,
                    ),
                    const SizedBox(height: 12),
                    _input(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      requiredField: true,
                    ),
                    const SizedBox(height: 12),
                    if (isVet || isGroomer) ...[
                      _input(
                        controller: _experienceController,
                        label: 'Experience',
                        icon: Icons.work_history_rounded,
                        maxLines: 2,
                        requiredField: true,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (isVet) ...[
                      _input(
                        controller: _certificationController,
                        label: 'Certification',
                        icon: Icons.verified_rounded,
                        maxLines: 2,
                        requiredField: true,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _certificationDocumentUrl.isNotEmpty
                                ? const Color(0xFFB7E4C7)
                                : const Color(0xFFFFE0B2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Certificate File (PDF/Image)',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            if (_certificationDocumentUrl.isNotEmpty)
                              Text(
                                _fileNameFromPath(_certificationDocumentUrl),
                                style: const TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5,
                                ),
                              )
                            else
                              const Text(
                                'No certificate file attached yet.',
                                style: TextStyle(
                                  color: Color(0xFF7A4E00),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5,
                                ),
                              ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _uploadingCertificate
                                        ? null
                                        : _pickAndUploadCertificate,
                                    icon: Icon(
                                      _uploadingCertificate
                                          ? Icons.sync_rounded
                                          : Icons.upload_file_rounded,
                                    ),
                                    label: Text(
                                      _uploadingCertificate
                                          ? 'Uploading...'
                                          : (_certificationDocumentUrl.isEmpty
                                                ? 'Attach File'
                                                : 'Replace File'),
                                    ),
                                  ),
                                ),
                                if (_certificationDocumentUrl.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () {
                                      setState(
                                        () => _certificationDocumentUrl = '',
                                      );
                                    },
                                    tooltip: 'Remove file',
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (isVet || isShop) ...[
                      _input(
                        controller: _clinicOrShopController,
                        label: isVet ? 'Clinic Name' : 'Shop Name',
                        icon: Icons.storefront_rounded,
                        requiredField: true,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (isShop) ...[
                      _input(
                        controller: _panNumberController,
                        label: 'PAN Number',
                        icon: Icons.badge_rounded,
                        requiredField: true,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (isVet || isShop) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: hasPinnedLocation
                                ? const Color(0xFFB7E4C7)
                                : const Color(0xFFFFE0B2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isShop ? 'Shop Map Pin' : 'Clinic Map Pin',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              hasPinnedLocation
                                  ? '${_locationLatitude!.toStringAsFixed(6)}, ${_locationLongitude!.toStringAsFixed(6)}'
                                  : 'No map pin selected yet.',
                              style: TextStyle(
                                color: hasPinnedLocation
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFF7A4E00),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _openMapPicker,
                                icon: Icon(
                                  hasPinnedLocation
                                      ? Icons.edit_location_alt_rounded
                                      : Icons.map_outlined,
                                ),
                                label: Text(
                                  hasPinnedLocation
                                      ? 'Update Pin on Map'
                                      : 'Pin on Map',
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _locationNoteController,
                              decoration: const InputDecoration(
                                labelText: 'Location Note (Optional)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.notes_rounded),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveProfile,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_rounded),
                        label: Text(_isSaving ? 'Saving...' : 'Save Profile'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.of(context).push<ProviderLocationPickResult>(
      MaterialPageRoute(
        builder: (_) => ProviderLocationPickerScreen(
          title: isShopProvider(_providerType)
              ? 'Pin Shop Location'
              : 'Pin Clinic Location',
          initialLatitude: _locationLatitude,
          initialLongitude: _locationLongitude,
          initialNote: _locationNoteController.text,
        ),
      ),
    );

    if (!mounted || result == null) return;
    setState(() {
      _locationLatitude = result.latitude;
      _locationLongitude = result.longitude;
      _locationNoteController.text = result.locationNote;
    });
  }

  Future<void> _pickAndUploadCertificate() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
    );

    if (!mounted || result == null || result.files.isEmpty) return;
    final selected = result.files.single;
    final path = selected.path;
    if (path == null || path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected file path is not accessible.')),
      );
      return;
    }

    setState(() => _uploadingCertificate = true);
    try {
      final api = ref.read(apiClientProvider);
      final formData = FormData.fromMap({
        'certification_document': await MultipartFile.fromFile(
          path,
          filename: selected.name,
        ),
      });

      final response = await api.uploadFile(
        ApiEndpoints.providerCertificateUpload,
        formData: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] != false) {
        final uploadedPath = (data['data'] as Map?)?['path']?.toString() ?? '';
        if (uploadedPath.isEmpty) {
          throw Exception('Upload succeeded but file path was not returned');
        }

        setState(() => _certificationDocumentUrl = uploadedPath);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Certificate file uploaded')),
        );
      } else {
        throw Exception(data is Map ? data['message']?.toString() : null);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) {
        setState(() => _uploadingCertificate = false);
      }
    }
  }

  String _fileNameFromPath(String path) {
    final normalized = path.replaceAll('\\', '/');
    final segments = normalized.split('/');
    return segments.isEmpty ? path : segments.last;
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool requiredField = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      validator: (value) {
        if (!requiredField) return null;
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }
}
