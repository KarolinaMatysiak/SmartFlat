import 'package:flutter/material.dart';
import 'package:smart_flat/features/auth/common/widgets/auth_background.dart';
import 'package:smart_flat/features/auth/sign_up/widgets/sign_up_form.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 420),
            child: SignUpForm(),
          ),
        ),
      ),
    );
  }
}
