import 'package:flutter/material.dart';
import 'package:petcare/app/l10n/app_localizations.dart';
import 'package:petcare/shared/widgets/index.dart';

/// Signup form section containing all input fields
/// Handles both user and provider registration forms
class SignupFormSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;
  final bool isProvider;
  final bool showPassword;
  final bool showConfirmPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;

  const SignupFormSection({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneController,
    required this.isProvider,
    required this.showPassword,
    required this.showConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: -10,
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            // Name fields - only for pet owners
            if (!isProvider)
              Row(
                children: [
                  Expanded(
                    child: FormTextField(
                      controller: firstNameController,
                      hintText: 'First',
                      labelText: 'First Name',
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context).tr('required');
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: FormTextField(
                      controller: lastNameController,
                      hintText: AppLocalizations.of(context).tr('lastNameHint'),
                      labelText: AppLocalizations.of(context).tr('lastName'),
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context).tr('required');
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            if (!isProvider) const SizedBox(height: 18),

            // Email field
            FormTextField(
              controller: emailController,
              hintText: AppLocalizations.of(context).tr('emailHint'),
              labelText: AppLocalizations.of(context).tr('emailAddress'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context).tr('emailRequired');
                }
                if (!value.contains('@')) {
                  return AppLocalizations.of(context).tr('enterValidEmail');
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // Phone field
            FormTextField(
              controller: phoneController,
              hintText: AppLocalizations.of(context).tr('phoneHint'),
              labelText: AppLocalizations.of(context).tr('phoneNumber'),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context).tr('phoneRequired');
                }
                if (value.length < 10) {
                  return AppLocalizations.of(context).tr('enterValidPhone');
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // Password field
            FormTextField(
              controller: passwordController,
              hintText: '••••••••',
              labelText: AppLocalizations.of(context).tr('password'),
              obscureText: !showPassword,
              keyboardType: TextInputType.text,
              suffixIcon: showPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              onSuffixIconPressed: onTogglePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context).tr('passwordRequired');
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // Confirm password field
            FormTextField(
              controller: confirmPasswordController,
              hintText: '••••••••',
              labelText: AppLocalizations.of(context).tr('confirmPassword'),
              obscureText: !showConfirmPassword,
              keyboardType: TextInputType.text,
              suffixIcon: showConfirmPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              onSuffixIconPressed: onToggleConfirmPassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(
                    context,
                  ).tr('pleaseConfirmPassword');
                }
                if (value != passwordController.text) {
                  return AppLocalizations.of(context).tr('passwordsDoNotMatch');
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
