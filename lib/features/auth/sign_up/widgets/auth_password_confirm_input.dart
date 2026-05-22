import 'package:flutter/material.dart';
import 'package:smart_flat/core/widgets/form_input.dart';

class AuthPasswordConfirmInput extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmationController;

  const AuthPasswordConfirmInput({
    super.key,
    required this.passwordController,
    required this.passwordConfirmationController,
  });

  @override
  Widget build(BuildContext context) {
    return FormInput(
      controller: passwordConfirmationController,
      icon: Icons.lock_outline,
      label: "Confirm Password",
      obscure: true,
      validator: (value) {
        final confirm = value?.trim() ?? '';

        if (confirm.isEmpty) {
          return "Password confirm is required";
        }

        if (confirm != passwordController.text.trim()) {
          return "Passwords do not match";
        }

        return null;
      },
    );
  }
}
