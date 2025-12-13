import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slideable/slideable.dart';
import 'package:to_do_list/Providers/TasksProvider.dart';

class Taskcard extends StatelessWidget {
  final Widget title;
  final Widget priority;
  final TimeOfDay taskTime;
  final bool isComplete;
  final int index;

  const Taskcard({
    super.key,
    required this.title,
    required this.priority,
    required this.isComplete,
    required this.taskTime,
    required this.index,
  });

  String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    TextStyle? titleStyle = isComplete
        ? TextStyle(
            decoration: TextDecoration.lineThrough,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          )
        : null;

    final cardColor = isComplete
        ? (isDark ? Colors.grey.shade800 : Colors.deepPurple.shade50)
        : (isDark
              ? Colors.grey.shade900
              : const Color.fromARGB(255, 248, 243, 255));

    final borderColor = isDark
        ? Colors.grey.shade700
        : Colors.deepPurple.shade300;
    final shadowColor = isDark
        ? Colors.black26
        : Colors.deepPurple.shade100.withOpacity(0.5);
    final textColor = isComplete
        ? (isDark ? Colors.grey.shade400 : Colors.grey.shade600)
        : (isDark ? Colors.white : Colors.deepPurple.shade800);
    final timeColor = isDark
        ? Colors.grey.shade400
        : Colors.deepPurple.shade400;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),

      child: Slideable(
        backgroundColor: Colors.transparent,
        items: <ActionItems>[
          ActionItems(
            backgroudColor: Colors.transparent,
            icon: Icon(Icons.edit, color: theme.colorScheme.secondary),
            onPress: () {
              context.read<TasksProvider>().editTaskDialog(context, index);
            },
          ),
          ActionItems(
            backgroudColor: Colors.transparent,
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPress: () {
              context.read<TasksProvider>().deleteTask(index);
            },
          ),
        ],
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            onTap: () {
              context.read<TasksProvider>().toggleCompletion(index);
            },
            leading: SizedBox(
              height: double.infinity,
              child: Checkbox(
                activeColor: theme.colorScheme.primary,
                value: isComplete,
                onChanged: (value) {
                  context.read<TasksProvider>().toggleCompletion(index);
                },
              ),
            ),
            title: DefaultTextStyle.merge(
              style: titleStyle?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              child: title,
            ),
            subtitle: Row(
              children: [
                Expanded(child: priority),
                Text(
                  "Time: ${formatTime(taskTime)}",
                  style: TextStyle(fontSize: 12, color: timeColor),
                ),
              ],
            ),
            trailing: isComplete
                ? const Icon(Icons.check_circle, color: Colors.green, size: 26)
                : null,
          ),
        ),
      ),
    );
  }
}
