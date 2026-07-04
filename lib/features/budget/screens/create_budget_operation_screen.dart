import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_flat/core/widgets/app_background.dart';
import 'package:smart_flat/core/widgets/form_input.dart';
import 'package:smart_flat/core/widgets/form_submit_button.dart';
import 'package:smart_flat/features/auth/providers/auth_provider.dart';
import 'package:smart_flat/features/budget/providers/budget_provider.dart';

class CreateBudgetOperationScreen extends StatefulWidget {
  const CreateBudgetOperationScreen({super.key});

  @override
  State<CreateBudgetOperationScreen> createState() => _CreateBudgetOperationScreenState();
}

class _CreateBudgetOperationScreenState extends State<CreateBudgetOperationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _type = 'top-up';
  String _category = 'Other';
  bool _isLoading = false;

  final List<String> _categories = [
    'Fixed Charges',
    'Food',
    'Cleaning & Household',
    'Home Furnishings',
    'Repairs & Maintenance',
    'Entertainment',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final budgetProvider = context.read<BudgetProvider>();

      await budgetProvider.addOperation(
        createdBy: authProvider.currentUser!.uid,
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        type: _type,
        category: _type == 'withdrawal' ? _category : null,
      );

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Operation', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              color: Colors.white.withOpacity(0.85),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _type,
                        decoration: InputDecoration(
                          labelText: 'Operation Type',
                          prefixIcon: Icon(Icons.swap_vert_rounded, color: cs.primary),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'top-up', child: Text('Top-up')),
                          DropdownMenuItem(value: 'withdrawal', child: Text('Withdrawal')),
                        ],
                        onChanged: (val) => setState(() => _type = val!),
                      ),
                      const SizedBox(height: 16),
                      if (_type == 'withdrawal') ...[
                        DropdownButtonFormField<String>(
                          value: _category,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            prefixIcon: Icon(Icons.category_rounded, color: cs.primary),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                          onChanged: (val) => setState(() => _category = val!),
                        ),
                        const SizedBox(height: 16),
                      ],
                      FormInput(
                        controller: _titleController,
                        icon: Icons.title_rounded,
                        label: 'Title',
                        validator: (val) => val == null || val.isEmpty ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 16),
                      FormInput(
                        controller: _amountController,
                        icon: Icons.attach_money_rounded,
                        label: 'Amount',
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Amount is required';
                          if (double.tryParse(val) == null) return 'Invalid amount';
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      FormSubmitButton(
                        loading: _isLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

