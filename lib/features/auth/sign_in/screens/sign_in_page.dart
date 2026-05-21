import 'package:flutter/material.dart';
import 'package:smart_flat/features/auth/common/widgets/auth_background.dart';
import 'package:smart_flat/features/auth/sign_in/widgets/sign_in_form.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
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
