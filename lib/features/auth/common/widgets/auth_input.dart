import 'package:flutter/material.dart';

class AuthInput extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String label;
  final bool obscure;
  final String? Function(String?)? validator;

  const AuthInput({
    super.key,
    required this.controller,
    required this.icon,
    required this.label,
    required this.obscure,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: cs.primary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
