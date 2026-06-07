import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_flat/features/task/providers/task_provider.dart';

class TodoListWidget extends StatelessWidget {
  const TodoListWidget({super.key});

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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildWidgetContent(context, taskProvider),
        ),
      ),
    );
  }

  Widget _buildWidgetContent(BuildContext context, TaskProvider taskProvider) {
    if (taskProvider.isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (!taskProvider.hasTasks) {
      return Center(
        child: Text(
          "No tasks for today!\nEnjoy your free time.",
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

    final allDocs = taskProvider.tasksSnapshot!.docs;
    final totalTasksCount = allDocs.length;
    final displayDocs = allDocs.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.format_list_bulleted, color: Colors.blue, size: 22),
                SizedBox(width: 8),
                Text(
                  "Zadania",
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
                "$totalTasksCount",
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: displayDocs.length,
            separatorBuilder: (_, __) => Divider(
              color: Colors.grey.withOpacity(0.15),
              height: 1,
              indent: 44,
            ),
            itemBuilder: (context, index) {
              final doc = displayDocs[index];
              final data = doc.data();
              final title = data['title'] ?? 'No title';
              final description = data['description'] ?? '';

              final isFirst = index == 0;

              return InkWell(
                onTap: () {
                  print("Clicked task ID: ${doc.id}");
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    children: [
                      // Okrągły checkbox / gwiazdka
                      Icon(
                        isFirst ? Icons.star_rounded : Icons.radio_button_off_rounded,
                        color: isFirst ? Colors.amber : Colors.grey.shade400,
                        size: isFirst ? 26 : 22,
                      ),
                      const SizedBox(width: 12),

                      // Tekst zadania
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: isFirst ? 17 : 15,
                                fontWeight: isFirst ? FontWeight.bold : FontWeight.w500,
                                color: Colors.black87,
                                letterSpacing: -0.2,
                              ),
                            ),
                            if (description.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: isFirst ? 14 : 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 18),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Trzy kropki na dole
        if (totalTasksCount > 5) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Center(
              child: Icon(
                Icons.more_horiz_rounded,
                color: Colors.grey.shade400,
                size: 24,
              ),
            ),
          ),
        ],
      ],
    );
  }
}