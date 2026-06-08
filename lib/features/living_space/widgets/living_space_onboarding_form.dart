import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_flat/core/widgets/form_input.dart';
import 'package:smart_flat/core/widgets/form_submit_button.dart';
import 'package:smart_flat/features/common/actions/show_error_snack_bar.dart';
import 'package:smart_flat/features/living_space/providers/living_space_provider.dart';
import 'package:smart_flat/features/living_space/screens/living_space_screen.dart';
import 'package:smart_flat/features/living_space/services/living_space_invitation_service.dart';
import 'package:smart_flat/features/living_space/services/living_space_service.dart';

enum LivingSpaceMode { create, join }

class LivingSpaceOnboardingForm extends StatefulWidget {
  final String userId;

  const LivingSpaceOnboardingForm({super.key, required this.userId});

  @override
  State<LivingSpaceOnboardingForm> createState() =>
      _LivingSpaceOnboardingFormState();
}

class _LivingSpaceOnboardingFormState extends State<LivingSpaceOnboardingForm> {
  final _formKey = GlobalKey<FormState>();

  final livingSpaceName = TextEditingController();
  final inviteCode = TextEditingController();

  LivingSpaceMode selectedMode = LivingSpaceMode.create;

  bool loading = false;

  Future<void> submit() async {
    final livingSpaceProvider = context.read<LivingSpaceProvider>();

    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    setState(() => loading = true);

    try {
      if (selectedMode == LivingSpaceMode.create) {
        final name = livingSpaceName.text.trim();
        await livingSpaceProvider.createLivingSpace(
          createdBy: widget.userId,
          name: name,
        );
      } else {
        final code = inviteCode.text.trim();
        await LivingSpaceInvitationService().joinSpaceWithCode(widget.userId, code);
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      showErrorSnackBar(context, "Living space operation failed");
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    livingSpaceName.dispose();
    inviteCode.dispose();
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
                "Living Space Setup",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                "Create a new living space or join an existing one",
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
              ),
              const SizedBox(height: 24),

              // CREATE
              InkWell(
                onTap: () {
                  setState(() {
                    selectedMode = LivingSpaceMode.create;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selectedMode == LivingSpaceMode.create
                          ? cs.primary
                          : Colors.grey.shade300,
                      width: selectedMode == LivingSpaceMode.create ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            selectedMode == LivingSpaceMode.create
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              "Create new living space",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FormInput(
                        controller: livingSpaceName,
                        icon: Icons.home_outlined,
                        label: "Name",
                        onTap: () {
                          setState(() {
                            selectedMode = LivingSpaceMode.create;
                          });
                        },
                        validator: (value) {
                          if (selectedMode != LivingSpaceMode.create) {
                            return null;
                          }

                          final name = value?.trim() ?? '';

                          if (name.isEmpty) {
                            return "Living space name is required";
                          }

                          if (name.length < 3) {
                            return "Name must be at least 3 characters";
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // JOIN
              InkWell(
                onTap: () {
                  setState(() {
                    selectedMode = LivingSpaceMode.join;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selectedMode == LivingSpaceMode.join
                          ? cs.primary
                          : Colors.grey.shade300,
                      width: selectedMode == LivingSpaceMode.join ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            selectedMode == LivingSpaceMode.join
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              "Join existing space",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FormInput(
                        controller: inviteCode,
                        icon: Icons.key,
                        label: "Code",
                        onTap: () {
                          setState(() {
                            selectedMode = LivingSpaceMode.join;
                          });
                        },
                        validator: (value) {
                          if (selectedMode != LivingSpaceMode.join) {
                            return null;
                          }

                          final code = value?.trim() ?? '';

                          if (code.isEmpty) {
                            return "Invitation code is required";
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              FormSubmitButton(loading: loading, onPressed: submit),
            ],
          ),
        ),
      ),
    );
  }
}
