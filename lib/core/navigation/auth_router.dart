import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_flat/core/screens/loading_screen.dart';
import 'package:smart_flat/core/navigation/initial_flow_router.dart';
import 'package:smart_flat/features/auth/providers/auth_provider.dart';
import 'package:smart_flat/features/auth/sign_in/screens/sign_in_screen.dart';
import 'package:smart_flat/features/living_space/providers/living_space_provider.dart';
import 'package:smart_flat/features/task/providers/task_provider.dart';
import 'package:smart_flat/features/user_profile/providers/user_profile_provider.dart';

class AuthRouter extends StatelessWidget {
  const AuthRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    if (authProvider.isLoading) {
      return const LoadingScreen();
    }

    if (authProvider.isAuthenticated) {
      final uid = authProvider.currentUser!.uid;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<UserProfileProvider>().init(uid);
        context.read<LivingSpaceProvider>().init(uid);
      });

      return const InitialFlowRouter();
    }

    return SignInScreen();
  }
}