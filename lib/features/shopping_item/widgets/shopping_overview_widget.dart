import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_flat/core/widgets/loading_widget.dart';
import 'package:smart_flat/features/shopping_item/providers/shopping_item_provider.dart';

class ShoppingOverviewWidget extends StatelessWidget {
  const ShoppingOverviewWidget({super.key});

  final displayedShoppingLimit = 4;

  @override
  Widget build(BuildContext context) {
    final shoppingProvider = context.watch<ShoppingItemProvider>();
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.push('/shopping-items'),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildContent(context, shoppingProvider, cs),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ShoppingItemProvider shoppingProvider, ColorScheme cs) {
    if (shoppingProvider.isLoading) {
      return const SizedBox(
        height: 100,
        child: LoadingWidget(),
      );
    }

    final userDocs = shoppingProvider.userShoppingItems;
    final totalShoppingCount = userDocs.length;
    final displayDocs = userDocs.take(displayedShoppingLimit).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(totalShoppingCount, cs),

        const SizedBox(height: 16),

        if (!shoppingProvider.hasUserShoppingItems)
          _buildEmptyState(cs)
        else
          _buildShoppingList(context, displayDocs, cs),

        if (shoppingProvider.hasShoppingItems && totalShoppingCount > displayedShoppingLimit)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Center(
              child: Text(
                '+${totalShoppingCount - displayedShoppingLimit} more items',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: cs.secondary.withOpacity(0.7),
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(int totalShoppingCount, ColorScheme cs) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.shopping_cart_rounded,
            color: cs.secondary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Shopping List',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        const Spacer(),
        if (totalShoppingCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: cs.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$totalShoppingCount',
              style: TextStyle(
                color: cs.secondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(width: 8),
        Icon(Icons.chevron_right_rounded, color: cs.onSurface.withOpacity(0.3)),
      ],
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          'Nothing to buy today!\nList is empty.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: cs.onSurface.withOpacity(0.5),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildShoppingList(BuildContext context, List displayDocs, ColorScheme cs) {
    return Column(
      children: displayDocs.asMap().entries.map((entry) {
        return _buildShoppingItem(context, entry.value, cs);
      }).toList(),
    );
  }

  Widget _buildShoppingItem(BuildContext context, dynamic doc, ColorScheme cs) {
    final data = doc.data();
    final itemId = doc.id;

    final title = data['title'] ?? 'No title';
    final status = data['status'] ?? 'pending';
    final isCompleted = status == 'completed';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.read<ShoppingItemProvider>().toggleShoppingItemStatus(itemId, status);
            },
            child: Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isCompleted ? Colors.green.shade500 : cs.secondary.withOpacity(0.4),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isCompleted ? cs.onSurface.withOpacity(0.4) : cs.onSurface,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}