import 'package:flutter/material.dart';
import 'package:petcare/Screens/Dashboard.dart';
import 'dart:ui';

import 'package:petcare/Screens/login.dart';

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

  double blurValue = 0;

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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // EMAIL FIELD
                      Container(
                        decoration: _boxShadow(),
                        child: TextFormField(
                          controller: _newEmailController,
                          focusNode: _newEmailFocusNode,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "example12@email.com",
                            labelText: "Enter your email",
                            prefixIcon: Icon(
                              Icons.email_rounded,
                              color: Colors.black,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email is empty";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 28),

                      // PASSWORD FIELD
                      Container(
                        decoration: _boxShadow(),
                        child: TextFormField(
                          controller: _newPasswordController,
                          focusNode: _newPasswordFocusNode,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "Enter password",
                            labelText: "Password",
                            prefixIcon: Icon(
                              Icons.lock_rounded,
                              color: Colors.black,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Password is empty";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 28),

                      // CONFIRM PASSWORD
                      Container(
                        decoration: _boxShadow(),
                        child: TextFormField(
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocusNode,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "*******",
                            labelText: "Confirm Password",
                            prefixIcon: Icon(
                              Icons.lock_rounded,
                              color: Colors.black,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Confirm password is empty";
                            }
                            if (value != _newPasswordController.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 28),

                      // FIRST NAME
                      Container(
                        decoration: _boxShadow(),
                        child: TextFormField(
                          controller: _fnameController,
                          focusNode: _fnameFocusNode,
                          decoration: InputDecoration(
                            hintText: "Enter first name",
                            labelText: "First Name",
                            prefixIcon: Icon(
                              Icons.person_rounded,
                              color: Colors.black,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "First name is empty";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 28),

                      // LAST NAME
                      Container(
                        decoration: _boxShadow(),
                        child: TextFormField(
                          controller: _lnameController,
                          focusNode: _lnameFocusNode,
                          decoration: InputDecoration(
                            hintText: "Enter last name",
                            labelText: "Last Name",
                            prefixIcon: Icon(
                              Icons.person_rounded,
                              color: Colors.black,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Last name is empty";
                            }
                            return null;
                          },
                        ),
                      ),

                      SizedBox(height: 28),

                      // SIGN UP BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 50,
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
          ),
        ],
      ),
    );
  }

  BoxDecoration _boxShadow() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(color: Colors.black, blurRadius: 12, offset: Offset(0, 6)),
      ],
    );
  }
}
