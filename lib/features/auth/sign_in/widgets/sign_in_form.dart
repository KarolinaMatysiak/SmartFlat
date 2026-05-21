import 'package:flutter/material.dart';
import 'package:smart_flat/features/auth/common/widgets/auth_input.dart';
import 'package:smart_flat/features/auth/sign_in/services/auth_service.dart';
import 'package:smart_flat/features/auth/sign_in/widgets/sign_in_button.dart';
import 'package:smart_flat/features/auth/sign_in/widgets/sign_in_logo.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInForm();
}

class _SignInForm extends State<SignInForm> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  Future<void> login() async {
    setState(() => loading = true);

    try {
      await AuthService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      color: Colors.white.withOpacity(0.75),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SignInLogo(),
            const SizedBox(height: 20),

            Text(
              "Sign In",
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 6),

            Text(
              "Enter Smart Flat World",
              style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
            ),

            const SizedBox(height: 24),

            AuthInput(
              controller: emailController,
              icon: Icons.email_outlined,
              label: "Email",
              obscure: false,
            ),

            const SizedBox(height: 14),

            AuthInput(
              controller: passwordController,
              icon: Icons.lock_outline,
              label: "Password",
              obscure: true,
            ),

            const SizedBox(height: 22),

            SignInButton(loading: loading, onPressed: login),
          ],
        ),
      ),
    );
  }
}
