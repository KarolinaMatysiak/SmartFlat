import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_flat/core/screens/loading_screen.dart';
import 'package:smart_flat/core/widgets/app_background.dart';
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

  String? _selectedMemberId;
  String? _selectedCategory;
  String _dateFilter = 'All time';

  final List<String> _dateFilters = ['All time', 'Today', 'This week', 'This month', 'This year'];
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
      appBar: AppBar(
        title: Text('History - $livingSpaceName',
            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: AppBackground(
        child: SafeArea(
          child: (budgetProvider.isLoadingBudgetHistory || _isLoadingMembers)
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildFilters(),
                    Expanded(child: _buildHistoryList(context, budgetProvider)),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/budget/add'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New operation",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip(
            label: _dateFilter,
            icon: Icons.calendar_today_rounded,
            onTap: _showDateFilterPicker,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: _selectedMemberId == null ? 'All People' : (_memberNames[_selectedMemberId] ?? 'Person'),
            icon: Icons.person_rounded,
            onTap: _showMemberFilterPicker,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: _selectedCategory ?? 'All Categories',
            icon: Icons.category_rounded,
            onTap: _showCategoryFilterPicker,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({required String label, required IconData icon, required VoidCallback onTap}) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  void _showDateFilterPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: _dateFilters.map((f) => ListTile(
          title: Text(f),
          onTap: () {
            setState(() => _dateFilter = f);
            Navigator.pop(context);
          },
          selected: _dateFilter == f,
        )).toList(),
      ),
    );
  }

  void _showMemberFilterPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: const Text('All People'),
            onTap: () {
              setState(() => _selectedMemberId = null);
              Navigator.pop(context);
            },
            selected: _selectedMemberId == null,
          ),
          ..._memberNames.entries.map((e) => ListTile(
            title: Text(e.value),
            onTap: () {
              setState(() => _selectedMemberId = e.key);
              Navigator.pop(context);
            },
            selected: _selectedMemberId == e.key,
          )),
        ],
      ),
    );
  }

  void _showCategoryFilterPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: const Text('All Categories'),
            onTap: () {
              setState(() => _selectedCategory = null);
              Navigator.pop(context);
            },
            selected: _selectedCategory == null,
          ),
          ..._categories.map((c) => ListTile(
            title: Text(c),
            onTap: () {
              setState(() => _selectedCategory = c);
              Navigator.pop(context);
            },
            selected: _selectedCategory == c,
          )),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, BudgetProvider budgetProvider) {
    if (!budgetProvider.hasBudgetHistory) {
      return _buildEmptyState("No operations yet");
    }

    var historyDocs = budgetProvider.budgetHistorySnapshot!.docs.where((doc) {
      final data = doc.data();
      final createdAt = data['createdAt']?.toDate() as DateTime?;
      final createdBy = data['createdBy'] as String?;
      final category = data['category'] as String?;

      // Filter by Member
      if (_selectedMemberId != null && createdBy != _selectedMemberId) return false;

      // Filter by Category
      if (_selectedCategory != null && category != _selectedCategory) return false;

      // Filter by Date
      if (createdAt == null) return true;
      final now = DateTime.now();
      switch (_dateFilter) {
        case 'Today':
          return createdAt.year == now.year && createdAt.month == now.month && createdAt.day == now.day;
        case 'This week':
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          return createdAt.isAfter(DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day));
        case 'This month':
          return createdAt.year == now.year && createdAt.month == now.month;
        case 'This year':
          return createdAt.year == now.year;
        default:
          return true;
      }
    }).toList();

    if (historyDocs.isEmpty) {
      return _buildEmptyState("No matching operations");
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: historyDocs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final doc = historyDocs[index];
        final data = doc.data();
        final title = data['title'] ?? 'No title';
        final amount = (data['amount'] ?? 0.0).toDouble();
        final type = data['type'] ?? 'top-up';
        final category = data['category'];
        final createdBy = data['createdBy'];
        final createdAt = data['createdAt']?.toDate();
        final creatorName = _memberNames[createdBy] ?? 'Unknown';

        final isTopUp = type == 'top-up';
        final dateStr = createdAt != null ? DateFormat('dd.MM.yyyy HH:mm').format(createdAt) : '';

        return Card(
          color: Colors.white.withOpacity(0.8),
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
                      if (category != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        '$creatorName • $dateStr',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
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
          Icon(Icons.history_rounded, size: 64, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        ],
      ),
    );
  }
}

