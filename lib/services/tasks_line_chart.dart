import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:to_do_list/Providers/TasksProvider.dart';
import 'package:to_do_list/models/tasks_in_day.dart';
import 'package:to_do_list/services/line_chart_data_builder.dart';

class TasksLineChart extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final bool isFullScreen;

  const TasksLineChart({
    super.key,
    required this.startDate,
    required this.endDate,
    this.isFullScreen = false,
  });

  // Helper methods for adaptive colors
  Color _getCardColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surface
        : Colors.white;
  }

  Color _getBorderColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final primaryColor = Theme.of(context).colorScheme.primary;
    return brightness == Brightness.dark
        ? primaryColor.withOpacity(0.3)
        : primaryColor.withOpacity(0.2);
  }

  Color _getShadowColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final primaryColor = Theme.of(context).colorScheme.primary;
    return brightness == Brightness.dark
        ? Colors.black.withOpacity(0.3)
        : primaryColor.withOpacity(0.1);
  }

  Color _getContainerColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final primaryColor = Theme.of(context).colorScheme.primary;
    return brightness == Brightness.dark
        ? primaryColor.withOpacity(0.1)
        : primaryColor.withOpacity(0.05);
  }

  Color _getTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  Color _getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TasksProvider>(
      builder: (context, provider, child) {
        // Get archived tasks
        final archivedTasks = provider.archivedTasksMap;

        // If no data
        if (archivedTasks.isEmpty) {
          return _buildNoDataWidget(context);
        }

        // Get filtered tasks by date range
        final filteredTasks = provider.getFilteredArchivedTasks(
          startDate,
          endDate,
        );

        // If no data in selected range
        if (filteredTasks.isEmpty) {
          return _buildNoDataInRangeWidget(context);
        }

        // Build chart data
        final chartData = LineChartDataBuilder.build(
          archivedTasks,
          startDate,
          endDate,
        );

        // Build chart interface
        return _buildChartWidget(context, chartData, filteredTasks);
      },
    );
  }

  /// Build chart interface
  Widget _buildChartWidget(
    BuildContext context,
    LineChartData chartData,
    Map<String, TasksInDay> filteredTasks,
  ) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart title
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Task Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(context),
                  ),
                ),
                _buildStatsSummary(context, filteredTasks),
              ],
            ),
          ),

          // Chart - full size without internal scroll
          Expanded(
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: LineChart(chartData),
            ),
          ),

          // Legend
          _buildChartLegend(context),

          // Additional info
          _buildAdditionalInfo(context, filteredTasks),
        ],
      ),
    );
  }

  /// Build statistics summary
  Widget _buildStatsSummary(
    BuildContext context,
    Map<String, TasksInDay> filteredTasks,
  ) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    int totalTasks = 0;
    int completedTasks = 0;

    filteredTasks.forEach((key, value) {
      totalTasks += value.tasks.length;
      completedTasks += value.tasks.where((task) => task.isCompleted).length;
    });

    double completionRate = totalTasks > 0
        ? (completedTasks / totalTasks) * 100
        : 0;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryColor.withOpacity(0.3)),
          ),
          child: Text(
            '${completionRate.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Text(
            '$completedTasks/$totalTasks',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
      ],
    );
  }

  /// Build chart legend
  Widget _buildChartLegend(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem('Total Tasks', primaryColor),
          const SizedBox(width: 20),
          _buildLegendItem('Completed', Colors.green),
          const SizedBox(width: 20),
          _buildLegendItem('Pending', Colors.orange),
        ],
      ),
    );
  }

  /// Build legend item
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Build additional information
  Widget _buildAdditionalInfo(
    BuildContext context,
    Map<String, TasksInDay> filteredTasks,
  ) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final daysCount = filteredTasks.length;
    final lastUpdate = filteredTasks.isNotEmpty
        ? filteredTasks.keys.toList().last
        : '';

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                '$daysCount days',
                style: TextStyle(
                  fontSize: 14,
                  color: _getSecondaryTextColor(context),
                ),
              ),
            ],
          ),
          if (lastUpdate.isNotEmpty)
            Row(
              children: [
                Icon(Icons.update, size: 16, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Last update: $lastUpdate',
                  style: TextStyle(
                    fontSize: 14,
                    color: _getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// No data widget
  Widget _buildNoDataWidget(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: _getContainerColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor(context)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 48,
            color: primaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No data available',
            style: TextStyle(
              fontSize: 16,
              color: _getTextColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding tasks to see statistics',
            style: TextStyle(
              fontSize: 14,
              color: _getSecondaryTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// No data in range widget
  Widget _buildNoDataInRangeWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(
          Theme.of(context).brightness == Brightness.dark ? 0.1 : 0.05,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline_outlined,
            size: 48,
            color: Colors.orange.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'No data in selected range',
            style: TextStyle(
              fontSize: 16,
              color: Colors.orange[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'From ${_formatDate(startDate)} to ${_formatDate(endDate)}',
            style: TextStyle(
              fontSize: 14,
              color: _getSecondaryTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Try changing the filter period',
            style: TextStyle(
              fontSize: 14,
              color: _getSecondaryTextColor(context),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// Format date
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
