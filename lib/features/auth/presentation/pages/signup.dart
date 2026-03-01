import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare/app/routes/route_paths.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/features/auth/presentation/providers/auth_providers.dart';
import 'package:petcare/features/auth/domain/usecases/register_usecase.dart';
import 'package:petcare/features/auth/presentation/widgets/common/auth_background.dart';
import 'package:petcare/features/auth/presentation/widgets/common/auth_animated_header.dart';
import 'package:petcare/features/auth/presentation/widgets/signup/signup_form_section.dart';
import 'package:petcare/features/auth/presentation/widgets/signup/signup_account_type_section.dart';
import 'package:petcare/features/auth/presentation/widgets/signup/signup_actions_section.dart';
import 'package:petcare/features/auth/presentation/widgets/signup/signup_footer.dart';

/// Sign up page for new user registration
/// Supports both pet owner and provider account creation
class Signup extends ConsumerStatefulWidget {
  const Signup({super.key});

  @override
  ConsumerState<Signup> createState() => _SignupState();
}

class _SignupState extends ConsumerState<Signup>
    with SingleTickerProviderStateMixin {
  // Form controllers
  final _newEmailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // State
  bool _isProvider = false;
  bool _isSubmitting = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  // Animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Background
            const AuthBackground(),

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

                      // Header Icon
                      AuthAnimatedHeader(scaleAnimation: _scaleAnimation),
                      const SizedBox(height: 30),

                      // Welcome Text
                      _buildWelcomeText(context),
                      const SizedBox(height: 40),

                      // Form Section
                      SignupFormSection(
                        formKey: _formKey,
                        emailController: _newEmailController,
                        passwordController: _newPasswordController,
                        confirmPasswordController: _confirmPasswordController,
                        firstNameController: _fnameController,
                        lastNameController: _lnameController,
                        phoneController: _phoneController,
                        isProvider: _isProvider,
                        showPassword: _showPassword,
                        showConfirmPassword: _showConfirmPassword,
                        onTogglePassword: () =>
                            setState(() => _showPassword = !_showPassword),
                        onToggleConfirmPassword: () => setState(
                          () => _showConfirmPassword = !_showConfirmPassword,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Account Type Section
                      SignupAccountTypeSection(
                        isProvider: _isProvider,
                        onAccountTypeChanged: (isProvider) =>
                            setState(() => _isProvider = isProvider),
                      ),
                      const SizedBox(height: 28),

                      // Actions Section
                      SignupActionsSection(
                        isSubmitting: _isSubmitting,
                        isProvider: _isProvider,
                        onSignupPressed: _onSignupPressed,
                      ),
                      const SizedBox(height: 32),

                      // Footer
                      const SignupFooter(),
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

  Widget _buildWelcomeText(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            'Create Account',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 32,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Join PawCare today',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.black.withValues(alpha: 0.5),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSignupPressed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (_isProvider) {
        // Redirect to provider-specific signup
        if (!mounted) return;
        context.push(RoutePaths.providerRegister);
      } else {
        // Register pet owner
        final usecase = ref.read(registerUsecaseProvider);
        final result = await usecase(
          RegisterUsecaseParams(
            email: _newEmailController.text.trim(),
            firstName: _fnameController.text.trim(),
            lastName: _lnameController.text.trim(),
            password: _newPasswordController.text,
            confirmPassword: _confirmPasswordController.text,
            phoneNumber: _phoneController.text.trim(),
          ),
        );

        if (!mounted) return;

        result.fold(
          (failure) {
            _showErrorSnackBar(failure.message);
          },
          (_) {
            _showSuccessSnackBar();
            context.go(RoutePaths.login);
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Account created successfully. Please log in.'),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
