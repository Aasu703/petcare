import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/features/pet/presentation/pages/add_pet.dart';
import 'package:petcare/features/pet/presentation/providers/pet_providers.dart';

class PetListScreen extends ConsumerStatefulWidget {
  const PetListScreen({super.key});

  @override
  ConsumerState<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends ConsumerState<PetListScreen> {
  @override
  void initState() {
    super.initState();
    // Load pets when screen initializes
    Future.microtask(() {
      // TODO: Get token from your auth provider
      const token = 'YOUR_AUTH_TOKEN_HERE';
      ref.read(petNotifierProvider.notifier).loadPets(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final petState = ref.watch(petNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pets'),
        backgroundColor: AppColors.iconSecondaryColor,
      ),
      body: petState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : petState.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${petState.error}'),
                  ElevatedButton(
                    onPressed: () {
                      const token = 'YOUR_AUTH_TOKEN_HERE';
                      ref.read(petNotifierProvider.notifier).loadPets(token);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : petState.pets.isEmpty
          ? const Center(child: Text('No pets added yet. Tap + to add a pet!'))
          : ListView.builder(
              itemCount: petState.pets.length,
              itemBuilder: (context, index) {
                final pet = petState.pets[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: pet.imagePath != null
                          ? NetworkImage('http://10.0.2.2:5050${pet.imagePath}')
                          : null,
                      child: pet.imagePath == null
                          ? const Icon(Icons.pets)
                          : null,
                    ),
                    title: Text(pet.name),
                    subtitle: Text(
                      '${pet.species.toUpperCase()} ${pet.breed.isNotEmpty ? "• ${pet.breed}" : ""}',
                    ),
                    trailing: Text('${pet.age} yrs, ${pet.weight} kg'),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPet()),
          );
        },
        backgroundColor: AppColors.iconSecondaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
