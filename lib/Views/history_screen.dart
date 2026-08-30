import 'package:flutter/material.dart';
import 'package:mass_ledger/ViewModel/ledger_viewmodel.dart';
import 'package:mass_ledger/model/daily_entry.dart';
import 'package:provider/provider.dart';

import 'date_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() =>
      _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LedgerViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${monthName(vm.visibleMonth)} '
          '${vm.visibleMonth.year}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              vm.changeMonth(-1);
            },
            icon: const Icon(
              Icons.chevron_left,
            ),
          ),

          IconButton(
            onPressed: () {
              vm.changeMonth(1);
            },
            icon: const Icon(
              Icons.chevron_right,
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ==================================================
          // TABS
          // ==================================================

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
            ),

            child: SizedBox(
              width: double.infinity,

              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment<int>(
                    value: 0,
                    label: Text(
                      'Month',
                    ),
                  ),

                  ButtonSegment<int>(
                    value: 1,
                    label: Text(
                      'Week',
                    ),
                  ),

                  ButtonSegment<int>(
                    value: 2,
                    label: Text(
                      'List',
                    ),
                  ),
                ],

                selected: {
                  selectedTab,
                },

                onSelectionChanged: (selection) {
                  setState(() {
                    selectedTab = selection.first;
                  });
                },
              ),
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Expanded(
            child: _buildTab(
              context,
              vm,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    LedgerViewModel vm,
  ) {
    switch (selectedTab) {
      case 0:
        return _MonthlyHistory(
          vm: vm,
        );

      case 1:
        return _WeeklyHistory(
          vm: vm,
        );

      case 2:
        return const _HistoryList();

      default:
        return const SizedBox();
    }
  }
}

// ============================================================
// MONTHLY HISTORY
// ============================================================

class _MonthlyHistory extends StatelessWidget {
  final LedgerViewModel vm;

