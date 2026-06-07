import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_flat/features/auth/common/widgets/auth_form_logo.dart';
import 'package:smart_flat/features/auth/common/widgets/auth_email_input.dart';
import 'package:smart_flat/features/auth/common/widgets/auth_password_input.dart';
import 'package:smart_flat/core/widgets/form_submit_button.dart';
import 'package:smart_flat/features/auth/providers/auth_provider.dart';
import 'package:smart_flat/features/auth/sign_up/screens/sign_up_screen.dart';
import 'package:smart_flat/features/common/actions/show_error_snack_bar.dart';

class SignInForm extends StatefulWidget {
  final VoidCallback onShowSignUp;
  const SignInForm({super.key, required this.onShowSignUp});

  @override
  State<SignInForm> createState() => _SignInForm();
}

class _SignInForm extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  Future<void> signIn() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    setState(() => loading = true);

    try {
      await context.read<AuthProvider>().signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      showErrorSnackBar(context, "Invalid credentials");
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AuthFormLogo(icon: Icons.lock),
              const SizedBox(height: 20),

              Text("Sign In", style: Theme.of(context).textTheme.headlineSmall),

              const SizedBox(height: 6),

              Text(
                "Enter Smart Flat World",
                style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
              ),

              const SizedBox(height: 24),

              AuthEmailInput(controller: emailController),

              const SizedBox(height: 14),

              AuthPasswordInput(controller: passwordController),

              const SizedBox(height: 22),

              FormSubmitButton(loading: loading, onPressed: signIn),

              const SizedBox(height: 22),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: widget.onShowSignUp,
                    child: const Text("Sign Up"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
