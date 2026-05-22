import 'package:flutter/material.dart';
import 'package:smart_flat/core/widgets/form_input.dart';

class AuthPasswordInput extends StatelessWidget {
  final TextEditingController controller;

  const AuthPasswordInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return FormInput(
      controller: controller,
      icon: Icons.lock_outline,
      label: "Password",
      obscure: true,
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
