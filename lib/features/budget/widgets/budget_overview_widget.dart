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
    final cs = Theme.of(context).colorScheme;

    return Card(
      color: Colors.white.withOpacity(0.8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/budget'),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildContent(context, budgetProvider, cs),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BudgetProvider budgetProvider, ColorScheme cs) {
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.green.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Space Budget',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: cs.onSurface.withOpacity(0.3)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              amount.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'PLN',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

}
