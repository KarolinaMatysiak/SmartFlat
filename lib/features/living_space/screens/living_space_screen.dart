import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_flat/core/screens/loading_screen.dart';
import 'package:smart_flat/core/widgets/app_background.dart';
import 'package:smart_flat/features/auth/providers/auth_provider.dart';
import 'package:smart_flat/features/living_space/providers/living_space_provider.dart';

class LivingSpaceScreen extends StatelessWidget {
  const LivingSpaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spaceProvider = context.watch<LivingSpaceProvider>();
    final authProvider = context.watch<AuthProvider>();
    if (spaceProvider.isLoading || authProvider.isLoading) {
      return const LoadingScreen();
    }

    final firstSpaceDoc = spaceProvider.spacesSnapshot!.docs.first;
    final firstSpaceData = firstSpaceDoc.data();
    final spaceName = firstSpaceData['name'];

    return Scaffold(
      appBar: AppBar(
        title: Text(spaceName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().signOut();
            },
          ),
        ],
      ),
      body: const AppBackground(
        child: Center(
          child: Text(
            "Witaj w domu!",
            style: TextStyle(fontSize: 24, color: Colors.black),
          ),
        ),
      ),
    );
  }
}