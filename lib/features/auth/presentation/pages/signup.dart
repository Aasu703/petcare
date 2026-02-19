import 'package:flutter/material.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare/app/routes/route_paths.dart';
import 'package:petcare/features/auth/di/auth_providers.dart';
import 'package:petcare/features/auth/domain/usecases/register_usecase.dart';
import 'package:petcare/features/auth/presentation/widgets/account_type_chip.dart';
import 'package:petcare/features/auth/presentation/widgets/auth_form_field.dart';

class Signup extends ConsumerStatefulWidget {
  const Signup({super.key});

  @override
  ConsumerState<Signup> createState() => _SignupState();
}

class _SignupState extends ConsumerState<Signup>
    with SingleTickerProviderStateMixin {
  // Controllers
  final _newEmailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Focus nodes
  final FocusNode _newEmailFocusNode = FocusNode();
  final FocusNode _newPasswordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final FocusNode _fnameFocusNode = FocusNode();
  final FocusNode _lnameFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();

  // Form key
  final _formKey = GlobalKey<FormState>();

  bool _isProvider = false;
  bool _isSubmitting = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _newEmailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _fnameController.dispose();
    _lnameController.dispose();
    _phoneController.dispose();
    _newEmailFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _fnameFocusNode.dispose();
    _lnameFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Animated gradient background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.accentColor.withValues(alpha: 0.08),
                      context.backgroundColor,
                      context.accentColor.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),

            // Floating orbs with blur effect
            Positioned(
              right: -80,
              top: 100,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentColor.withValues(alpha: 0.15),
                      AppColors.accentColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: -60,
              bottom: 150,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentColor.withValues(alpha: 0.12),
                      AppColors.accentColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Animated header icon
                      Center(
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.accentColor,
                                  AppColors.accentColor.withValues(alpha: 0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentColor.withValues(
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
                              size: 45,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Create Account',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1,
                                    fontSize: 32,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Join our pet-loving community 🐾',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Glass morphism form card
                      Container(
                        width: double.infinity,
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
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                              spreadRadius: -10,
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Name row - only show for users
                              if (!_isProvider)
                                Row(
                                  children: [
                                    Expanded(
                                      child: AuthFormField(
                                        controller: _fnameController,
                                        focusNode: _fnameFocusNode,
                                        hint: 'First',
                                        label: 'First Name',
                                        icon: Icons.person_outline_rounded,
                                        keyboardType: TextInputType.name,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: AuthFormField(
                                        controller: _lnameController,
                                        focusNode: _lnameFocusNode,
                                        hint: 'Last',
                                        label: 'Last Name',
                                        icon: Icons.person_outline_rounded,
                                        keyboardType: TextInputType.name,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              if (!_isProvider) const SizedBox(height: 18),
                              AuthFormField(
                                controller: _newEmailController,
                                focusNode: _newEmailFocusNode,
                                hint: 'example@email.com',
                                label: 'Email Address',
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
                              const SizedBox(height: 18),
                              AuthFormField(
                                controller: _phoneController,
                                focusNode: _phoneFocusNode,
                                hint: '+1234567890',
                                label: 'Phone Number',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Phone number is required';
                                  }
                                  if (value.length < 10) {
                                    return 'Enter a valid phone number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),
                              AuthFormField(
                                controller: _newPasswordController,
                                focusNode: _newPasswordFocusNode,
                                hint: '••••••••',
                                label: 'Password',
                                icon: Icons.lock_outline_rounded,
                                obscure: !_showPassword,
                                keyboardType: TextInputType.text,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _showPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showPassword = !_showPassword;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (value.length < 6) {
                                    return 'Min 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),
                              AuthFormField(
                                controller: _confirmPasswordController,
                                focusNode: _confirmPasswordFocusNode,
                                hint: '••••••••',
                                label: 'Confirm Password',
                                icon: Icons.lock_outline_rounded,
                                obscure: !_showConfirmPassword,
                                keyboardType: TextInputType.text,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _showConfirmPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showConfirmPassword =
                                          !_showConfirmPassword;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Confirm your password';
                                  }
                                  if (value != _newPasswordController.text) {
                                    return 'Passwords don\'t match';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 28),

                              // Modern account type section
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.accentColor.withValues(
                                        alpha: 0.08,
                                      ),
                                      AppColors.accentColor.withValues(
                                        alpha: 0.04,
                                      ),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.accentColor.withValues(
                                      alpha: 0.15,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.accentColor
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.badge_outlined,
                                            size: 20,
                                            color: AppColors.accentColor,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Account Type',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AccountTypeChip(
                                            label: 'Pet Owner',
                                            icon: Icons.pets,
                                            selected: !_isProvider,
                                            onTap: () {
                                              setState(() {
                                                _isProvider = false;
                                              });
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: AccountTypeChip(
                                            label: 'Provider',
                                            icon: Icons.store_rounded,
                                            selected: _isProvider,
                                            onTap: () {
                                              setState(() {
                                                _isProvider = true;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 28),

                              // Modern sign up button
                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: ElevatedButton(
                                  onPressed: _isSubmitting
                                      ? null
                                      : _onSignupPressed,
                                  style:
                                      ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.accentColor,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shadowColor: AppColors.accentColor
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
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _isProvider
                                                  ? 'Continue to Provider Signup'
                                                  : 'Create Account',
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w700,
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

                      // Login link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    fontSize: 15,
                                  ),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.push(RoutePaths.login);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppColors.accentColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Sign In',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.accentColor,
                                        fontSize: 15,
                                      ),
                                ),
                              ),
                            ),
                          ],
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

  Future<void> _onSignupPressed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_isProvider) {
        context.push(RoutePaths.providerRegister);
      } else {
        final usecase = ref.read(registerUsecaseProvider);

        final email = _newEmailController.text.trim();
        final password = _newPasswordController.text;
        final confirmPassword = _confirmPasswordController.text;
        final firstName = _fnameController.text.trim();
        final lastName = _lnameController.text.trim();
        final phoneNumber = _phoneController.text.trim();

        final result = await usecase(
          RegisterUsecaseParams(
            email: email,
            firstName: firstName,
            lastName: lastName,
            password: password,
            confirmPassword: confirmPassword,
            phoneNumber: phoneNumber,
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Account created successfully. Please log in.',
                ),
                backgroundColor: Colors.green.shade400,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            context.go(RoutePaths.login);
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
