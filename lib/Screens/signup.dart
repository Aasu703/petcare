import 'package:flutter/material.dart';
import 'package:petcare/Screens/login.dart';
import 'package:petcare/widget/mytextformfield.dart';
import 'package:petcare/theme/app_colors.dart';
// import 'package:petcare/Screens/Dashboard.dart'; // Uncomment if you plan to navigate there.

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  // Controllers
  final _newEmailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();

  // Focus nodes
  final FocusNode _newEmailFocusNode = FocusNode();
  final FocusNode _newPasswordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final FocusNode _fnameFocusNode = FocusNode();
  final FocusNode _lnameFocusNode = FocusNode();

  // Form key
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Optional: listen to focus changes to update UI (e.g., highlight field)
    _newEmailFocusNode.addListener(_onFocusChanged);
    _newPasswordFocusNode.addListener(_onFocusChanged);
    _confirmPasswordFocusNode.addListener(_onFocusChanged);
    _fnameFocusNode.addListener(_onFocusChanged);
    _lnameFocusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    // If you want to react to focus changes (e.g., set state to change shadow),
    // do it here. For now, just calling setState() to trigger rebuild.
    setState(() {});
  }

  @override
  void dispose() {
    // Dispose controllers
    _newEmailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _fnameController.dispose();
    _lnameController.dispose();

    // Dispose focus nodes
    _newEmailFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _fnameFocusNode.dispose();
    _lnameFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative background icons
            Positioned(
              right: -40,
              top: 140,
              child: Opacity(
                opacity: 0.12,
                child: Icon(
                  Icons.pets,
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

            // Content
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create account',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Join our pet-loving community',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 28),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _field(
                            controller: _newEmailController,
                            focusNode: _newEmailFocusNode,
                            hint: 'example12@email.com',
                            label: 'Enter your email',
                            icon: Icons.email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email is empty';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          _field(
                            controller: _newPasswordController,
                            focusNode: _newPasswordFocusNode,
                            hint: 'Enter password',
                            label: 'Password',
                            icon: Icons.lock_rounded,
                            obscure: true,
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is empty';
                              }
                              if (value.length < 6) {
                                return 'Minimum 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          _field(
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordFocusNode,
                            hint: '*******',
                            label: 'Confirm Password',
                            icon: Icons.lock_rounded,
                            obscure: true,
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Confirm password is empty';
                              }
                              if (value != _newPasswordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          _field(
                            controller: _fnameController,
                            focusNode: _fnameFocusNode,
                            hint: 'Enter first name',
                            label: 'First Name',
                            icon: Icons.person_rounded,
                            keyboardType: TextInputType.name,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'First name is empty';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          _field(
                            controller: _lnameController,
                            focusNode: _lnameFocusNode,
                            hint: 'Enter last name',
                            label: 'Last Name',
                            icon: Icons.person_rounded,
                            keyboardType: TextInputType.name,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Last name is empty';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Login(),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Sign Up'),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Login(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Login',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        decoration: TextDecoration.underline,
                                      ),
                                ),
                              ),
                            ],
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

  /// Reusable text field widget
  Widget _field({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    // Optional visual tweak when focused
    final isFocused = focusNode.hasFocus;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isFocused ? 0.10 : 0.06),
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
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }
}
