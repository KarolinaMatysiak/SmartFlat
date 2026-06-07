import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_flat/core/screens/loading_screen.dart';
import 'package:smart_flat/core/widgets/app_background.dart';
import 'package:smart_flat/features/auth/providers/auth_provider.dart';
import 'package:smart_flat/features/living_space/providers/living_space_provider.dart';
import 'package:smart_flat/features/task/widgets/tasks_overview_widget.dart';
import 'package:smart_flat/features/living_space/widgets/living_space_members_tab.dart';

class LivingSpaceScreen extends StatefulWidget {
  const LivingSpaceScreen({super.key});

  @override
  State<LivingSpaceScreen> createState() => _LivingSpaceScreenState();
}

class _LivingSpaceScreenState extends State<LivingSpaceScreen> {
  int _selectedIndex = 0;

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
    final spaceId = firstSpaceDoc.id;

    final List<Widget> _tabs = [
      const _HomeTab(),
      LivingSpaceMembersTab(
        spaceId: spaceId,
        memberIds: List<String>.from(firstSpaceData['memberIds'] ?? []),
      ),
    ];

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
          child: _tabs[_selectedIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Members',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: const [
          TasksOverviewWidget(),
        ],
      ),
    );
  }
}
