import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slideable/slideable.dart';
import 'TasksProvider.dart';

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
    TextStyle? titleStyle = isComplete
        ? TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          )
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Slideable(
        backgroundColor: Colors.transparent,
        items: <ActionItems>[
          ActionItems(
            backgroudColor: Colors.transparent,
            icon: Icon(Icons.edit, color: Colors.deepPurple.shade400),
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
            color: isComplete
                ? Colors.deepPurple.shade50
                : const Color.fromARGB(255, 248, 243, 255),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.deepPurple.shade300, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.shade100.withOpacity(0.5),
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
                activeColor: Colors.deepPurple,
                value: isComplete,
                onChanged: (value) {
                  context.read<TasksProvider>().toggleCompletion(index);
                },
              ),
            ),
            title: DefaultTextStyle.merge(
              style: titleStyle?.copyWith(
                color: isComplete
                    ? Colors.grey.shade600
                    : Colors.deepPurple.shade800,
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.deepPurple.shade400,
                  ),
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
