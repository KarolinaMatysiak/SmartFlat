import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smart_flat/core/screens/loading_screen.dart';
import 'package:smart_flat/core/widgets/app_background.dart';
import 'package:smart_flat/features/auth/providers/auth_provider.dart';
import 'package:smart_flat/features/budget/providers/budget_provider.dart';
import 'package:smart_flat/features/living_space/providers/living_space_provider.dart';
import 'package:smart_flat/features/shopping_item/screens/shopping_item_list_screen.dart';
import 'package:smart_flat/features/budget/widgets/budget_overview_widget.dart';
import 'package:smart_flat/features/shopping_item/widgets/shopping_overview_widget.dart';
import 'package:smart_flat/features/task/widgets/tasks_overview_widget.dart';
import 'package:smart_flat/features/living_space/widgets/living_space_members_tab.dart';
import 'package:smart_flat/features/motivation/widgets/motivator_pet.dart';

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
    final budgetProvider = context.watch<BudgetProvider>();

    if (!authProvider.isAuthenticated || spaceProvider.spacesSnapshot == null || spaceProvider.isLoading) {
      return const LoadingScreen();
    }

    if (!spaceProvider.hasSpaces) {
      return const LoadingScreen();
    }

    final firstSpaceDoc = spaceProvider.spacesSnapshot!.docs.first;
    final firstSpaceData = firstSpaceDoc.data();
    final spaceName = firstSpaceData['name'] ?? 'My Smart Flat';
    final spaceId = firstSpaceDoc.id;

    // Initialize budget provider for this space
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<BudgetProvider>().setCurrentSpaceId(spaceId);
      }
    });

    final List<Widget> _tabs = [
      const _HomeTab(),
      LivingSpaceMembersTab(
        spaceId: spaceId,
        memberIds: List<String>.from(firstSpaceData['memberIds'] ?? []),
      ),
    ];

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        extendBody: true,
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
        body: SafeArea(
          bottom: false, // Background flows under navigation bar
          child: _tabs[_selectedIndex],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline_rounded),
                activeIcon: Icon(Icons.people_rounded),
                label: 'Members',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MotivatorPet(),
          const BudgetOverviewWidget(),
          const SizedBox(height: 16),
          const TasksOverviewWidget(),
          const SizedBox(height: 16),
          const ShoppingOverviewWidget(),
        ],
      ),
    );
  }
}
