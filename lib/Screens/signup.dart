import 'package:flutter/material.dart';
import 'package:petcare/Screens/login.dart';
import 'package:petcare/widget/mytextformfield.dart';
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

  // Colors
  static const Color _bgColor = Color(0xFFFFF5EC);
  static const Color _accentColor = Color(0xFFFFA84C);

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
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative background icons
            Positioned(
              right: -40,
              top: 140,
              child: Opacity(
                opacity: 0.12,
                child: Icon(Icons.pets, size: 180, color: _accentColor),
              ),
            ),
            Positioned(
              left: -30,
              bottom: 160,
              child: Opacity(
                opacity: 0.12,
                child: Icon(Icons.pets, size: 220, color: _accentColor),
              ),
            ),

            // Content
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Join our pet-loving community',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 28),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                              // // Optional: add a stronger email format check
                              // final emailRegex = RegExp(
                              //   r'^[^@]+@[^@]+\.[^@]+$',
                              // );
                              // if (!emailRegex.hasMatch(value)) {
                              //   return 'Enter a valid email address';
                              // }
                              // return null;
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
                                  // TODO: Insert your signup logic (API/Firebase) here.
                                  // On success, navigate to Login (or Dashboard).
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Login(),
                                    ),
                                  );
                                  // Or:
                                  // Navigator.pushReplacement(
                                  //   context,
                                  //   MaterialPageRoute(builder: (_) => const Dashboard()),
                                  // );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accentColor,
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontFamily: 'Nunito',
                                ),
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
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black,
                                    decoration: TextDecoration.underline,
                                    fontFamily: 'Nunito',
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
        prefixIcon: Icon(icon, color: Colors.black),
        filled: true,
        fillcolor: Colors.white,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }
}
