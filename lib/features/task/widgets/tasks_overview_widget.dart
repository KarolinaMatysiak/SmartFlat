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
    final double widgetHeight = MediaQuery.of(context).size.height / 3;

    return SizedBox(
      height: widgetHeight,
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
          onTap: () => context.push('/tasks'),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _buildContent(context, taskProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TaskProvider taskProvider) {
    if (taskProvider.isLoading) {
      return const LoadingWidget();
    }

    final userDocs = taskProvider.userTasks;
    final totalTasksCount = userDocs.length;
    final displayDocs = userDocs.take(displayedTasksLimit).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(totalTasksCount),

        const SizedBox(height: 16),

        if (!taskProvider.hasUserTasks)
          Expanded(
            child: _buildEmptyState(),
          )
        else
          Expanded(
            child: _buildTasksList(context, displayDocs),
          ),

        if (taskProvider.hasUserTasks && totalTasksCount > displayedTasksLimit)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Center(
              child: Text(
                '+${totalTasksCount - displayedTasksLimit} more',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(int totalTasksCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(
              Icons.format_list_bulleted,
              color: Colors.blue,
              size: 22,
            ),
            SizedBox(width: 8),
            Text(
              'Tasks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        if (totalTasksCount > 0)
          Text(
            '$totalTasksCount',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No tasks for today!\nEnjoy your free time.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildTasksList(BuildContext context, List displayDocs) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayDocs.length,
      separatorBuilder: (_, __) => Divider(
        color: Colors.grey.withOpacity(0.15),
        height: 1,
        indent: 44,
      ),
      itemBuilder: (context, index) {
        return _buildTaskItem(context, displayDocs[index], index);
      },
    );
  }

  Widget _buildTaskItem(BuildContext context, dynamic doc, int index) {
    final data = doc.data();
    final taskId = doc.id;

    final title = data['title'] ?? 'No title';
    final description = data['description'] ?? '';
    final status = data['status'] ?? 'pending';
    final isCompleted = status == 'completed';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.read<TaskProvider>().toggleTaskStatus(taskId, status);
            },
            child: Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.pending_rounded,
              color: isCompleted ? Colors.green.shade500 : Colors.amber.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isCompleted ? Colors.grey : Colors.black87,
                    letterSpacing: -0.2,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey.shade300,
            size: 18,
          ),
        ],
      ),
    );
  }
}