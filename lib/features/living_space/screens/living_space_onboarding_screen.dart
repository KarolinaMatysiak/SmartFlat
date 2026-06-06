import 'package:flutter/material.dart';
import 'package:smart_flat/core/screens/loading_screen.dart';
import 'package:smart_flat/core/widgets/app_background.dart';
import 'package:smart_flat/features/auth/providers/auth_provider.dart';
import 'package:smart_flat/features/living_space/providers/living_space_provider.dart';
import 'package:smart_flat/features/living_space/screens/living_space_screen.dart';
import 'package:smart_flat/features/living_space/widgets/living_space_onboarding_form.dart';
import 'package:provider/provider.dart';

class LivingSpaceSetupScreen extends StatelessWidget {
  const LivingSpaceSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final spaceProvider = context.watch<LivingSpaceProvider>();
    if (spaceProvider.isLoading || authProvider.isLoading) {
      return const LoadingScreen();
    }

    if (!spaceProvider.hasSpaces) {
      return Scaffold(
        body: AppBackground(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: LivingSpaceOnboardingForm(
                identityId: authProvider.currentUser!.uid,
              ),
            ),
          ),
        ),
      );
    }

    return LivingSpaceScreen();
  }
}
