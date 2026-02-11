import 'package:flutter/material.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/features/provider/di/provider_providers.dart';
import 'package:petcare/features/provider/domain/usecases/provider_register_usecase.dart';
import 'package:petcare/features/provider/presentation/screens/provider_dashboard_screen.dart';
import 'package:petcare/core/widget/mytextformfield.dart';
import 'package:petcare/app/theme/theme_extensions.dart';

class ProviderSetupScreen extends ConsumerStatefulWidget {
  final String email;
  final String password;
  final String confirmPassword;

  ProviderSetupScreen({
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

    final usecase = ref.read(providerRegisterUsecaseProvider);
    final result = await usecase(
      ProviderRegisterUsecaseParams(
        email: widget.email,
        password: widget.password,
        confirmPassword: widget.confirmPassword,
        businessName: _businessNameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
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
        // Save session or something? For now, just navigate
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ProviderDashboardScreen()),
          (route) => false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                          color: context.textPrimary.withOpacity(0.08),
                          blurRadius: 16,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
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
            color: context.textPrimary.withOpacity(isFocused ? 0.10 : 0.06),
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
