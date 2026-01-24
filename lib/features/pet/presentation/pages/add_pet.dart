import 'package:flutter/material.dart';
import 'package:petcare/app/theme/app_colors.dart';

class AddPet extends StatelessWidget {
  const AddPet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.iconSecondaryColor,
        title: Text(
          'Add Pet',
          style: TextStyle(color: AppColors.textPrimaryColor),
        ),
      ),
      body: Container(
        color: AppColors.iconPrimaryColor,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pet Photo Picker (UI only)
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.iconSecondaryColor,
                      child: Icon(
                        Icons.pets,
                        size: 60,
                        color: AppColors.iconPrimaryColor,
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: AppColors.iconPrimaryColor,
                        child: Icon(
                          Icons.camera_alt,
                          color: AppColors.iconSecondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Pet Name Field
              TextField(
                decoration: InputDecoration(
                  labelText: 'Pet Name',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              // Gender Selection
              Text(
                'Gender',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(
                        Icons.male,
                        color: AppColors.iconSecondaryColor,
                      ),
                      label: const Text('Male'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: AppColors.iconSecondaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(
                        Icons.female,
                        color: AppColors.iconSecondaryColor,
                      ),
                      label: const Text('Female'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: AppColors.iconSecondaryColor),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Add Pet Button
              ElevatedButton(
                onPressed: () {},
                child: const Text('Add Pet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.iconSecondaryColor,
                  foregroundColor: AppColors.textPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
