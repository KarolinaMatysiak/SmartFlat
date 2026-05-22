import 'package:flutter/material.dart';
import 'package:smart_flat/core/widgets/app_background.dart';
import 'package:smart_flat/features/auth/common/services/auth_service.dart';
import 'package:smart_flat/features/home/screens/home_screen.dart';
import 'package:smart_flat/features/onboarding/widgets/user_profile_onboarding_form.dart';
import 'package:smart_flat/features/user_profile/services/user_profile_service.dart';

class UserProfileOnboardingScreen extends StatelessWidget {
  const UserProfileOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.getCurrentUser();

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return FutureBuilder(
      future: UserProfileService().getUserProfile(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userProfile = snapshot.data;
        if (userProfile == null || !userProfile.exists) {
          return Scaffold(
            body: AppBackground(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 420),
                  child: UserProfileOnboardingForm(identityId: user.uid),
                ),
              ),
            ),
          );
        }

        return HomeScreen();
      },
    );
  }
}
