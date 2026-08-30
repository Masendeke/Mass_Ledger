class LedgerEntry {
  final String id;
  final DateTime date;
  final String title;
  final String description;
  final double amount;
  final EntryType type;
  final String category;

  LedgerEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
  });

  bool get isIncome => type == EntryType.income;

  bool get isExpense => type == EntryType.expense;

  double get signedAmount {
    return isIncome ? amount : -amount;
  }
}

enum EntryType {
  income,
  expense,
}