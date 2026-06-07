import 'package:flutter/material.dart';
import 'package:smart_flat/core/widgets/app_background.dart';
import 'package:smart_flat/features/auth/sign_up/widgets/sign_up_form.dart';

class SignUpScreen extends StatelessWidget {
  final VoidCallback onShowSignIn;
  const SignUpScreen({super.key, required this.onShowSignIn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SignUpForm(onShowSignIn: onShowSignIn),
          ),
        ),
      ),
    );
  }
}
