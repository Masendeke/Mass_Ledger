import 'package:flutter/material.dart';
import 'package:mass_ledger/ViewModel/ledger_viewmodel.dart';
import 'package:mass_ledger/model/daily_entry.dart';
import 'package:mass_ledger/utils/ledger_helper.dart' as helper;
import 'package:provider/provider.dart';

import 'add_edit_screen.dart';

class DateDetailScreen extends StatelessWidget {
  const DateDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LedgerViewModel>();

    final date = vm.selectedDate;

    final entry = vm.entryFor(date);

    return Scaffold(
      // ========================================================
      // APP BAR
      // ========================================================

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
          helper.fullDate(date),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: Padding(
        padding: const EdgeInsets.all(14),

        child: entry == null
            ? _emptyState(context)
            : _entryDetails(
                context,
                vm,
                entry,
              ),
      ),
    );
  }

  // ==========================================================
  // EMPTY STATE
  // ==========================================================

  Widget _emptyState(
    BuildContext context,
  ) {
    return Center(
      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.all(25),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(14),

          border: Border.all(
            color: Colors.grey,
          ),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            // ==================================================
            // ICON
            // ==================================================

            const Icon(
              Icons.event_busy_outlined,
              size: 45,
              color: Colors.black45,
            ),

            const SizedBox(height: 12),

            // ==================================================
            // MESSAGE
            // ==================================================

            const Text(
              'No entry for this day',

              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // ADD ENTRY BUTTON
            // ==================================================

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AddEditScreen(),
                    ),
                  );
                },

                icon: const Icon(
                  Icons.add,
                ),

                label: const Text(
                  'Add Entry',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ENTRY DETAILS
  // ==========================================================

  Widget _entryDetails(
    BuildContext context,
    LedgerViewModel vm,
    DailyEntry entry,
  ) {
    return Column(
      children: [
        // ====================================================
        // DAILY RESULT CARD
        // ====================================================

        Container(
          width: double.infinity,

          padding: const EdgeInsets.all(17),

          decoration: BoxDecoration(
            color: _typeColor(entry.type),

            borderRadius: BorderRadius.circular(14),
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // ==============================================
              // TITLE + TYPE
              // ==============================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [
                  const Text(
                    'Daily Result',

                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: 0.2,
                      ),

                      borderRadius:
                          BorderRadius.circular(20),
                    ),

                    child: Text(
                      _typeLabel(entry.type),

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ==============================================
              // AMOUNT
              // ==============================================

              Text(
                _displayAmount(entry),

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 7),

              // ==============================================
              // NOTE
              // ==============================================

              Text(
                entry.note.isEmpty
                    ? 'Tap to add note'
                    : entry.note,

                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        // ====================================================
        // DETAILS
        // ====================================================

        _DetailRow(
          icon: Icons.sell_outlined,
          title: 'Type',
          value: _typeLabel(entry.type),
          valueColor: _typeColor(entry.type),
        ),

        _DetailRow(
          icon: Icons.payments_outlined,
          title: 'Amount',
          value: _displayAmount(entry),
        ),

        _DetailRow(
          icon: Icons.notes_outlined,
          title: 'Note',
          value: entry.note.isEmpty
              ? '—'
              : entry.note,
        ),

        _DetailRow(
          icon: Icons.access_time,
          title: 'Updated',
          value:
              '${entry.updatedAt.day} '
              '${_shortMonth(entry.updatedAt)} '
              '${entry.updatedAt.year}, '
              '${entry.updatedAt.hour.toString().padLeft(2, '0')}:'
              '${entry.updatedAt.minute.toString().padLeft(2, '0')}',
        ),

        const Spacer(),

        // ====================================================
        // EDIT / DELETE
        // ====================================================

        Row(
          children: [
            // ================================================
            // EDIT
            // ================================================

            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AddEditScreen(),
                    ),
                  );
                },

                child: const Text(
                  'Edit',
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ================================================
            // DELETE
            // ================================================

            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      const Color.fromARGB(
                    255,
                    236,
                    45,
                    45,
                  ),
                ),

                onPressed: () {
                  _deleteEntry(
                    context,
                    vm,
                    entry,
                  );
                },

                child: const Text(
                  'Delete',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // DISPLAY AMOUNT
  // ==========================================================

  String _displayAmount(
    DailyEntry entry,
  ) {
    if (entry.type == ResultType.loss) {
      return '-R ${entry.amount.toStringAsFixed(2)}';
    }

    if (entry.type ==
        ResultType.noMovement) {
      return 'R 0.00';
    }

    return 'R ${entry.amount.toStringAsFixed(2)}';
  }

  // ==========================================================
  // DELETE ENTRY
  // ==========================================================

  void _deleteEntry(
    BuildContext context,
    LedgerViewModel vm,
    DailyEntry entry,
  ) {
    showDialog(
      context: context,

      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Delete Entry?',
          ),

          content: const Text(
            'Are you sure you want to delete this entry?',
          ),

          actions: [
            // ================================================
            // CANCEL
            // ================================================

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                'Cancel',
              ),
            ),

            // ================================================
            // DELETE
            // ================================================

            TextButton(
              style: TextButton.styleFrom(
                foregroundColor:
                    const Color.fromARGB(
                  255,
                  236,
                  45,
                  45,
                ),
              ),

              onPressed: () {
                vm.deleteEntry(
                  entry.date,
                );

                // Close dialog.
                Navigator.pop(context);

                // Return to calendar.
                Navigator.pop(context);
              },

              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// DETAIL ROW
// ============================================================

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),

      child: Row(
        children: [
          // ==================================================
          // ICON
          // ==================================================

          Icon(
            icon,
            size: 21,
            color: Colors.black54,
          ),

          const SizedBox(
            width: 12,
          ),

          // ==================================================
          // TITLE
          // ==================================================

          Text(
            title,

            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          // ==================================================
          // VALUE
          // ==================================================

          Flexible(
            child: Text(
              value,

              textAlign: TextAlign.right,

              style: TextStyle(
                color:
                    valueColor ??
                    Colors.black87,

                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TYPE COLOR
// ============================================================

Color _typeColor(
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

String _typeLabel(
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

// ============================================================
// SHORT MONTH
// ============================================================

String _shortMonth(
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