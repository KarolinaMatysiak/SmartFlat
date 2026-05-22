import 'package:flutter/material.dart';
import 'package:smart_flat/core/widgets/form_input.dart';
import 'package:smart_flat/core/widgets/form_submit_button.dart';
import 'package:smart_flat/features/common/actions/show_error_snack_bar.dart';
import 'package:smart_flat/features/home/screens/home_screen.dart';
import 'package:smart_flat/features/user_profile/services/user_profile_service.dart';

class UserProfileOnboardingForm extends StatefulWidget {
  final String identityId;

  const UserProfileOnboardingForm({super.key, required this.identityId});

  @override
  State<UserProfileOnboardingForm> createState() =>
      _UserProfileOnboardingForm();
}

class _UserProfileOnboardingForm extends State<UserProfileOnboardingForm> {
  final _formKey = GlobalKey<FormState>();

  final firstName = TextEditingController();
  final userName = TextEditingController();

  bool loading = false;

  Future<void> createUserProfile() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    setState(() => loading = true);

    try {
      await UserProfileService().createUserProfile(
        identityId: widget.identityId,
        firstName: firstName.text.trim(),
        userName: userName.text.trim(),
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      print(e);

      showErrorSnackBar(context, "User profile creation error");
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    firstName.dispose();
    userName.dispose();
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
              Text(
                "Welcome to the Smart Flat!",
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 6),

              Text(
                "Share your user's data to find a match with your friends",
                style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
              ),

              const SizedBox(height: 24),

              FormInput(
                controller: firstName,
                icon: Icons.account_box,
                label: "First Name",
                validator: (value) {
                  final firstName = value?.trim() ?? '';

                  if (firstName.isEmpty) {
                    return "First name is required";
                  }

                  if (firstName.length < 3) {
                    return "First name must be at least 3 characters ";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              FormInput(
                controller: userName,
                icon: Icons.abc,
                label: "User Name",
                validator: (value) {
                  final userName = value?.trim() ?? '';

                  if (userName.isEmpty) {
                    return "User name is required";
                  }

                  if (userName.length < 3) {
                    return "User name must be at least 3 characters ";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 22),

              FormSubmitButton(loading: loading, onPressed: createUserProfile),
            ],
          ),
        ),
      ),
    );
  }
}
