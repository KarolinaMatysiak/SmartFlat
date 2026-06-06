import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_flat/core/screens/loading_screen.dart';
import 'package:smart_flat/core/widgets/app_background.dart';
import 'package:smart_flat/features/auth/providers/auth_provider.dart';
import 'package:smart_flat/features/user_profile/widgets/user_profile_onboarding_form.dart';

class UserProfileOnboardingScreen extends StatelessWidget {
  const UserProfileOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    if (authProvider.isLoading) {
      return const LoadingScreen();
    }

    final userId = authProvider.currentUser!.uid;
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: UserProfileOnboardingForm(identityId: userId),
          ),
        ),
      ),
    );
  }
}