import 'package:flutter/foundation.dart';
import 'package:mass_ledger/model/daily_entry.dart';
import 'package:mass_ledger/model/user_profile.dart';

class LedgerViewModel extends ChangeNotifier {
  LedgerViewModel();

  // ============================================================
  // DATA
  // ============================================================

  final List<DailyEntry> _entries = [];

  // ============================================================
  // USER PROFILE
  // ============================================================

  UserProfile _profile = const UserProfile(
    name: 'John Doe',
    email: 'john@example.com',
    currency: 'South African Rand (R)',
  );

  // ============================================================
  // DATES
  // ============================================================

  DateTime _selectedDate = DateTime.now();

  DateTime _visibleMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  // ============================================================
  // GETTERS
  // ============================================================

  List<DailyEntry> get entries => List.unmodifiable(_entries);

  UserProfile get profile => _profile;

  DateTime get selectedDate => _selectedDate;

  DateTime get visibleMonth => _visibleMonth;

  // ============================================================
  // TOTAL PROFIT
  // ============================================================

  double get totalProfit {
    return _entries
        .where(
          (entry) => entry.type == ResultType.profit,
        )
        .fold(
          0.0,
          (sum, entry) => sum + entry.amount,
        );
  }

  // ============================================================
  // TOTAL LOSS
  // ============================================================

  double get totalLoss {
    return _entries
        .where(
          (entry) => entry.type == ResultType.loss,
        )
        .fold(
          0.0,
          (sum, entry) => sum + entry.amount,
        );
  }

  // ============================================================
  // NET RESULT
  // ============================================================

  double get netResult {
    return totalProfit - totalLoss;
  }

  // ============================================================
  // FIRST ENTRY DATE
  // ============================================================

  DateTime? get firstEntryDate {
    if (_entries.isEmpty) {
      return null;
    }

    DateTime first = _entries.first.date;

    for (final entry in _entries) {
      if (_dateOnly(entry.date).isBefore(
        _dateOnly(first),
      )) {
        first = entry.date;
      }
    }

    return _dateOnly(first);
  }

  // ============================================================
  // LATEST ENTRY DATE
  // ============================================================

  DateTime? get latestEntryDate {
    if (_entries.isEmpty) {
      return null;
    }

    DateTime latest = _entries.first.date;

    for (final entry in _entries) {
      if (_dateOnly(entry.date).isAfter(
        _dateOnly(latest),
      )) {
        latest = entry.date;
      }
    }

    return _dateOnly(latest);
  }

  // ============================================================
  // FIND ENTRY
  // ============================================================

  DailyEntry? entryFor(DateTime date) {
    for (final entry in _entries) {
      if (_sameDay(entry.date, date)) {
        return entry;
      }
    }

    return null;
  }

  // ============================================================
  // WHETHER TRACKING HAS STARTED
  // ============================================================

  bool hasStarted(DateTime date) {
    final first = firstEntryDate;

    if (first == null) {
      return false;
    }

    return !_dateOnly(date).isBefore(first);
  }

  // ============================================================
  // WHETHER DATE IS WITHIN TRACKING PERIOD
  // ============================================================

  bool isWithinTrackingPeriod(DateTime date) {
    final first = firstEntryDate;
    final latest = latestEntryDate;

    if (first == null || latest == null) {
      return false;
    }

    final cleanDate = _dateOnly(date);

    return !cleanDate.isBefore(first) &&
        !cleanDate.isAfter(latest);
  }

  // ============================================================
  // SELECT DATE
  // ============================================================

  void selectDate(DateTime date) {
    _selectedDate = _dateOnly(date);

    _visibleMonth = DateTime(
      date.year,
      date.month,
      1,
    );

    notifyListeners();
  }

  // ============================================================
  // CHANGE MONTH
  // ============================================================

  void changeMonth(int delta) {
    _visibleMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + delta,
      1,
    );

