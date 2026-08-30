import 'package:flutter/material.dart';
import 'package:mass_ledger/model/daily_entry.dart';

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
// SHORT MONTH
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
// FULL DATE
// ============================================================

String fullDate(DateTime date) {
  return '${date.day} ${monthName(date)} ${date.year}';
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

String money(num amount) {
  if (amount < 0) {
    return '-R ${amount.abs().toStringAsFixed(2)}';
  }

  return 'R ${amount.toStringAsFixed(2)}';
}

// ============================================================
// RESULT TYPE COLOR
// ============================================================

Color typeColor(ResultType type) {
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
// RESULT TYPE ICON
// ============================================================

IconData typeIcon(ResultType type) {
  switch (type) {
    case ResultType.profit:
      return Icons.trending_up;

    case ResultType.loss:
      return Icons.trending_down;

    case ResultType.noMovement:
      return Icons.remove;
  }
}

// ============================================================
// RESULT TYPE LABEL
// ============================================================

String typeLabel(ResultType type) {
  switch (type) {
    case ResultType.profit:
      return 'Profit';

    case ResultType.loss:
      return 'Loss';

    case ResultType.noMovement:
      return 'No Movement';
  }
}