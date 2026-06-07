import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_flat/features/auth/common/widgets/auth_form_logo.dart';
import 'package:smart_flat/features/auth/common/widgets/auth_email_input.dart';
import 'package:smart_flat/features/auth/common/widgets/auth_password_input.dart';
import 'package:smart_flat/features/auth/providers/auth_provider.dart';
import 'package:smart_flat/features/auth/sign_in/screens/sign_in_screen.dart';
import 'package:smart_flat/core/widgets/form_submit_button.dart';
import 'package:smart_flat/features/auth/sign_up/widgets/auth_password_confirm_input.dart';
import 'package:smart_flat/features/common/actions/show_error_snack_bar.dart';

class SignUpForm extends StatefulWidget {
  final VoidCallback onShowSignIn;
  const SignUpForm({super.key, required this.onShowSignIn});

  @override
  State<SignUpForm> createState() => _SignUpForm();
}

class _SignUpForm extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();

  bool loading = false;

  Future<void> signUp() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    setState(() => loading = true);

    try {
      await context.read<AuthProvider>().signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      showErrorSnackBar(context, "Cannot create user");
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
    passwordConfirmationController.dispose();
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
              const AuthFormLogo(icon: Icons.account_circle),
              const SizedBox(height: 20),

              Text("Sign Up", style: Theme.of(context).textTheme.headlineSmall),

              const SizedBox(height: 6),

              Text(
                "Enter Smart Flat World",
                style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
              ),

              const SizedBox(height: 24),

              AuthEmailInput(controller: emailController),

              const SizedBox(height: 14),

              AuthPasswordInput(controller: passwordController),

              const SizedBox(height: 14),

              AuthPasswordConfirmInput(
                passwordController: passwordController,
                passwordConfirmationController: passwordConfirmationController,
              ),

              const SizedBox(height: 22),

              FormSubmitButton(loading: loading, onPressed: signUp),

              const SizedBox(height: 22),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: widget.onShowSignIn,
                    child: const Text("Sign In"),
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
