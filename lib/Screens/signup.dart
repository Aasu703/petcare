import 'package:flutter/material.dart';
import 'package:petcare/Screens/Dashboard.dart';
import 'dart:ui';

import 'package:petcare/widget/mytextformfield.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _newEmailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();

  final FocusNode _newEmailFocusNode = FocusNode();
  final FocusNode _newPasswordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final FocusNode _fnameFocusNode = FocusNode();
  final FocusNode _lnameFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  double blurValue = 0; // default blur

  @override
  void initState() {
    super.initState();
    _newEmailFocusNode.addListener(_onFocusChanged);
    _newPasswordFocusNode.addListener(_onFocusChanged);
    _confirmPasswordFocusNode.addListener(_onFocusChanged);
    _fnameFocusNode.addListener(_onFocusChanged);
    _lnameFocusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    setState(() {
      blurValue =
          (_newEmailFocusNode.hasFocus ||
              _newPasswordFocusNode.hasFocus ||
              _confirmPasswordFocusNode.hasFocus ||
              _fnameFocusNode.hasFocus ||
              _lnameFocusNode.hasFocus)
          ? 5.0
          : 0.0;
    });
  }

  @override
  void dispose() {
    _newEmailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _fnameController.dispose();
    _lnameController.dispose();
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Transform.scale(
              scale: 1.3,
              child: Image.asset('assets/images/cat.jpg', fit: BoxFit.cover),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
              child: Container(),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),

                      child: MyTextformfield(
                        controller: _newEmailController,
                        hintText: "example12@email.com",
                        labelText: "Enter your email",
                        errorMessage: "email is empty",
                        prefixIcon: Icon(
                          Icons.email_rounded,
                          color: Colors.black,
                        ),
                        focusNode: _newEmailFocusNode,
                        filled: true,
                        fillcolor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 28),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: MyTextformfield(
                        controller: _newPasswordController,
                        hintText: "Enter password",
                        labelText: "Password",
                        errorMessage: "password is empty",
                        prefixIcon: Icon(
                          Icons.lock_rounded,
                          color: Colors.black,
                        ),
                        focusNode: _newPasswordFocusNode,
                        filled: true,
                        fillcolor: Colors.white,
                        obscureText: true,
                      ),
                    ),
                    SizedBox(height: 28),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: MyTextformfield(
                        controller: _confirmPasswordController,
                        hintText: "*******",
                        labelText: "Confirm Password",
                        errorMessage: "Password Doesn't match",
                        prefixIcon: Icon(
                          Icons.lock_rounded,
                          color: Colors.black,
                        ),
                        focusNode: _confirmPasswordFocusNode,
                        filled: true,
                        fillcolor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 28),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: MyTextformfield(
                        controller: _fnameController,
                        hintText: "Enter first name",
                        labelText: "First Name",
                        errorMessage: "first name is empty",
                        prefixIcon: Icon(
                          Icons.person_rounded,
                          color: Colors.black,
                        ),
                        focusNode: _fnameFocusNode,
                        filled: true,
                        fillcolor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 28),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: MyTextformfield(
                        controller: _lnameController,
                        hintText: "Enter last name",
                        labelText: "Last Name",
                        errorMessage: "last name is empty",
                        prefixIcon: Icon(
                          Icons.person_rounded,
                          color: Colors.black,
                        ),
                        focusNode: _lnameFocusNode,
                        filled: true,
                        fillcolor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Dashboard(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
