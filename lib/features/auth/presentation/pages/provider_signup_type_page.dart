import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare/app/l10n/app_localizations.dart';
import 'package:petcare/app/routes/route_paths.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/features/auth/presentation/widgets/provider_type_selector.dart';
import 'package:petcare/features/provider/domain/usecases/provider_register_usecase.dart';
import 'package:petcare/features/provider/presentation/pages/provider_location_picker_screen.dart';
import 'package:petcare/features/provider/presentation/provider/provider_providers.dart';

class ProviderSignupTypePage extends ConsumerStatefulWidget {
  final String email;
  final String password;
  final String confirmPassword;
  final String businessName;
  final String address;
  final String phone;

  const ProviderSignupTypePage({
    super.key,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.businessName,
    required this.address,
    required this.phone,
  });

  @override
  ConsumerState<ProviderSignupTypePage> createState() =>
      _ProviderSignupTypePageState();
}

class _ProviderSignupTypePageState
    extends ConsumerState<ProviderSignupTypePage> {
  String? _selectedProviderType;
  bool _showProviderTypeError = false;
  bool _isSubmitting = false;
  double? _locationLatitude;
  double? _locationLongitude;
  String _locationNote = '';

  Future<void> _pickLocationOnMap() async {
    final title = _selectedProviderType == 'vet'
        ? AppLocalizations.of(context).tr('pinClinicLocation')
        : AppLocalizations.of(context).tr('pinShopLocation');
    final result = await Navigator.of(context).push<ProviderLocationPickResult>(
      MaterialPageRoute(
        builder: (_) => ProviderLocationPickerScreen(
          title: title,
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

  Future<void> _submit() async {
    if (_selectedProviderType == null || _selectedProviderType!.isEmpty) {
      setState(() {
        _showProviderTypeError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).tr('pleaseChooseProviderType'),
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

    setState(() {
      _isSubmitting = true;
    });

    try {
      final usecase = ref.read(providerRegisterUsecaseProvider);
      final params = ProviderRegisterUsecaseParams(
        email: widget.email,
        password: widget.password,
        confirmPassword: widget.confirmPassword,
        businessName: widget.businessName,
        address: widget.address,
        phone: widget.phone,
        providerType: _selectedProviderType!,
        locationLatitude: _locationLatitude,
        locationLongitude: _locationLongitude,
        locationAddress: _locationNote.trim().isEmpty ? null : _locationNote,
      );

      final result = await usecase(params);

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).tr('providerAccountCreated'),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          context.go(RoutePaths.providerLogin);
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final requiresPinnedLocation =
        _selectedProviderType == 'shop' || _selectedProviderType == 'vet';
    final hasPinnedLocation =
        _locationLatitude != null && _locationLongitude != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).tr('providerType')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 2: Select provider type',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).tr('createProviderAccount'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            ProviderTypeSelector(
              selectedProviderType: _selectedProviderType,
              showError: _showProviderTypeError,
              onSelected: (value) {
                setState(() {
                  _selectedProviderType = value;
                  _showProviderTypeError = false;
                });
              },
            ),
            if (requiresPinnedLocation) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                    Row(
                      children: [
                        Icon(
                          Icons.location_pin,
                          color: hasPinnedLocation
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFEF6C00),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedProviderType == 'vet'
                                ? AppLocalizations.of(
                                    context,
                                  ).tr('clinicMapLocation')
                                : AppLocalizations.of(
                                    context,
                                  ).tr('shopMapLocation'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasPinnedLocation
                          ? 'Pinned at ${_locationLatitude!.toStringAsFixed(6)}, ${_locationLongitude!.toStringAsFixed(6)}'
                          : AppLocalizations.of(
                              context,
                            ).tr('pinExactBusinessLocation'),
                      style: TextStyle(
                        color: hasPinnedLocation
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFF6D4C41),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
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
                              ? Icons.edit_location_alt
                              : Icons.map_outlined,
                          color: AppColors.iconPrimaryColor,
                        ),
                        label: Text(
                          hasPinnedLocation
                              ? AppLocalizations.of(
                                  context,
                                ).tr('updatePinOnMap')
                              : AppLocalizations.of(context).tr('pinOnMap'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.iconPrimaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        AppLocalizations.of(
                          context,
                        ).tr('createProviderAccount'),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
