import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_flat/core/widgets/loading_widget.dart';
import 'package:smart_flat/features/budget/providers/budget_provider.dart';

class BudgetOverviewWidget extends StatelessWidget {
  const BudgetOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();

    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(
            color: Colors.grey.withOpacity(0.15),
            width: 1,
          ),
        ),
        shadowColor: Colors.black.withOpacity(0.04),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => context.push('/budget'),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _buildContent(context, budgetProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BudgetProvider budgetProvider) {
    if (budgetProvider.isLoadingBudget) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: LoadingWidget(),
      );
    }

    double amount = 0.0;
    if (budgetProvider.hasBudget) {
      final doc = budgetProvider.budgetSnapshot!.docs.first;
      amount = (doc.data()['amount'] ?? 0.0).toDouble();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.green.shade600,
              size: 22,
            ),
            const SizedBox(width: 8),
            const Text(
              'Budget',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            children: [
              const TextSpan(text: 'Budget Twojego space to '),
              TextSpan(
                text: amount.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
