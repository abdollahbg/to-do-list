import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:to_do_list/models/tasks_in_day.dart';

class LineChartDataBuilder {
  static LineChartData build(
    Map<String, TasksInDay> archivedTasks,
    DateTime startDate,
    DateTime endDate,
  ) {
    final filteredTasks = _filterTasksByDateRange(
      archivedTasks,
      startDate,
      endDate,
    );

    if (filteredTasks.isEmpty) {
      return _buildEmptyChart();
    }

    filteredTasks.sort((a, b) => a.date.compareTo(b.date));

    final allTasksSpots = <FlSpot>[];
    final completedTasksSpots = <FlSpot>[];
    final pendingTasksSpots = <FlSpot>[];

    for (int i = 0; i < filteredTasks.length; i++) {
      final day = filteredTasks[i];
      final total = day.tasks.length.toDouble();
      final completed = day.tasks.where((t) => t.isCompleted).length.toDouble();
      final pending = total - completed;

      allTasksSpots.add(FlSpot(i.toDouble(), total));
      completedTasksSpots.add(FlSpot(i.toDouble(), completed));
      pendingTasksSpots.add(FlSpot(i.toDouble(), pending));
    }

    return LineChartData(
      lineTouchData: _buildLineTouchData(filteredTasks),
      gridData: _buildGridData(),
      titlesData: _buildTitlesData(filteredTasks),
      borderData: _buildBorderData(),
      minY: 0,
      maxY: _calculateMaxY(allTasksSpots),
      lineBarsData: [
        _buildLineBarData(allTasksSpots, 'Total Tasks', Colors.purple),
        _buildLineBarData(
          completedTasksSpots,
          'Completed',
          const Color(0xFF4CAF50),
        ),
        _buildLineBarData(
          pendingTasksSpots,
          'Pending',
          const Color(0xFFFF9800),
        ),
      ],
    );
  }

  static List<TasksInDay> _filterTasksByDateRange(
    Map<String, TasksInDay> archivedTasks,
    DateTime startDate,
    DateTime endDate,
  ) {
    final filtered = <TasksInDay>[];

    archivedTasks.forEach((dateKey, tasksInDay) {
      final date = DateTime.parse(dateKey);
      if (!date.isBefore(startDate) && !date.isAfter(endDate)) {
        filtered.add(tasksInDay);
      }
    });

    return filtered;
  }

  static double _calculateMaxY(List<FlSpot> spots) {
    if (spots.isEmpty) return 10;
    double max = spots.first.y;
    for (final spot in spots) {
      if (spot.y > max) max = spot.y;
    }
    return (max + 2).ceilToDouble();
  }

  static LineChartData _buildEmptyChart() {
    return LineChartData(
      lineTouchData: LineTouchData(enabled: false),
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [],
      minY: 0,
      maxY: 10,
    );
  }

  static LineTouchData _buildLineTouchData(List<TasksInDay> filteredTasks) {
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        fitInsideHorizontally: true,
        getTooltipItems: (List<LineBarSpot> touchedSpots) {
          return touchedSpots.map((spot) {
            final index = spot.spotIndex;
            final value = spot.y.toInt();

            String title;
            Color color;

            switch (spot.barIndex) {
              case 0:
                title = 'Total Tasks';
                color = const Color(0xFF2196F3);
                break;
              case 1:
                title = 'Completed';
                color = const Color(0xFF4CAF50);
                break;
              case 2:
                title = 'Pending';
                color = const Color(0xFFFF9800);
                break;
              default:
                title = 'Unknown';
                color = Colors.grey;
            }

            if (index >= 0 && index < filteredTasks.length) {
              final date = DateFormat(
                'yyyy-MM-dd',
              ).format(filteredTasks[index].date);
              return LineTooltipItem(
                '$title\n number: $date\n value $value',
                TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }

            return LineTooltipItem(
              '$title: $value',
              TextStyle(color: color, fontWeight: FontWeight.bold),
            );
          }).toList();
        },
      ),
    );
  }

  static LineChartBarData _buildLineBarData(
    List<FlSpot> spots,
    String label,
    Color color,
  ) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.3,
      barWidth: 3,
      color: color,
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.1),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.3), color.withOpacity(0.05)],
        ),
      ),
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: color,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      shadow: Shadow(
        color: color.withOpacity(0.5),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color, color.withOpacity(0.7)],
      ),
    );
  }

  static FlGridData _buildGridData() {
    return FlGridData(
      show: true,
      drawHorizontalLine: true,
      drawVerticalLine: false,
      horizontalInterval: 1,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Colors.grey.withOpacity(0.2),
          strokeWidth: 1,
          dashArray: [5, 5],
        );
      },
    );
  }

  static FlTitlesData _buildTitlesData(List<TasksInDay> filteredTasks) {
    return FlTitlesData(
      show: true,
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

      leftTitles: AxisTitles(
        axisNameWidget: const Text(
          'Tasks number',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            if (value == meta.min || value == meta.max) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            );
          },
        ),
      ),

      bottomTitles: AxisTitles(
        axisNameWidget: const Text(
          'date',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: _calculateTitleInterval(filteredTasks.length),
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= filteredTasks.length) {
              return const SizedBox.shrink();
            }

            final date = filteredTasks[index].date;
            String format;

            if (filteredTasks.length <= 7) {
              format = 'MM/dd\nEEE';
            } else if (filteredTasks.length <= 30) {
              format = 'MM/dd';
            } else {
              format = 'MM';
            }

            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Transform.rotate(
                angle: -0.5,
                child: Text(
                  DateFormat(format).format(date),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static double _calculateTitleInterval(int dataCount) {
    if (dataCount <= 7) return 1;
    if (dataCount <= 14) return 2;
    if (dataCount <= 30) return 3;
    if (dataCount <= 60) return 5;
    if (dataCount <= 90) return 7;
    return 10;
  }

  static FlBorderData _buildBorderData() {
    return FlBorderData(
      show: true,
      border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
    );
  }

  static LineChartData buildSimple(Map<String, TasksInDay> archivedTasks) {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day - 7);
    final endDate = now;

    return build(archivedTasks, startDate, endDate);
  }
}
