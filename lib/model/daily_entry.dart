// ================================================================
// DAILY ENTRY MODEL
// ================================================================
//
// This model represents one day's financial entry in Mass Ledger.
//
// ResultType:
//   profit      -> Money was gained
//   loss        -> Money was lost
//   noMovement  -> No profit or loss
//
// ================================================================

enum ResultType {
  profit,
  loss,
  noMovement,
}

// ================================================================
// DAILY ENTRY
// ================================================================

class DailyEntry {
  // ==============================================================
  // VARIABLES
  // ==============================================================

  final String id;

  final DateTime date;

  final ResultType type;

  final double amount;

  final String note;

  final DateTime updatedAt;

  // ==============================================================
  // CONSTRUCTOR
  // ==============================================================

  const DailyEntry({
    required this.id,
    required this.date,
    required this.type,
    required this.amount,
    this.note = '',
    required this.updatedAt,
  });

  // ==============================================================
  // SIGNED AMOUNT
  // ==============================================================
  //
  // Profit      -> positive amount
  // Loss        -> negative amount
  // No Movement -> 0
  //
  // Example:
  //
  // Profit 500  -> +500
  // Loss 200    -> -200
  // No movement -> 0
  //
  // ==============================================================

  double get signedAmount {
    switch (type) {
      case ResultType.profit:
        return amount.abs();

      case ResultType.loss:
        return -amount.abs();

      case ResultType.noMovement:
        return 0;
    }
  }

  // ==============================================================
  // COPY WITH
  // ==============================================================
  //
  // Used when editing an existing entry.
  //
  // Only the values supplied to copyWith() will change.
  //
  // Example:
  //
  // entry.copyWith(
  //   amount: 500,
  //   type: ResultType.profit,
  // );
  //
  // ==============================================================

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

  // ==============================================================
  // TO MAP
  // ==============================================================
  //
  // This converts the model into a Map.
  //
  // It will be useful when saving the entry to Supabase.
  //
  // ==============================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type.name,
      'amount': amount,
      'note': note,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ==============================================================
  // FROM MAP
  // ==============================================================
  //
  // This converts Supabase data back into a DailyEntry object.
  //
  // ==============================================================

  factory DailyEntry.fromMap(Map<String, dynamic> map) {
    return DailyEntry(
      id: map['id']?.toString() ?? '',
      date: DateTime.parse(
        map['date'].toString(),
      ),
      type: ResultType.values.firstWhere(
        (value) => value.name == map['type'].toString(),
        orElse: () => ResultType.noMovement,
      ),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      note: map['note']?.toString() ?? '',
      updatedAt: DateTime.parse(
        map['updated_at'].toString(),
      ),
    );
  }
}