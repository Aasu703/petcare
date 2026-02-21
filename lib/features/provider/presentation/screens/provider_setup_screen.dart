import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/routes/route_paths.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/features/provider/di/provider_providers.dart';
import 'package:petcare/features/provider/domain/usecases/provider_register_usecase.dart';
import 'package:petcare/core/widget/mytextformfield.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/features/provider/presentation/screens/provider_location_picker_screen.dart';

class ProviderSetupScreen extends ConsumerStatefulWidget {
  final String email;
  final String password;
  final String confirmPassword;

  const ProviderSetupScreen({
    super.key,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  @override
  ConsumerState<ProviderSetupScreen> createState() =>
      _ProviderSetupScreenState();
}

class _ProviderSetupScreenState extends ConsumerState<ProviderSetupScreen> {
  final _businessNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedProviderType;
  double? _locationLatitude;
  double? _locationLongitude;
  String _locationNote = '';

  final FocusNode _businessNameFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _businessNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _businessNameFocusNode.dispose();
    _addressFocusNode.dispose();
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _completeSetup() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    if (_selectedProviderType == null || _selectedProviderType!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a provider type'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final requiresPinnedLocation =
        _selectedProviderType == 'shop' || _selectedProviderType == 'vet';
    if (requiresPinnedLocation &&
        (_locationLatitude == null || _locationLongitude == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please pin your clinic/shop location on map to continue',
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final usecase = ref.read(providerRegisterUsecaseProvider);
    final result = await usecase(
      ProviderRegisterUsecaseParams(
        email: widget.email,
        password: widget.password,
        confirmPassword: widget.confirmPassword,
        businessName: _businessNameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        providerType: _selectedProviderType!,
        locationLatitude: _locationLatitude,
        locationLongitude: _locationLongitude,
        locationAddress: _locationNote.trim().isEmpty
            ? null
            : _locationNote.trim(),
      ),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      (_) {
        context.go(RoutePaths.providerDashboard);
      },
    );
  }

  Future<void> _pickLocationOnMap() async {
    final result = await Navigator.of(context).push<ProviderLocationPickResult>(
      MaterialPageRoute(
        builder: (_) => ProviderLocationPickerScreen(
          title: _selectedProviderType == 'vet'
              ? 'Pin Clinic Location'
              : 'Pin Shop Location',
          initialLatitude: _locationLatitude,
          initialLongitude: _locationLongitude,
          initialNote: _locationNote,
        ),
      ),
    );

    if (!mounted || result == null) return;
    setState(() {
      _locationLatitude = result.latitude;
      _locationLongitude = result.longitude;
      _locationNote = result.locationNote;
    });
  }

  @override
  Widget build(BuildContext context) {
    final requiresPinnedLocation =
        _selectedProviderType == 'shop' || _selectedProviderType == 'vet';
    final hasPinnedLocation =
        _locationLatitude != null && _locationLongitude != null;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: 140,
              child: Opacity(
                opacity: 0.12,
                child: Icon(
                  Icons.store_mall_directory_rounded,
                  size: 180,
                  color: AppColors.accentColor,
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: 160,
              child: Opacity(
                opacity: 0.12,
                child: Icon(
                  Icons.pets,
                  size: 220,
                  color: AppColors.accentColor,
                ),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create provider profile',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Tell pet owners about your business',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: context.textPrimary.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: _selectedProviderType,
                            decoration: const InputDecoration(
                              labelText: 'Provider type',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'vet',
                                child: Text('Veterinary Clinic'),
                              ),
                              DropdownMenuItem(
                                value: 'shop',
                                child: Text('Pet Shop'),
                              ),
                              DropdownMenuItem(
                                value: 'babysitter',
                                child: Text('Groomer / Babysitter'),
                              ),
                            ],
                            onChanged: (value) =>
                                setState(() => _selectedProviderType = value),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Select provider type'
                                : null,
                          ),
                          if (requiresPinnedLocation) ...[
                            SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceColor,
                                borderRadius: BorderRadius.circular(14),
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
                                    _selectedProviderType == 'vet'
                                        ? 'Clinic map location'
                                        : 'Shop map location',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
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
                                  if (_locationNote.trim().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        _locationNote.trim(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: _pickLocationOnMap,
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
                                ],
                              ),
                            ),
                          ],
                          SizedBox(height: 18),
                          _field(
                            controller: _businessNameController,
                            focusNode: _businessNameFocusNode,
                            hint: 'Happy Paws Clinic',
                            label: 'Business name',
                            icon: Icons.storefront_rounded,
                          ),
                          SizedBox(height: 18),
                          _field(
                            controller: _addressController,
                            focusNode: _addressFocusNode,
                            hint: '123 Pet Street, City',
                            label: 'Address',
                            icon: Icons.location_on_rounded,
                          ),
                          SizedBox(height: 18),
                          _field(
                            controller: _phoneController,
                            focusNode: _phoneFocusNode,
                            hint: '+1 234 567 890',
                            label: 'Phone number',
                            icon: Icons.phone_rounded,
                            keyboardType: TextInputType.phone,
                          ),
                          SizedBox(height: 18),
                          _field(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            hint: 'email@example.com',
                            label: 'Email',
                            icon: Icons.email_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _completeSetup,
                              child: Text('Finish setup'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final isFocused = focusNode.hasFocus;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: context.textPrimary.withValues(
              alpha: isFocused ? 0.10 : 0.06,
            ),
            blurRadius: isFocused ? 14 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: MyTextformfield(
        controller: controller,
        focusNode: focusNode,
        hintText: hint,
        labelText: label,
        errorMessage: '$label is empty',
        prefixIcon: Icon(icon, color: AppColors.iconPrimaryColor),
        filled: true,
        fillcolor: AppColors.surfaceColor,
        keyboardType: keyboardType,
      ),
    );
  }
}
