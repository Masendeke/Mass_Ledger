enum ResultType {
  profit,
  loss,
  noMovement,
}

class DailyEntry {
  final String id;
  final DateTime date;
  final ResultType type;
  final double amount;
  final String note;
  final DateTime updatedAt;

  const DailyEntry({
    required this.id,
    required this.date,
    required this.type,
    required this.amount,
    this.note = '',
    required this.updatedAt,
  });

  double get signedAmount {
    if (type == ResultType.loss) {
      return -amount.abs();
    }

    if (type == ResultType.noMovement) {
      return 0;
    }

    return amount.abs();
  }

  DailyEntry copyWith({
    DateTime? date,
    ResultType? type,
    double? amount,
    String? note,
    DateTime? updatedAt,
  }) {
    return DailyEntry(
      id: id,
      date: date ?? this.date,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}