import 'package:flutter/material.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';

class LoginContent extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final Animation<double> scaleAnimation;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onLoginTap;
  final VoidCallback onSignupTap;
  final VoidCallback onProviderLoginTap;
  final VoidCallback onForgotPasswordTap;

  const LoginContent({
    super.key,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.scaleAnimation,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onLoginTap,
    required this.onSignupTap,
    required this.onProviderLoginTap,
    required this.onForgotPasswordTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.primaryColor.withValues(alpha: 0.08),
                      context.backgroundColor,
                      context.primaryColor.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -80,
              top: 80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.iconPrimaryColor.withValues(alpha: 0.15),
                      AppColors.iconPrimaryColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: -60,
              bottom: 200,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.iconPrimaryColor.withValues(alpha: 0.12),
                      AppColors.iconPrimaryColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      Center(
                        child: ScaleTransition(
                          scale: scaleAnimation,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  context.primaryColor,
                                  context.primaryColor.withValues(alpha: 0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: context.primaryColor.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                  spreadRadius: -5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.pets,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Welcome Back',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1,
                                    fontSize: 34,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Sign in to continue to PawCare',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: context.textPrimary.withValues(
                                      alpha: 0.6,
                                    ),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: context.textPrimary.withValues(
                                alpha: 0.08,
                              ),
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
                              _LoginField(
                                controller: emailController,
                                label: 'Email Address',
                                hint: 'example@email.com',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email is required';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              _LoginField(
                                controller: passwordController,
                                label: 'Password',
                                hint: '********',
                                icon: Icons.lock_outline_rounded,
                                obscureText: obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 20,
                                  ),
                                  onPressed: onTogglePassword,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: onForgotPasswordTap,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                  ),
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: AppColors.iconPrimaryColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : onLoginTap,
                                  style:
                                      ElevatedButton.styleFrom(
                                        backgroundColor: context.primaryColor,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shadowColor: context.primaryColor
                                            .withValues(alpha: 0.4),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                      ).copyWith(
                                        elevation:
                                            WidgetStateProperty.resolveWith((
                                              states,
                                            ) {
                                              if (states.contains(
                                                WidgetState.pressed,
                                              )) {
                                                return 0;
                                              }
                                              return 8;
                                            }),
                                      ),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor: AlwaysStoppedAnimation(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'Sign In',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 17,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 22,
                                              color: Colors.white.withValues(
                                                alpha: 0.95,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: context.textPrimary.withValues(
                                      alpha: 0.6,
                                    ),
                                    fontSize: 15,
                                  ),
                            ),
                            GestureDetector(
                              onTap: onSignupTap,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppColors.iconPrimaryColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Sign Up',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.iconPrimaryColor,
                                        fontSize: 15,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: context.textPrimary.withValues(alpha: 0.1),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or',
                              style: TextStyle(
                                color: context.textPrimary.withValues(
                                  alpha: 0.5,
                                ),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: context.textPrimary.withValues(alpha: 0.1),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.iconPrimaryColor.withValues(
                                alpha: 0.3,
                              ),
                              width: 1.5,
                            ),
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onProviderLoginTap,
                              borderRadius: BorderRadius.circular(16),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.store_rounded,
                                      size: 20,
                                      color: AppColors.iconPrimaryColor,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Login as Provider',
                                      style: TextStyle(
                                        color: AppColors.iconPrimaryColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _LoginField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          color: context.textPrimary.withValues(alpha: 0.35),
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          color: context.textPrimary.withValues(alpha: 0.6),
          fontWeight: FontWeight.w600,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.iconPrimaryColor,
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.iconPrimaryColor.withValues(alpha: 0.7),
          size: 22,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: context.textPrimary.withValues(alpha: 0.08),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: context.textPrimary.withValues(alpha: 0.08),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.iconPrimaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
