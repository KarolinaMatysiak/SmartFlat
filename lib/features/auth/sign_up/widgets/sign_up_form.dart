import 'package:flutter/material.dart';
import 'package:smart_flat/features/auth/common/widgets/auth_form_logo.dart';
import 'package:smart_flat/features/auth/common/widgets/auth_input.dart';
import 'package:smart_flat/features/auth/common/services/auth_service.dart';
import 'package:smart_flat/features/auth/sign_in/screens/sign_in_screen.dart';
import 'package:smart_flat/features/auth/sign_in/widgets/sign_in_button.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpForm();
}

class _SignUpForm extends State<SignUpForm> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  Future<void> login() async {
    setState(() => loading = true);

    try {
      await AuthService.signIn(
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
            const AuthFormLogo(icon: Icons.account_circle),
            const SizedBox(height: 20),

            Text("Sign Up", style: Theme.of(context).textTheme.headlineSmall),

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

            const SizedBox(height: 14),

            AuthInput(
              controller: passwordController,
              icon: Icons.lock_outline,
              label: "Password Confirmation",
              obscure: true,
            ),

            const SizedBox(height: 22),

            SignInButton(loading: loading, onPressed: login),

            const SizedBox(height: 22),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignInScreen(),
                      ),
                    );
                  },
                  child: Text("Sign In"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
