import 'package:flutter/material.dart';
import 'package:mass_ledger/ViewModel/ledger_viewmodel.dart';
import 'package:mass_ledger/model/daily_entry.dart';
import 'package:provider/provider.dart';

class WeekOverviewScreen extends StatelessWidget {
  const WeekOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LedgerViewModel>();

    final selectedDate = vm.selectedDate;

    final monday = selectedDate.subtract(
      Duration(
        days: selectedDate.weekday - 1,
      ),
    );

    final sunday = monday.add(
      const Duration(days: 6),
    );

    final entries = vm.entriesForWeek(
      selectedDate,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),

        title: Text(
          'Week ${_weekNumber(monday)}',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          const Icon(
            Icons.keyboard_arrow_down,
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(14),

        children: [
          // ==================================================
          // WEEK RANGE
          // ==================================================

          Text(
            '${monday.day} – ${sunday.day} '
            '${shortMonth(sunday)} '
            '${sunday.year}',

            style: const TextStyle(
              color: Colors.black54,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          // ==================================================
          // TOTAL
          // ==================================================

          Container(
            padding:
                const EdgeInsets.all(15),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(12),

              border: Border.all(
                color: Colors.grey,
              ),
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  'Total Profit',

                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  money(
                    vm.totalForWeek(
                      selectedDate,
                    ),
                  ),

                  style:
                      const TextStyle(
                    color: Colors.green,

                    fontWeight:
                        FontWeight.bold,

                    fontSize: 21,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          // ==================================================
          // DAYS
          // ==================================================

          for (int i = 0; i < 7; i++)
            _WeekDayRow(
              date: monday.add(
                Duration(days: i),
              ),

              entry: _findEntry(
                entries,

                monday.add(
                  Duration(days: i),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // FIND ENTRY FOR DATE
  // ==========================================================

  DailyEntry? _findEntry(
    List<DailyEntry> entries,
    DateTime date,
  ) {
    for (final entry in entries) {
      if (entry.date.year == date.year &&
          entry.date.month == date.month &&
          entry.date.day == date.day) {
        return entry;
      }
    }

    return null;
  }

  // ==========================================================
  // WEEK NUMBER
  // ==========================================================

  int _weekNumber(DateTime date) {
    final firstDay =
        DateTime(date.year, 1, 1);

    return ((date
                    .difference(firstDay)
                    .inDays +
                firstDay.weekday -
                1) /
            7)
        .floor() +
        1;
  }
}

// ============================================================
// WEEK DAY ROW
// ============================================================

class _WeekDayRow extends StatelessWidget {
  final DateTime date;

  final DailyEntry? entry;

  const _WeekDayRow({
    required this.date,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final amount =
        entry?.signedAmount ?? 0;

    final color = entry == null
        ? Colors.black45
        : typeColor(entry!.type);

    String amountText;

    if (amount < 0) {
      amountText =
          '-R ${amount.abs().toStringAsFixed(2)}';
    } else {
      amountText =
          'R ${amount.toStringAsFixed(2)}';
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 5,
      ),

      decoration:
          const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
          ),
        ),
      ),

      child: Row(
        children: [
          Expanded(
            child: Text(
              '${dayName(date)}, '
              '${date.day} '
              '${shortMonth(date)}',

              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

          Text(
            amountText,

            style: TextStyle(
              color: color,

              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SHORT MONTH
// ============================================================
//
// Example:
// January  -> Jan
// February -> Feb
// August   -> Aug
//
// ============================================================

String shortMonth(
  DateTime date,
) {
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
//
// Example:
// Monday    -> Monday
// Tuesday   -> Tuesday
// Wednesday -> Wednesday
//
// ============================================================

String dayName(
  DateTime date,
) {
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
//
// Example:
// 100       -> R 100.00
// 1250.50   -> R 1250.50
//
// ============================================================

String money(
  num amount,
) {
  return 'R ${amount.toStringAsFixed(2)}';
}

// ============================================================
// RESULT TYPE COLOR
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