  const _MonthlyHistory({
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final month = vm.visibleMonth;

    final weeks = vm.weeklyTotals(
      month,
    );

    return ListView(
      padding: const EdgeInsets.all(14),

      children: [
        _TotalBox(
          title: 'Total Profit',
          amount: vm.totalForMonth(
            month,
          ),
        ),

        const SizedBox(
          height: 15,
        ),

        const Text(
          'Weekly Breakdown',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 7,
        ),

        for (final week in weeks.entries)
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 4,
            ),

            title: Text(
              week.key,
            ),

            subtitle: Text(
              _weekRange(
                month,
                week.key,
              ),
            ),

            trailing: Text(
              week.value == 0
                  ? '—'
                  : money(
                      week.value,
                    ),

              style: TextStyle(
                color: week.value < 0
                    ? const Color.fromARGB(
                        255,
                        236,
                        45,
                        45,
                      )
                    : Colors.green,

                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  String _weekRange(
    DateTime month,
    String weekName,
  ) {
    final number = int.parse(
      weekName.split(' ').last,
    );

    final start = DateTime(
      month.year,
      month.month,
      1 + ((number - 1) * 7),
    );

    final end = DateTime(
      month.year,
      month.month,
      7 + ((number - 1) * 7),
    );

    return '${start.day} – '
        '${end.day} '
        '${shortMonth(end)}';
  }
}

// ============================================================
// WEEKLY HISTORY
// ============================================================

class _WeeklyHistory extends StatelessWidget {
  final LedgerViewModel vm;

  const _WeeklyHistory({
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final entries = vm.entriesForWeek(
      vm.selectedDate,
    );

    return ListView(
      padding: const EdgeInsets.all(14),

      children: [
        _TotalBox(
          title: 'Total Profit',
          amount: vm.totalForWeek(
            vm.selectedDate,
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        if (entries.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'No entries for this week.',
              ),
            ),
          ),

        for (final entry in entries)
          ListTile(
            title: Text(
              '${dayName(entry.date)}, '
              '${entry.date.day} '
              '${shortMonth(entry.date)}',
            ),

            trailing: Text(
              _displayAmount(entry),

              style: TextStyle(
                color: typeColor(
                  entry.type,
                ),

                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  String _displayAmount(
    DailyEntry entry,
  ) {
    if (entry.type == ResultType.loss) {
      return '-R ${entry.amount.toStringAsFixed(2)}';
    }

    return 'R ${entry.amount.toStringAsFixed(2)}';
  }
}

// ============================================================
// LIST HISTORY
// ============================================================

class _HistoryList extends StatelessWidget {
  const _HistoryList();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LedgerViewModel>();

    final entries = vm.recentEntries();

    if (entries.isEmpty) {
      return const Center(
        child: Text(
          'No history available.',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(14),

      itemCount: entries.length,

      itemBuilder: (
        context,
        index,
      ) {
        final entry = entries[index];

        return ListTile(
          onTap: () {
            vm.selectDate(
              entry.date,
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const DateDetailScreen(),
              ),
            );
          },

          leading: CircleAvatar(
            backgroundColor: typeColor(
              entry.type,
            ).withValues(
              alpha: .12,
            ),

            child: Text(
              '${entry.date.day}',

              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          title: Row(
            children: [
              Text(
                dayName(entry.date),
              ),

              const SizedBox(
                width: 8,
              ),

              Container(
                width: 8,
                height: 8,

                decoration: BoxDecoration(
                  color: typeColor(
                    entry.type,
                  ),

                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(
                width: 6,
              ),

              Text(
                typeLabel(
                  entry.type,
                ),
              ),
            ],
          ),

          subtitle: Text(
            '${entry.date.day} '
            '${shortMonth(entry.date)} '
            '${entry.date.year}',
          ),

          trailing: Text(
            entry.signedAmount < 0
                ? '-R ${entry.amount.toStringAsFixed(2)}'
                : 'R ${entry.amount.toStringAsFixed(2)}',

            style: TextStyle(
              color: typeColor(
                entry.type,
              ),

              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// TOTAL BOX
// ============================================================

class _TotalBox extends StatelessWidget {
  final String title;

  final double amount;

  const _TotalBox({
    required this.title,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(
          12,
        ),

        border: Border.all(
          color: Colors.grey,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            title,

            style: const TextStyle(
              fontSize: 12,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            money(amount),

            style: TextStyle(
              color: amount < 0
                  ? const Color.fromARGB(
                      255,
                      236,
                      45,
                      45,
                    )
                  : Colors.green,

              fontWeight: FontWeight.bold,

              fontSize: 21,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SHARED HISTORY HELPERS
// ============================================================
//
// These functions are outside the individual widgets so that
// every history widget can use them.
//
// ============================================================

// ============================================================
// MONTH NAME
// ============================================================

String monthName(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return months[date.month - 1];
}

// ============================================================
// SHORT MONTH NAME
// ============================================================

String shortMonth(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return months[date.month - 1];
}

// ============================================================
// DAY NAME
// ============================================================

String dayName(DateTime date) {
  const days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  return days[date.weekday - 1];
}

// ============================================================
// MONEY FORMAT
// ============================================================

String money(double amount) {
  final prefix = amount < 0 ? '-R ' : 'R ';

  return '$prefix'
      '${amount.abs().toStringAsFixed(2)}';
}

// ============================================================
// TYPE COLOR
// ============================================================

Color typeColor(
  ResultType type,
) {
  switch (type) {
    case ResultType.profit:
      return Colors.green;

    case ResultType.loss:
      return const Color.fromARGB(
        255,
        236,
        45,
        45,
      );

    case ResultType.noMovement:
      return Colors.deepOrange;
  }
}

// ============================================================
// TYPE LABEL
// ============================================================

String typeLabel(
  ResultType type,
) {
  switch (type) {
    case ResultType.profit:
      return 'Profit';

    case ResultType.loss:
      return 'Loss';

    case ResultType.noMovement:
      return 'No Movement';
  }
}