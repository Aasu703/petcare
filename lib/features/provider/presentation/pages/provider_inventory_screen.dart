import 'package:flutter/material.dart';
import 'package:petcare/features/shop/presentation/pages/manage_inventory_page.dart';

class ProviderInventoryScreen extends StatelessWidget {
  const ProviderInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Reuse the shop inventory management page for providers so they can
    // manage their own products tied to their provider account.
    return const ManageInventoryPage();
  }
}
