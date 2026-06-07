import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_flat/features/auth/providers/auth_provider.dart';
import 'package:smart_flat/features/auth/sign_in/screens/sign_in_screen.dart';
import 'package:smart_flat/features/auth/sign_up/screens/sign_up_screen.dart';
import 'package:smart_flat/features/living_space/providers/living_space_provider.dart';
import 'package:smart_flat/features/living_space/screens/living_space_screen.dart';
import 'package:smart_flat/features/living_space/screens/living_space_onboarding_screen.dart';
import 'package:smart_flat/features/user_profile/providers/user_profile_provider.dart';
import 'package:smart_flat/features/user_profile/screens/user_profile_onboarding_screen.dart';
import 'package:smart_flat/core/screens/loading_screen.dart';

class AppRouter {
  static GoRouter createRouter(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final userProfileProvider = context.read<UserProfileProvider>();
    final spaceProvider = context.read<LivingSpaceProvider>();

    return GoRouter(
      initialLocation: '/',
      refreshListenable: Listenable.merge([
        authProvider,
        userProfileProvider,
        spaceProvider,
      ]),
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/login';
        final isRegistering = state.matchedLocation == '/register';

        if (!isAuthenticated) {
          if (isLoggingIn || isRegistering) return null;
          return '/login';
        }

        if (isLoggingIn || isRegistering) {
          return '/';
        }

        if (userProfileProvider.isLoading || spaceProvider.isLoading) {
          return null;
        }

        if (!userProfileProvider.hasProfile) {
          if (state.matchedLocation != '/onboarding/profile') {
            return '/onboarding/profile';
          }
          return null;
        }

        if (!spaceProvider.hasSpaces) {
          if (state.matchedLocation != '/onboarding/space') {
            return '/onboarding/space';
          }
          return null;
        }

        if (state.matchedLocation.startsWith('/onboarding')) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) =>
              SignInScreen(onShowSignUp: () => context.go('/register')),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) =>
              SignUpScreen(onShowSignIn: () => context.go('/login')),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) {
            final up = context.watch<UserProfileProvider>();
            final sp = context.watch<LivingSpaceProvider>();

            if (up.isLoading || sp.isLoading) {
              return const LoadingScreen();
            }
            return const LivingSpaceScreen();
          },
        ),
        GoRoute(
          path: '/onboarding/profile',
          builder: (context, state) => const UserProfileOnboardingScreen(),
        ),
        GoRoute(
          path: '/onboarding/space',
          builder: (context, state) => const LivingSpaceSetupScreen(),
        ),
      ],
    );
  }
}
