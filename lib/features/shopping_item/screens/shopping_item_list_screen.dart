import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_flat/core/screens/loading_screen.dart';
import 'package:smart_flat/core/widgets/app_background.dart';
import 'package:smart_flat/features/auth/providers/auth_provider.dart';
import 'package:smart_flat/features/living_space/providers/living_space_provider.dart';
import 'package:smart_flat/features/living_space/services/living_space_service.dart';
import 'package:smart_flat/features/shopping_item/providers/shopping_item_provider.dart';
import 'package:smart_flat/features/shopping_item/screens/create_shopping_item_screen.dart';

class ShoppingItemsListScreen extends StatefulWidget {
  const ShoppingItemsListScreen({super.key});

  @override
  State<ShoppingItemsListScreen> createState() => _ShoppingItemsListScreenState();
}

class _ShoppingItemsListScreenState extends State<ShoppingItemsListScreen> {
  final _livingSpaceService = LivingSpaceService();
  Map<String, String> _memberNames = {};
  bool _isLoadingMembers = true;

  String _statusFilter = 'all';
  String? _memberFilter;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    final spaceProvider = context.read<LivingSpaceProvider>();
    if (spaceProvider.hasSpaces) {
      final spaceDoc = spaceProvider.spacesSnapshot!.docs.first;
      final memberIds = List<String>.from(spaceDoc.data()['memberIds'] ?? []);
      try {
        final members = await _livingSpaceService.getMembers(memberIds);
        if (mounted) {
          setState(() {
            _memberNames = {
              for (var m in members)
                m['createdBy']: m['firstName'] ?? m['userName'] ?? 'User'
            };
            _isLoadingMembers = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isLoadingMembers = false);
      }
    } else {
      if (mounted) setState(() => _isLoadingMembers = false);
    }
  }

  void _deleteShoppingItem(String shoppingItemId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Item"),
        content: const Text("Do you want to delete this item?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<ShoppingItemProvider>().deleteShoppingItem(shoppingItemId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shoppingItemProvider = context.watch<ShoppingItemProvider>();
    final livingSpaceProvider = context.watch<LivingSpaceProvider>();
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isAuthenticated ||
        livingSpaceProvider.isLoading ||
        livingSpaceProvider.spacesSnapshot == null ||
        !livingSpaceProvider.hasSpaces) {
      return const LoadingScreen();
    }

    final docs = livingSpaceProvider.spacesSnapshot!.docs;
    final livingSpaceName = docs.first.data()['name'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(livingSpaceName, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: AppBackground(
        child: SafeArea(
          child: (shoppingItemProvider.isLoading || _isLoadingMembers)
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildFilterBar(),
                    Expanded(child: _buildShoppingItemsList(context, shoppingItemProvider)),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/shopping-items/create'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New item", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _FilterChip(
            label: "All",
            isSelected: _statusFilter == 'all',
            onSelected: (_) => setState(() => _statusFilter = 'all'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: "Pending",
            isSelected: _statusFilter == 'pending',
            onSelected: (_) => setState(() => _statusFilter = 'pending'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: "Completed",
            isSelected: _statusFilter == 'completed',
            onSelected: (_) => setState(() => _statusFilter = 'completed'),
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 24, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(width: 16),

          DropdownButton<String?>(
            value: _memberFilter,
            hint: const Text("Filter members", style: TextStyle(fontSize: 14)),
            underline: const SizedBox(),
            dropdownColor: Colors.white,
            items: [
              const DropdownMenuItem(value: null, child: Text("Everyone")),
              ..._memberNames.entries.map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value),
                  )),
            ],
            onChanged: (val) => setState(() => _memberFilter = val),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingItemsList(BuildContext context, ShoppingItemProvider shoppingItemProvider) {
    if (!shoppingItemProvider.hasShoppingItems) {
      return _buildEmptyState("This space has no shopping items yet");
    }

    final filteredDocs = shoppingItemProvider.shoppingItemsSnapshot!.docs.where((doc) {
      final data = doc.data();
      final status = data['status'] ?? 'pending';
      final assignedTo = data['assignedTo'];

      final matchesStatus = _statusFilter == 'all' || status == _statusFilter;
      final matchesMember = _memberFilter == null || assignedTo == _memberFilter;

      return matchesStatus && matchesMember;
    }).toList();

    if (filteredDocs.isEmpty) {
      return _buildEmptyState("There are no results for current filter");
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: filteredDocs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final doc = filteredDocs[index];
        final data = doc.data();
        final shoppingItemId = doc.id;
        final title = data['title'] ?? 'No title';
        final description = data['description'] ?? '';
        final assignedTo = data['assignedTo'];
        final status = data['status'] ?? 'pending';
        final isCompleted = status == 'completed';
        final assignedName = _memberNames[assignedTo] ?? 'Unassigned';

        return Card(
          color: Colors.white.withOpacity(0.8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => shoppingItemProvider.toggleShoppingItemStatus(shoppingItemId, status),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      isCompleted ? Icons.check_circle_rounded : Icons.pending_rounded,
                      color: isCompleted ? Colors.green.shade500 : Colors.amber.shade600,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? Colors.grey : Colors.black87,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                          children: [
                            TextSpan(text: title),
                            TextSpan(
                              text: "  •  ",
                              style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.normal),
                            ),
                            TextSpan(
                              text: assignedName,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CreateShoppingItemScreen(shoppingItemToEdit: doc)),
                      ),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      color: Colors.grey[400],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => _deleteShoppingItem(shoppingItemId),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      color: Colors.red[300],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Function(bool) onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.white.withOpacity(0.5),
      selectedColor: cs.primary.withOpacity(0.2),
      checkmarkColor: cs.primary,
      labelStyle: TextStyle(
        color: isSelected ? cs.primary : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? cs.primary : Colors.grey.withOpacity(0.2),
        ),
      ),
    );
  }
}

