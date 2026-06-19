import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_flat/core/screens/loading_screen.dart';
import 'package:smart_flat/features/auth/providers/auth_provider.dart';
import 'package:smart_flat/features/living_space/providers/living_space_provider.dart';
import 'package:smart_flat/features/living_space/services/living_space_service.dart';
import 'package:smart_flat/features/task/providers/task_provider.dart';
import 'package:smart_flat/features/task/screens/create_task_screen.dart';

class TasksListScreen extends StatefulWidget {
  const TasksListScreen({super.key});

  @override
  State<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends State<TasksListScreen> {
  final _livingSpaceService = LivingSpaceService();
  Map<String, String> _memberNames = {};
  bool _isLoadingMembers = true;

  // Filtry
  String _statusFilter = 'all';
  String? _memberFilter; // null (wszyscy) lub ID użytkownika

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

  void _deleteTask(String taskId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Usuń zadanie"),
        content: const Text("Czy na pewno chcesz usunąć to zadanie?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Anuluj")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Usuń"),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<TaskProvider>().deleteTask(taskId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
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
        title: Text(livingSpaceName, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: (taskProvider.isLoading || _isLoadingMembers)
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterBar(),
                Expanded(child: _buildTasksList(context, taskProvider)),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tasks/create'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New task", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          Container(width: 1, height: 24, color: Colors.grey[300]),
          const SizedBox(width: 16),

          DropdownButton<String?>(
            value: _memberFilter,
            hint: const Text("Filter members", style: TextStyle(fontSize: 14)),
            underline: const SizedBox(),
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

  Widget _buildTasksList(BuildContext context, TaskProvider taskProvider) {
    if (!taskProvider.hasTasks) {
      return _buildEmptyState("This space has no tasks yet");
    }

    final filteredDocs = taskProvider.tasksSnapshot!.docs.where((doc) {
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
        final taskId = doc.id;
        final title = data['title'] ?? 'Bez tytułu';
        final description = data['description'] ?? '';
        final assignedTo = data['assignedTo'];
        final status = data['status'] ?? 'pending';
        final isCompleted = status == 'completed';
        final assignedName = _memberNames[assignedTo] ?? 'Nieprzypisane';

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => taskProvider.toggleTaskStatus(taskId, status),
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
                                color: Colors.blue.shade600,
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
                        MaterialPageRoute(builder: (_) => CreateTaskScreen(taskToEdit: doc)),
                      ),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      color: Colors.grey[400],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => _deleteTask(taskId),
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
          Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey, fontSize: 16)),
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
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.white,
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[300]!,
        ),
      ),
    );
  }
}
