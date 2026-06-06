import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_flat/core/screens/loading_screen.dart';
import 'package:smart_flat/core/widgets/app_background.dart';
import 'package:smart_flat/features/auth/providers/auth_provider.dart';
import 'package:smart_flat/features/living_space/providers/living_space_provider.dart';
import 'package:smart_flat/features/living_space/screens/living_space_screen.dart';
import 'package:smart_flat/features/living_space/widgets/living_space_onboarding_form.dart';
import 'package:smart_flat/features/user_profile/screens/user_profile_onboarding_screen.dart';
import 'package:smart_flat/features/user_profile/providers/user_profile_provider.dart';

class InitialFlowRouter extends StatelessWidget {
  const InitialFlowRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final spaceProvider = context.watch<LivingSpaceProvider>();
    final userProfileProvider = context.watch<UserProfileProvider>();
    final authProvider = context.watch<AuthProvider>();

    if (spaceProvider.isLoading ||
        userProfileProvider.isLoading ||
        authProvider.isLoading) {
      return const LoadingScreen();
    }

    if (!userProfileProvider.hasProfile) {
      return const UserProfileOnboardingScreen();
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

    return const LivingSpaceScreen();
  }
}
