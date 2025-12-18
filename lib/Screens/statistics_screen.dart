import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:to_do_list/Providers/TasksProvider.dart';
import 'package:to_do_list/models/tasks_in_day.dart';
import 'package:to_do_list/services/statistics_filter.dart';
import 'package:to_do_list/services/tasks_line_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  StatisticsFilter _currentFilter = StatisticsFilter.weekly;
  bool _showChart = true;

  void _onFilterChanged(DateTime start, DateTime end) {
    setState(() {
      _startDate = start;
      _endDate = end;
    });
  }

  void _toggleView() {
    setState(() {
      _showChart = !_showChart;
    });
  }

  Map<String, TasksInDay> _getFilteredTasks(TasksProvider provider) {
    return provider.getFilteredArchivedTasks(_startDate, _endDate);
  }

  Map<String, dynamic> _calculateStatistics(
    Map<String, TasksInDay> filteredTasks,
  ) {
    int totalTasks = 0;
    int completedTasks = 0;
    int highPriorityTasks = 0;
    int mediumPriorityTasks = 0;
    int lowPriorityTasks = 0;
    int daysWithTasks = 0;
    int mostProductiveDayTasks = 0;
    String? mostProductiveDay;

    filteredTasks.forEach((dateKey, tasksInDay) {
      final tasks = tasksInDay.tasks;
      if (tasks.isNotEmpty) {
        daysWithTasks++;

        final total = tasks.length;
        final completed = tasks.where((task) => task.isCompleted).length;
        final highPriority = tasks.where((task) => task.priority == 3).length;
        final mediumPriority = tasks.where((task) => task.priority == 2).length;
        final lowPriority = tasks.where((task) => task.priority == 1).length;

        totalTasks += total;
        completedTasks += completed;
        highPriorityTasks += highPriority;
        mediumPriorityTasks += mediumPriority;
        lowPriorityTasks += lowPriority;

        // Find the most productive day
        if (total > mostProductiveDayTasks) {
          mostProductiveDayTasks = total;
          mostProductiveDay = dateKey;
        }
      }
    });

    final completionRate = totalTasks > 0
        ? (completedTasks / totalTasks) * 100
        : 0;
    final averagePerDay = daysWithTasks > 0 ? totalTasks / daysWithTasks : 0;
    final productivityScore = daysWithTasks > 0
        ? (completedTasks / daysWithTasks) * 10
        : 0;

    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'pendingTasks': totalTasks - completedTasks,
      'completionRate': completionRate,
      'daysWithTasks': daysWithTasks,
      'daysCount': filteredTasks.length,
      'averagePerDay': averagePerDay,
      'productivityScore': productivityScore,
      'highPriorityTasks': highPriorityTasks,
      'mediumPriorityTasks': mediumPriorityTasks,
      'lowPriorityTasks': lowPriorityTasks,
      'mostProductiveDay': mostProductiveDay,
      'mostProductiveDayTasks': mostProductiveDayTasks,
    };
  }

  List<Map<String, dynamic>> _getDailyStats(
    Map<String, TasksInDay> filteredTasks,
  ) {
    final dailyStats = <Map<String, dynamic>>[];

    filteredTasks.forEach((dateKey, tasksInDay) {
      final tasks = tasksInDay.tasks;
      final total = tasks.length;
      final completed = tasks.where((task) => task.isCompleted).length;
      final pending = total - completed;

      dailyStats.add({
        'date': dateKey,
        'dateFormatted': DateFormat(
          'EEE, MMM d',
        ).format(DateTime.parse(dateKey)),
        'total': total,
        'completed': completed,
        'pending': pending,
        'completionRate': total > 0 ? (completed / total) * 100 : 0,
      });
    });

    dailyStats.sort((a, b) => b['date'].compareTo(a['date']));
    return dailyStats;
  }

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
    return brightness == Brightness.dark
        ? Colors.black.withOpacity(0.3)
        : Theme.of(context).colorScheme.primary.withOpacity(0.1);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistics"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_showChart ? Icons.list : Icons.bar_chart),
            onPressed: _toggleView,
            tooltip: _showChart ? 'Show List' : 'Show Chart',
          ),
        ],
      ),
      body: Consumer<TasksProvider>(
        builder: (context, provider, child) {
          final filteredTasks = _getFilteredTasks(provider);
          final statistics = _calculateStatistics(filteredTasks);
          final dailyStats = _getDailyStats(filteredTasks);
          final hasData = filteredTasks.isNotEmpty;

          return ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              // Filter section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getContainerColor(context),
                  boxShadow: [
                    BoxShadow(
                      color: _getShadowColor(context),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border(
                    bottom: BorderSide(
                      color: _getBorderColor(context),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    StatisticsFilterWidget(
                      onFilterChanged: _onFilterChanged,
                      initialFilter: _currentFilter,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'From ${_formatDate(_startDate)} to ${_formatDate(_endDate)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: _getSecondaryTextColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              if (!hasData)
                _buildNoDataWidget(context)
              else
                _showChart
                    ? _buildChartView(context, statistics)
                    : _buildListView(context, dailyStats, statistics),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChartView(
    BuildContext context,
    Map<String, dynamic> statistics,
  ) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Main statistics cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard(
                  context: context,
                  title: 'Total Tasks',
                  value: statistics['totalTasks'].toString(),
                  icon: Icons.task,
                  color: primaryColor,
                  subtitle: '${statistics['daysWithTasks']} days',
                ),
                _buildStatCard(
                  context: context,
                  title: 'Completed',
                  value: statistics['completedTasks'].toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                  subtitle:
                      '${statistics['completionRate'].toStringAsFixed(1)}%',
                ),
                _buildStatCard(
                  context: context,
                  title: 'Pending',
                  value: statistics['pendingTasks'].toString(),
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                  subtitle:
                      '${statistics['averagePerDay'].toStringAsFixed(1)} tasks/day',
                ),
                _buildStatCard(
                  context: context,
                  title: 'Productivity Score',
                  value: statistics['productivityScore'].toStringAsFixed(1),
                  icon: Icons.trending_up,
                  color: theme.colorScheme.secondary,
                  subtitle: 'out of 10',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Chart - Larger size
            Container(
              height: 350,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getCardColor(context),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _getShadowColor(context),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: _getBorderColor(context), width: 1),
              ),
              child: TasksLineChart(
                startDate: _startDate,
                endDate: _endDate,
                isFullScreen: false,
              ),
            ),

            const SizedBox(height: 24),

            // Priority statistics
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getCardColor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _getBorderColor(context), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: _getShadowColor(context),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.priority_high, color: primaryColor, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Priority Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getTextColor(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPriorityItem(
                        context: context,
                        label: 'High',
                        count: statistics['highPriorityTasks'],
                        color: Colors.red,
                      ),
                      _buildPriorityItem(
                        context: context,
                        label: 'Medium',
                        count: statistics['mediumPriorityTasks'],
                        color: Colors.orange,
                      ),
                      _buildPriorityItem(
                        context: context,
                        label: 'Low',
                        count: statistics['lowPriorityTasks'],
                        color: Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Additional information
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getCardColor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _getBorderColor(context), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: _getShadowColor(context),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: primaryColor, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Additional Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getTextColor(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (statistics['mostProductiveDay'] != null)
                    _buildInfoRow(
                      context: context,
                      icon: Icons.emoji_events,
                      title: 'Most Productive Day',
                      value:
                          '${statistics['mostProductiveDayTasks']} tasks on ${DateFormat('EEE, MMM d').format(DateTime.parse(statistics['mostProductiveDay']))}',
                    ),
                  _buildInfoRow(
                    context: context,
                    icon: Icons.calendar_today,
                    title: 'Days Count',
                    value:
                        '${statistics['daysWithTasks']} of ${statistics['daysCount']} days',
                  ),
                  _buildInfoRow(
                    context: context,
                    icon: Icons.auto_graph,
                    title: 'Daily Average',
                    value:
                        '${statistics['averagePerDay'].toStringAsFixed(1)} tasks per day',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(
    BuildContext context,
    List<Map<String, dynamic>> dailyStats,
    Map<String, dynamic> statistics,
  ) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Main statistics cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard(
                  context: context,
                  title: 'Total Tasks',
                  value: statistics['totalTasks'].toString(),
                  icon: Icons.task,
                  color: primaryColor,
                  subtitle: '${statistics['daysWithTasks']} days',
                ),
                _buildStatCard(
                  context: context,
                  title: 'Completed',
                  value: statistics['completedTasks'].toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                  subtitle:
                      '${statistics['completionRate'].toStringAsFixed(1)}%',
                ),
                _buildStatCard(
                  context: context,
                  title: 'Pending',
                  value: statistics['pendingTasks'].toString(),
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                  subtitle:
                      '${statistics['averagePerDay'].toStringAsFixed(1)} tasks/day',
                ),
                _buildStatCard(
                  context: context,
                  title: 'Productivity Score',
                  value: statistics['productivityScore'].toStringAsFixed(1),
                  icon: Icons.trending_up,
                  color: Theme.of(context).colorScheme.secondary,
                  subtitle: 'out of 10',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // List title
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: _getContainerColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getBorderColor(context), width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month, size: 24, color: primaryColor),
                  const SizedBox(width: 12),
                  Text(
                    'Daily Statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getTextColor(context),
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '${dailyStats.length} days',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    backgroundColor: primaryColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Daily statistics list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dailyStats.length,
              itemBuilder: (context, index) {
                final stat = dailyStats[index];
                final completionRate = stat['completionRate'] as double;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: _getCardColor(context),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _getShadowColor(context),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: _getBorderColor(context),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: _getCompletionColor(
                        completionRate,
                      ).withOpacity(0.1),
                      radius: 24,
                      child: Text(
                        '${completionRate.toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          color: _getCompletionColor(completionRate),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      stat['dateFormatted'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _getTextColor(context),
                      ),
                    ),
                    subtitle: Text(
                      '${stat['completed']} completed of ${stat['total']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: _getSecondaryTextColor(context),
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${stat['total']} tasks',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String subtitle = '',
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getShadowColor(context),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: _getBorderColor(context), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _getSecondaryTextColor(context),
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityItem({
    required BuildContext context,
    required String label,
    required int count,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
            border: Border.all(
              color: color.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.5 : 0.3,
              ),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 22, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: _getSecondaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataWidget(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 100,
              color: primaryColor.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Statistics Data Available',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _getTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'From ${_formatDate(_startDate)} to ${_formatDate(_endDate)}',
              style: TextStyle(
                fontSize: 16,
                color: _getSecondaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _startDate = DateTime.now().subtract(const Duration(days: 7));
                  _endDate = DateTime.now();
                  _currentFilter = StatisticsFilter.weekly;
                });
              },
              icon: Icon(
                Icons.refresh,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              label: Text(
                'Reset',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: primaryColor.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Try changing the filter period or add new tasks',
              style: TextStyle(
                fontSize: 14,
                color: _getSecondaryTextColor(context),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getCompletionColor(double rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 50) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
