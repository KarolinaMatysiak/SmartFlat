import 'package:flutter/material.dart';
import 'package:smart_flat/features/auth/common/widgets/auth_input.dart';

class AuthInputPassword extends StatelessWidget {
  final TextEditingController controller;
  final String? label;

  const AuthInputPassword({super.key, required this.controller, this.label});

  @override
  Widget build(BuildContext context) {
    return AuthInput(
      controller: controller,
      icon: Icons.lock_outline,
      label: label ?? "Password",
      obscure: false,
      validator: (value) {
        final password = value?.trim() ?? '';

        if (password.isEmpty) {
          return "Password is required";
        }

        if (password.length < 6) {
          return "Password must be at least 6 characters";
        }

        return null;
      },
    );
  }
}
