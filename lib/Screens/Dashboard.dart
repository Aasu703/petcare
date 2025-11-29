import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        title: Text(
          "PawCare",
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                height: 500,
                width: 500,
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: Image.asset('assets/images/logo.png'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
