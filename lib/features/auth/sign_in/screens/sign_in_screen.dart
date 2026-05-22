import 'package:flutter/material.dart';
import 'package:smart_flat/core/widgets/app_background.dart';
import 'package:smart_flat/features/auth/sign_in/widgets/sign_in_form.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 420),
            child: SignInForm(),
          ),
        ),
      ),
    );
  }
}
