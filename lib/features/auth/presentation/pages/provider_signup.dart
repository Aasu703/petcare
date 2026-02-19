import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/features/provider/di/provider_providers.dart';
import 'package:petcare/features/provider/domain/usecases/provider_register_usecase.dart';
import 'package:petcare/features/provider/presentation/screens/provider_login_screen.dart';
import 'package:petcare/features/auth/presentation/widgets/auth_form_field.dart';
import 'package:petcare/features/auth/presentation/widgets/provider_type_selector.dart';

class ProviderSignupScreen extends ConsumerStatefulWidget {
  const ProviderSignupScreen({super.key});

  @override
  ConsumerState<ProviderSignupScreen> createState() =>
      _ProviderSignupScreenState();
}

class _ProviderSignupScreenState extends ConsumerState<ProviderSignupScreen>
    with SingleTickerProviderStateMixin {
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  // Focus nodes
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final FocusNode _businessNameFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();

  // Form key
  final _formKey = GlobalKey<FormState>();

  bool _isSubmitting = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String? _selectedProviderType;
  bool _showProviderTypeError = false;

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
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _businessNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _businessNameFocusNode.dispose();
    _addressFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  Future<void> _tryRegister() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    if (_selectedProviderType == null || _selectedProviderType!.isEmpty) {
      setState(() {
        _showProviderTypeError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please choose a provider type to continue'),
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
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        businessName: _businessNameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        providerType: _selectedProviderType!,
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
                'Provider account created successfully! Please login to continue.',
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => ProviderLoginScreen()),
            (route) => false,
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
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
                  Icons.storefront_rounded,
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
                  Icons.business_rounded,
                  size: 220,
                  color: AppColors.accentColor,
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.arrow_back),
                                  color: AppColors.iconPrimaryColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Provider Sign Up',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Create your provider account',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 28),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
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
                                  const SizedBox(height: 18),
                                  AuthFormField(
                                    controller: _emailController,
                                    focusNode: _emailFocusNode,
                                    hint: 'Enter your email',
                                    label: 'Email',
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                      ).hasMatch(value)) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  AuthFormField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocusNode,
                                    hint: 'Enter your password',
                                    label: 'Password',
                                    icon: Icons.lock_outline_rounded,
                                    obscure: !_showPassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _showPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: AppColors.iconSecondaryColor,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _showPassword = !_showPassword;
                                        });
                                      },
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      if (value.length < 8) {
                                        return 'Password must be at least 8 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  AuthFormField(
                                    controller: _confirmPasswordController,
                                    focusNode: _confirmPasswordFocusNode,
                                    hint: 'Confirm your password',
                                    label: 'Confirm Password',
                                    icon: Icons.lock_outline_rounded,
                                    obscure: !_showConfirmPassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _showConfirmPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: AppColors.iconSecondaryColor,
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
                                        return 'Please confirm your password';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  AuthFormField(
                                    controller: _businessNameController,
                                    focusNode: _businessNameFocusNode,
                                    hint: 'Enter your business name',
                                    label: 'Business Name',
                                    icon: Icons.business_outlined,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your business name';
                                      }
                                      if (value.length < 2) {
                                        return 'Business name must be at least 2 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  AuthFormField(
                                    controller: _addressController,
                                    focusNode: _addressFocusNode,
                                    hint: 'Enter your business address',
                                    label: 'Address',
                                    icon: Icons.location_on_outlined,
                                    maxLines: 3,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your address';
                                      }
                                      if (value.length < 5) {
                                        return 'Address must be at least 5 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  AuthFormField(
                                    controller: _phoneController,
                                    focusNode: _phoneFocusNode,
                                    hint: 'Enter your phone number',
                                    label: 'Phone Number',
                                    icon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your phone number';
                                      }
                                      if (value.length < 10) {
                                        return 'Phone number must be at least 10 digits';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 32),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: _isSubmitting
                                          ? null
                                          : _tryRegister,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.iconPrimaryColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 2,
                                      ),
                                      child: _isSubmitting
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                          : const Text(
                                              'Create Provider Account',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
