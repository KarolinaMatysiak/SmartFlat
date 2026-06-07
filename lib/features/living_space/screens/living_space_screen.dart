import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_flat/core/screens/loading_screen.dart';
import 'package:smart_flat/core/widgets/app_background.dart';
import 'package:smart_flat/features/auth/providers/auth_provider.dart';
import 'package:smart_flat/features/living_space/providers/living_space_provider.dart';
import 'package:smart_flat/features/task/widgets/tasks_overview_widget.dart';

class LivingSpaceScreen extends StatelessWidget {
  const LivingSpaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spaceProvider = context.watch<LivingSpaceProvider>();
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isAuthenticated || spaceProvider.spacesSnapshot == null || spaceProvider.isLoading) {
      return const LoadingScreen();
    }

    if (!spaceProvider.hasSpaces) {
      return const LoadingScreen();
    }

    final firstSpaceDoc = spaceProvider.spacesSnapshot!.docs.first;
    final firstSpaceData = firstSpaceDoc.data();
    final spaceName = firstSpaceData['name'] ?? 'Mój Smart Flat';

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(spaceName, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                TasksOverviewWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
