import 'package:flutter/material.dart';
import 'package:petcare/Screens/Dashboard.dart';
import 'package:petcare/Screens/signup.dart';
import 'package:petcare/widget/mytextformfield.dart';
import 'package:petcare/theme/app_colors.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _tryLogin() {
    // Trigger field validators
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      // Show a friendly message and stop navigation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors above.')),
      );
      return;
    }

    // If valid, proceed to dashboard
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Dashboard()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: 140,
              child: Opacity(
                opacity: 0.12,
                child: Icon(Icons.pets, size: 180, color: AppColors.accentColor),
              ),
            ),
            Positioned(
              left: -30,
              bottom: 160,
              child: Opacity(
                opacity: 0.12,
                child: Icon(Icons.pets, size: 220, color: AppColors.accentColor),
              ),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Log in to your account',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: MyTextformfield(
                              controller: _emailController,
                              hintText: "example@gmail.com",
                              labelText: "Email",
                              errorMessage: "Incorrect email",
                              prefixIcon: Icon(
                                Icons.email_rounded,
                                color: AppColors.iconPrimaryColor,
                              ),
                              focusNode: _emailFocusNode,
                              filled: true,
                              fillcolor: AppColors.surfaceColor,
                            ),
                          ),

                          const SizedBox(height: 18),

                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: MyTextformfield(
                              controller: _passwordController,
                              hintText: "*********",
                              labelText: "Enter Your Password",
                              errorMessage: "Incorrect Password",
                              prefixIcon: Icon(
                                Icons.lock_rounded,
                                color: AppColors.iconPrimaryColor,
                              ),
                              focusNode: _passwordFocusNode,
                              filled: true,
                              fillcolor: AppColors.surfaceColor,
                              obscureText: true,
                            ),
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _tryLogin,
                              child: const Text('Login'),
                            ),
                          ),

                          const SizedBox(height: 18),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Signup(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sign Up',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
}
