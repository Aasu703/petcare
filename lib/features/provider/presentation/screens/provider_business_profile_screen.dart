import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/api/api_client.dart';
import 'package:petcare/core/api/api_endpoints.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/provider/domain/utils/provider_access.dart';

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

  String? _providerType;
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
      _businessNameController.text =
          profile['businessName']?.toString() ?? '';
      _addressController.text = profile['address']?.toString() ?? '';
      _phoneController.text = profile['phone']?.toString() ?? '';
      _emailController.text = profile['email']?.toString() ?? '';
      _certificationController.text =
          profile['certification']?.toString() ?? '';
      _experienceController.text = profile['experience']?.toString() ?? '';
      _clinicOrShopController.text =
          profile['clinicOrShopName']?.toString() ?? '';
      _panNumberController.text = profile['panNumber']?.toString() ?? '';
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
    setState(() => _isSaving = true);
    try {
      final api = ref.read(apiClientProvider);
      final payload = <String, dynamic>{
        'businessName': _businessNameController.text.trim(),
        'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'certification': _certificationController.text.trim(),
        'experience': _experienceController.text.trim(),
        'clinicOrShopName': _clinicOrShopController.text.trim(),
        'panNumber': _panNumberController.text.trim().toUpperCase(),
      };

      final response = await api.put(ApiEndpoints.providerProfile, data: payload);
      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] != false) {
        final updated = (data['data'] as Map<String, dynamic>?) ?? payload;
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
          const SnackBar(content: Text('Business profile updated')),
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
                                child: CircularProgressIndicator(strokeWidth: 2),
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
