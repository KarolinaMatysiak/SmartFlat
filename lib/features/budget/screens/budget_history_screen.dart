import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_flat/core/screens/loading_screen.dart';
import 'package:smart_flat/features/auth/providers/auth_provider.dart';
import 'package:smart_flat/features/budget/providers/budget_provider.dart';
import 'package:smart_flat/features/living_space/providers/living_space_provider.dart';
import 'package:smart_flat/features/living_space/services/living_space_service.dart';

class BudgetHistoryScreen extends StatefulWidget {
  const BudgetHistoryScreen({super.key});

  @override
  State<BudgetHistoryScreen> createState() => _BudgetHistoryScreenState();
}

class _BudgetHistoryScreenState extends State<BudgetHistoryScreen> {
  final _livingSpaceService = LivingSpaceService();
  Map<String, String> _memberNames = {};
  bool _isLoadingMembers = true;

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
                m['createdBy']: m['firstName'] ?? m['userName'] ?? 'Użytkownik'
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

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Historia - $livingSpaceName',
            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: (budgetProvider.isLoadingBudgetHistory || _isLoadingMembers)
          ? const Center(child: CircularProgressIndicator())
          : _buildHistoryList(context, budgetProvider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/budget/add'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Nowa operacja",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, BudgetProvider budgetProvider) {
    if (!budgetProvider.hasBudgetHistory) {
      return _buildEmptyState("Brak historii operacji");
    }

    final historyDocs = budgetProvider.budgetHistorySnapshot!.docs;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: historyDocs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final doc = historyDocs[index];
        final data = doc.data();
        final title = data['title'] ?? 'Brak tytułu';
        final amount = (data['amount'] ?? 0.0).toDouble();
        final type = data['type'] ?? 'top-up';
        final createdBy = data['createdBy'];
        final createdAt = data['createdAt']?.toDate();
        final creatorName = _memberNames[createdBy] ?? 'Nieznany';

        final isTopUp = type == 'top-up';
        final dateStr = createdAt != null ? DateFormat('dd.MM.yyyy HH:mm').format(createdAt) : '';

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isTopUp ? Colors.green.shade50 : Colors.red.shade50,
                  child: Icon(
                    isTopUp ? Icons.add_rounded : Icons.remove_rounded,
                    color: isTopUp ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$creatorName • $dateStr',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${isTopUp ? "+" : "-"}${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isTopUp ? Colors.green.shade700 : Colors.red.shade700,
                  ),
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
          Icon(Icons.history_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}
