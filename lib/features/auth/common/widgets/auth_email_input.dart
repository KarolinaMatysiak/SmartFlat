import 'package:flutter/material.dart';
import 'package:smart_flat/core/widgets/form_input.dart';

class AuthEmailInput extends StatelessWidget {
  final TextEditingController controller;

  const AuthEmailInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return FormInput(
      controller: controller,
      icon: Icons.email_outlined,
      label: "Email",
      obscure: false,
      validator: (value) {
        final email = value?.trim() ?? '';

        if (email.isEmpty) {
          return "Email is required";
        }

        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

        if (!emailRegex.hasMatch(email)) {
          return "Enter a valid email";
        }

        return null;
      },
    );
  }
}
