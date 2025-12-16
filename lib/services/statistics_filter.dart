import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum StatisticsFilter { daily, weekly, monthly, yearly, custom }

class StatisticsFilterWidget extends StatefulWidget {
  final Function(DateTime start, DateTime end) onFilterChanged;
  final StatisticsFilter initialFilter;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const StatisticsFilterWidget({
    super.key,
    required this.onFilterChanged,
    this.initialFilter = StatisticsFilter.weekly,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<StatisticsFilterWidget> createState() => _StatisticsFilterWidgetState();
}

class _StatisticsFilterWidgetState extends State<StatisticsFilterWidget> {
  late StatisticsFilter selectedFilter;
  DateTimeRange? customRange;

  // Capitalized labels for better UI appearance
  final Map<StatisticsFilter, String> filterLabels = {
    StatisticsFilter.daily: 'Day',
    StatisticsFilter.weekly: 'Week',
    StatisticsFilter.monthly: 'Month',
    StatisticsFilter.yearly: 'Year',
    StatisticsFilter.custom: 'Custom',
  };

  final Map<StatisticsFilter, IconData> filterIcons = {
    StatisticsFilter.daily: Icons.today,
    StatisticsFilter.weekly: Icons.calendar_view_week,
    StatisticsFilter.monthly: Icons.calendar_month,
    StatisticsFilter.yearly: Icons.calendar_today,
    StatisticsFilter.custom: Icons.date_range,
  };

  @override
  void initState() {
    super.initState();
    selectedFilter = widget.initialFilter;

    // Initialize custom range if passed
    if (widget.initialStartDate != null && widget.initialEndDate != null) {
      customRange = DateTimeRange(
        start: widget.initialStartDate!,
        end: widget.initialEndDate!,
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Apply filter after build completion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectedFilter != StatisticsFilter.custom) {
        _applyFilter();
      }
    });
  }

  void _applyFilter() {
    final now = DateTime.now();
    DateTime start, end;

    switch (selectedFilter) {
      case StatisticsFilter.daily:
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case StatisticsFilter.weekly:
        start = DateTime(now.year, now.month, now.day - 6);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case StatisticsFilter.monthly:
        start = DateTime(now.year, now.month - 1, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case StatisticsFilter.yearly:
        start = DateTime(now.year - 1, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case StatisticsFilter.custom:
        if (customRange != null) {
          start = customRange!.start;
          end = DateTime(
            customRange!.end.year,
            customRange!.end.month,
            customRange!.end.day,
            23,
            59,
            59,
          );
        } else {
          // Default: Last 7 days
          start = DateTime(now.year, now.month, now.day - 6);
          end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        }
        break;
    }

    widget.onFilterChanged(start, end);
  }

  Future<void> _pickCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: customRange,
      helpText: 'Select Date Range',
      cancelText: 'Cancel',
      confirmText: 'Confirm',
      saveText: 'Save',
      errorFormatText: 'Invalid format',
      errorInvalidText: 'Invalid date',
      errorInvalidRangeText: 'Invalid range',
      fieldStartHintText: 'Start date',
      fieldEndHintText: 'End date',
      fieldStartLabelText: 'From',
      fieldEndLabelText: 'To',
    );

    if (picked != null) {
      setState(() {
        customRange = picked;
        selectedFilter = StatisticsFilter.custom;
      });
      _applyFilter();
    }
  }

  String _getRangeLabel() {
    if (customRange != null) {
      final start = DateFormat('yyyy-MM-dd').format(customRange!.start);
      final end = DateFormat('yyyy-MM-dd').format(customRange!.end);

      final daysDiff = customRange!.end.difference(customRange!.start).inDays;
      return '$start to $end ($daysDiff days)';
    }
    return 'Select custom range';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter Header
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Icon(Icons.filter_alt, size: 20),
              const SizedBox(width: 8),
              Text(
                'Filter Statistics',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // Quick Filter Buttons
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: StatisticsFilter.values.map((filter) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(filterLabels[filter]!),
                  selected: selectedFilter == filter,
                  onSelected: (selected) {
                    setState(() {
                      selectedFilter = filter;
                      if (filter == StatisticsFilter.custom) {
                        _pickCustomRange();
                      } else {
                        _applyFilter();
                      }
                    });
                  },
                  avatar: Icon(filterIcons[filter], size: 18),

                  backgroundColor: Colors.grey.withOpacity(0.1),
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    color: selectedFilter == filter
                        ? Theme.of(context).primaryColor
                        : Colors.grey[700],
                    fontWeight: selectedFilter == filter
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: selectedFilter == filter
                          ? Theme.of(context).primaryColor.withOpacity(0.5)
                          : Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 12),

        // Display Custom Range Selection
        if (selectedFilter == StatisticsFilter.custom)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Custom Range:',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        _getRangeLabel(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: _pickCustomRange,
                  tooltip: 'Edit Range',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

        // Info Text
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getFilterInfo(),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getFilterInfo() {
    switch (selectedFilter) {
      case StatisticsFilter.daily:
        return 'Showing statistics for today';
      case StatisticsFilter.weekly:
        return 'Showing statistics for the last 7 days';
      case StatisticsFilter.monthly:
        return 'Showing statistics for the last month';
      case StatisticsFilter.yearly:
        return 'Showing statistics for the last year';
      case StatisticsFilter.custom:
        if (customRange != null) {
          final days =
              customRange!.end.difference(customRange!.start).inDays + 1;
          return 'Showing statistics for $days days';
        }
        return 'Select a custom date range';
    }
  }
}

/// Compact version of the filter (for small screens)
class CompactStatisticsFilter extends StatelessWidget {
  final Function(DateTime start, DateTime end) onFilterChanged;
  final StatisticsFilter initialFilter;

  const CompactStatisticsFilter({
    super.key,
    required this.onFilterChanged,
    this.initialFilter = StatisticsFilter.weekly,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<StatisticsFilter>(
      onSelected: (filter) {
        final now = DateTime.now();
        DateTime start, end;

        switch (filter) {
          case StatisticsFilter.daily:
            start = DateTime(now.year, now.month, now.day);
            end = DateTime(now.year, now.month, now.day, 23, 59, 59);
            break;
          case StatisticsFilter.weekly:
            start = DateTime(now.year, now.month, now.day - 6);
            end = DateTime(now.year, now.month, now.day, 23, 59, 59);
            break;
          case StatisticsFilter.monthly:
            start = DateTime(now.year, now.month - 1, now.day);
            end = DateTime(now.year, now.month, now.day, 23, 59, 59);
            break;
          case StatisticsFilter.yearly:
            start = DateTime(now.year - 1, now.month, now.day);
            end = DateTime(now.year, now.month, now.day, 23, 59, 59);
            break;
          case StatisticsFilter.custom:
            // Custom not supported in compact version
            return;
        }

        onFilterChanged(start, end);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: StatisticsFilter.daily,
          child: Row(
            children: [
              const Icon(Icons.today, size: 20),
              const SizedBox(width: 8),
              const Text('Today'),
            ],
          ),
        ),
        PopupMenuItem(
          value: StatisticsFilter.weekly,
          child: Row(
            children: [
              const Icon(Icons.calendar_view_week, size: 20),
              const SizedBox(width: 8),
              const Text('Week'),
            ],
          ),
        ),
        PopupMenuItem(
          value: StatisticsFilter.monthly,
          child: Row(
            children: [
              const Icon(Icons.calendar_month, size: 20),
              const SizedBox(width: 8),
              const Text('Month'),
            ],
          ),
        ),
        PopupMenuItem(
          value: StatisticsFilter.yearly,
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 20),
              const SizedBox(width: 8),
              const Text('Year'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_alt, size: 18),
            SizedBox(width: 8),
            Text('Filter'),
          ],
        ),
      ),
    );
  }
}
