import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_flat/core/widgets/loading_widget.dart';
import 'package:smart_flat/features/task/providers/task_provider.dart';

class TasksOverviewWidget extends StatelessWidget {
  const TasksOverviewWidget({super.key});

  final displayedTasksLimit = 4;

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.push('/tasks'),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildContent(context, taskProvider, cs),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TaskProvider taskProvider, ColorScheme cs) {
    if (taskProvider.isLoading) {
      return const SizedBox(
        height: 100,
        child: LoadingWidget(),
      );
    }

    final userDocs = taskProvider.userTasks;
    final totalTasksCount = userDocs.length;
    final displayDocs = userDocs.take(displayedTasksLimit).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(totalTasksCount, cs),

        const SizedBox(height: 16),

        if (!taskProvider.hasUserTasks)
          _buildEmptyState(cs)
        else
          _buildTasksList(context, displayDocs, cs),

        if (taskProvider.hasUserTasks && totalTasksCount > displayedTasksLimit)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Center(
              child: Text(
                '+${totalTasksCount - displayedTasksLimit} more tasks',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: cs.primary.withOpacity(0.7),
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(int totalTasksCount, ColorScheme cs) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.check_box_rounded,
            color: cs.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Your Tasks',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        const Spacer(),
        if (totalTasksCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$totalTasksCount',
              style: TextStyle(
                color: cs.primary,
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
          'No tasks for today!\nEnjoy your free time.',
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

  Widget _buildTasksList(BuildContext context, List displayDocs, ColorScheme cs) {
    return Column(
      children: displayDocs.asMap().entries.map((entry) {
        return _buildTaskItem(context, entry.value, cs);
      }).toList(),
    );
  }

  Widget _buildTaskItem(BuildContext context, dynamic doc, ColorScheme cs) {
    final data = doc.data();
    final taskId = doc.id;

    final title = data['title'] ?? 'No title';
    final status = data['status'] ?? 'pending';
    final isCompleted = status == 'completed';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.read<TaskProvider>().toggleTaskStatus(taskId, status);
            },
            child: Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isCompleted ? Colors.green.shade500 : cs.primary.withOpacity(0.4),
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