    notifyListeners();
  }

  // ============================================================
  // SET VISIBLE MONTH
  // ============================================================

  void setVisibleMonth(DateTime month) {
    _visibleMonth = DateTime(
      month.year,
      month.month,
      1,
    );

    notifyListeners();
  }

  // ============================================================
  // SET MONTH
  // ============================================================

  void setMonth(DateTime month) {
    setVisibleMonth(month);
  }

  // ============================================================
  // AUTOMATIC RESULT CALCULATION
  // ============================================================

  ResultType calculateResultType(
    DateTime date,
    double amount,
  ) {
    final previousAmount = _previousAmountBefore(date);

    if (previousAmount == null) {
      return ResultType.profit;
    }

    if (amount > previousAmount) {
      return ResultType.profit;
    }

    if (amount < previousAmount) {
      return ResultType.loss;
    }

    return ResultType.noMovement;
  }

  // ============================================================
  // PREVIOUS AMOUNT
  // ============================================================

  double? _previousAmountBefore(
    DateTime date,
  ) {
    final previousEntries = _entries
        .where(
          (entry) => _dateOnly(entry.date).isBefore(
            _dateOnly(date),
          ),
        )
        .toList()
      ..sort(
        (a, b) => b.date.compareTo(a.date),
      );

    if (previousEntries.isEmpty) {
      return null;
    }

    return previousEntries.first.amount;
  }

  // ============================================================
  // SAVE ENTRY AUTOMATICALLY
  // ============================================================

  void saveEntryAutomatically({
    required DateTime date,
    required double amount,
    required String note,
  }) {
    if (amount < 0) {
      amount = amount.abs();
    }

    final cleanDate = _dateOnly(date);

    final existingIndex = _entries.indexWhere(
      (entry) => _sameDay(entry.date, cleanDate),
    );

    final type = calculateResultType(
      cleanDate,
      amount,
    );

    final entry = DailyEntry(
      id: existingIndex >= 0
          ? _entries[existingIndex].id
          : DateTime.now()
              .microsecondsSinceEpoch
              .toString(),
      date: cleanDate,
      type: type,
      amount: amount,
      note: note.trim(),
      updatedAt: DateTime.now(),
    );

    if (existingIndex >= 0) {
      _entries[existingIndex] = entry;
    } else {
      _entries.add(entry);
    }

    // Recalculate all entries after adding/editing.
    _recalculateAllEntries();

    // Keep the edited date selected.
    _selectedDate = cleanDate;

    // Show the month containing the edited date.
    _visibleMonth = DateTime(
      cleanDate.year,
      cleanDate.month,
      1,
    );

    notifyListeners();
  }

  // ============================================================
  // RECALCULATE ALL ENTRIES
  // ============================================================

  void _recalculateAllEntries() {
    _entries.sort(
      (a, b) => a.date.compareTo(b.date),
    );

    double? previousAmount;

    for (int i = 0; i < _entries.length; i++) {
      final oldEntry = _entries[i];

      ResultType type;

      if (previousAmount == null) {
        type = ResultType.profit;
      } else if (oldEntry.amount > previousAmount) {
        type = ResultType.profit;
      } else if (oldEntry.amount < previousAmount) {
        type = ResultType.loss;
      } else {
        type = ResultType.noMovement;
      }

      _entries[i] = DailyEntry(
        id: oldEntry.id,
        date: oldEntry.date,
        type: type,
        amount: oldEntry.amount,
        note: oldEntry.note,
        updatedAt: oldEntry.updatedAt,
      );

      previousAmount = oldEntry.amount;
    }
  }

  // ============================================================
  // OLD SAVE METHOD
  // ============================================================

  void saveEntry({
    required DateTime date,
    required ResultType type,
    required double amount,
    required String note,
  }) {
    saveEntryAutomatically(
      date: date,
      amount: amount,
      note: note,
    );
  }

  // ============================================================
  // DELETE ENTRY
  // ============================================================

  void deleteEntry(DateTime date) {
    _entries.removeWhere(
      (entry) => _sameDay(entry.date, date),
    );

    _recalculateAllEntries();

    notifyListeners();
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================

  void updateProfile({
    String? name,
    String? email,
    String? currency,
  }) {
    _profile = _profile.copyWith(
      name: name,
      email: email,
      currency: currency,
    );

    notifyListeners();
  }

  // ============================================================
  // MONTH ENTRIES
  // ============================================================

  List<DailyEntry> entriesForMonth(
    DateTime month,
  ) {
    return _entries
        .where(
          (entry) =>
              entry.date.year == month.year &&
              entry.date.month == month.month,
        )
        .toList()
      ..sort(
        (a, b) => a.date.compareTo(b.date),
      );
  }

  // ============================================================
  // MONTH TOTAL
  // ============================================================

  double totalForMonth(
    DateTime month,
  ) {
    return entriesForMonth(month).fold(
      0.0,
      (sum, entry) => sum + entry.signedAmount,
    );
  }

  // ============================================================
  // MONTH PROFIT
  // ============================================================

  double profitForMonth(
    DateTime month,
  ) {
    return entriesForMonth(month)
        .where(
          (entry) => entry.type == ResultType.profit,
        )
        .fold(
          0.0,
          (sum, entry) => sum + entry.amount,
        );
  }

  // ============================================================
  // MONTH LOSS
  // ============================================================

  double lossForMonth(
    DateTime month,
  ) {
    return entriesForMonth(month)
        .where(
          (entry) => entry.type == ResultType.loss,
        )
        .fold(
          0.0,
          (sum, entry) => sum + entry.amount,
        );
  }

  // ============================================================
  // NO MOVEMENT COUNT
  // ============================================================

  int noMovementCount(
    DateTime month,
  ) {
    return entriesForMonth(month)
        .where(
          (entry) =>
              entry.type == ResultType.noMovement,
        )
        .length;
  }

  // ============================================================
  // SKIPPED-DATE COUNT
  // ============================================================

  int skippedDaysCount(
    DateTime month,
  ) {
    final first = firstEntryDate;
    final latest = latestEntryDate;

    if (first == null || latest == null) {
      return 0;
    }

    int count = 0;

    DateTime current = first;

    while (!current.isAfter(latest)) {
      if (current.year == month.year &&
          current.month == month.month) {
        if (entryFor(current) == null) {
          count++;
        }
      }

      current = current.add(
        const Duration(days: 1),
      );
    }

    return count;
  }

  // ============================================================
  // TOTAL NO MOVEMENT COUNT
  // ============================================================

  int totalNoMovementCount(
    DateTime month,
  ) {
    return noMovementCount(month) +
        skippedDaysCount(month);
  }

  // ============================================================
  // WEEK ENTRIES
  // ============================================================

  List<DailyEntry> entriesForWeek(
    DateTime date,
  ) {
    final monday = date.subtract(
      Duration(days: date.weekday - 1),
    );

    final sunday = monday.add(
      const Duration(days: 6),
    );

    return _entries
        .where(
          (entry) =>
              !_dateOnly(entry.date).isBefore(
                _dateOnly(monday),
              ) &&
              !_dateOnly(entry.date).isAfter(
                _dateOnly(sunday),
              ),
        )
        .toList()
      ..sort(
        (a, b) => a.date.compareTo(b.date),
      );
  }

  // ============================================================
  // WEEK TOTAL
  // ============================================================

  double totalForWeek(
    DateTime date,
  ) {
    return entriesForWeek(date).fold(
      0.0,
      (sum, entry) => sum + entry.signedAmount,
    );
  }

  // ============================================================
  // WEEKLY TOTALS
  // ============================================================

  Map<String, double> weeklyTotals(
    DateTime month,
  ) {
    final result = <String, double>{};

    for (int week = 0; week < 5; week++) {
      final start = DateTime(
        month.year,
        month.month,
        1 + week * 7,
      );

      final end = DateTime(
        month.year,
        month.month,
        7 + week * 7,
      );

      final total = _entries
          .where(
            (entry) =>
                !entry.date.isBefore(start) &&
                !entry.date.isAfter(end),
          )
          .fold(
            0.0,
            (sum, entry) =>
                sum + entry.signedAmount,
          );

      result['Week ${week + 1}'] = total;
    }

    return result;
  }

  // ============================================================
  // RECENT ENTRIES
  // ============================================================

  List<DailyEntry> recentEntries() {
    return _entries.toList()
      ..sort(
        (a, b) => b.date.compareTo(a.date),
      );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  List<DailyEntry> searchEntries(
    String query,
  ) {
    final search = query.trim().toLowerCase();

    if (search.isEmpty) {
      return recentEntries();
    }

    return _entries.where((entry) {
      final date = entry.date;

      final dateFormats = [
        '${date.day}',
        '${date.month}',
        '${date.year}',
        '${date.day}/${date.month}/${date.year}',
        '${date.day}-${date.month}-${date.year}',
        _monthName(date.month),
        _monthName(date.month).substring(0, 3),
        _dayName(date.weekday),
        _dayName(date.weekday).substring(0, 3),
      ];

      final dateText = dateFormats.join(' ');

      final note = entry.note.toLowerCase();

      final amount = entry.amount
          .toStringAsFixed(2)
          .toLowerCase();

      final type =
          _typeLabel(entry.type).toLowerCase();

      final signedAmount = entry.signedAmount
          .toStringAsFixed(2)
          .toLowerCase();

      return dateText.contains(search) ||
          note.contains(search) ||
          amount.contains(search) ||
          signedAmount.contains(search) ||
          type.contains(search);
    }).toList()
      ..sort(
        (a, b) => b.date.compareTo(a.date),
      );
  }

  // ============================================================
  // DATE STATUS
  // ============================================================

  ResultType? statusForDate(
    DateTime date,
  ) {
    final first = firstEntryDate;
    final latest = latestEntryDate;

    // No entries yet.
    if (first == null || latest == null) {
      return null;
    }

    final cleanDate = _dateOnly(date);

    // Before tracking started.
    if (cleanDate.isBefore(first)) {
      return null;
    }

    // After the latest recorded entry.
    if (cleanDate.isAfter(latest)) {
      return null;
    }

    // Actual entry.
    final entry = entryFor(cleanDate);

    if (entry != null) {
      return entry.type;
    }

    // Missing date between first and latest entry.
    return ResultType.noMovement;
  }

  // ============================================================
  // CALENDAR TYPE
  // ============================================================

  ResultType? calendarTypeFor(
    DateTime date,
  ) {
    return statusForDate(date);
  }

  // ============================================================
  // DISPLAY AMOUNT FOR DATE
  // ============================================================

  String amountForDate(
    DateTime date,
  ) {
    final entry = entryFor(date);

    if (entry == null) {
      return '';
    }

    return entry.amount.toStringAsFixed(2);
  }

  // ============================================================
  // SAME DAY
  // ============================================================

  static bool _sameDay(
    DateTime a,
    DateTime b,
  ) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  // ============================================================
  // DATE ONLY
  // ============================================================

  static DateTime _dateOnly(
    DateTime date,
  ) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  // ============================================================
  // MONTH NAME
  // ============================================================

  static String _monthName(
    int month,
  ) {
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

    return months[month - 1];
  }

  // ============================================================
  // DAY NAME
  // ============================================================

  static String _dayName(
    int weekday,
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

    return days[weekday - 1];
  }

  // ============================================================
  // TYPE LABEL
  // ============================================================

  static String _typeLabel(
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
}