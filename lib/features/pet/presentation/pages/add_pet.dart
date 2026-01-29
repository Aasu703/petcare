import 'package:flutter/material.dart';
import 'package:petcare/app/theme/app_colors.dart';

class AddPet extends StatelessWidget {
  const AddPet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Pet')),
      backgroundColor: AppColors.iconPrimaryColor,
      body: container(),
    );
  }
}

class container extends StatelessWidget {
  const container({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Add Pet Page Content Here'));
  }
}
