import 'package:flutter/material.dart';
import 'package:mass_ledger/ViewModel/ledger_viewmodel.dart';

import 'package:provider/provider.dart';

class AddEditScreen extends StatefulWidget {
  const AddEditScreen({super.key});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  late DateTime selectedDate;

  final amountController = TextEditingController();
  final noteController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final vm = context.read<LedgerViewModel>();

    selectedDate = vm.selectedDate;

    final existing = vm.entryFor(selectedDate);

    if (existing != null) {
      amountController.text =
          existing.amount.toStringAsFixed(2);

      noteController.text = existing.note;
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LedgerViewModel>();

    final existing = vm.entryFor(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          existing == null ? 'Add Update' : 'Edit Update',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Save',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              'Select Date',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  suffixIcon: Icon(
                    Icons.calendar_month,
                  ),
                ),
                child: Text(
                  fullDate(selectedDate),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Amount (R)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                prefixText: 'R ',
                hintText: 'Enter amount',
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Note (Optional)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: noteController,
              maxLines: 4,
              maxLength: 100,
              decoration: const InputDecoration(
                hintText: 'Add a note...',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      selectedDate = result;
    });

    final vm = context.read<LedgerViewModel>();

    final existing = vm.entryFor(result);

    if (existing != null) {
      setState(() {
        amountController.text =
            existing.amount.toStringAsFixed(2);

        noteController.text =
            existing.note;
      });
    } else {
      setState(() {
        amountController.clear();
        noteController.clear();
      });
    }
  }

  void _save() {
    final amount = double.tryParse(
          amountController.text.trim(),
        ) ??
        0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter an amount greater than 0.',
          ),
        ),
      );

      return;
    }

    context.read<LedgerViewModel>().saveEntryAutomatically(
          date: selectedDate,
          amount: amount,
          note: noteController.text,
        );

    Navigator.pop(context);
  }
}

// ============================================================
// DATE FORMAT
// ============================================================

String fullDate(DateTime date) {
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

  return '${date.day} '
      '${months[date.month - 1]} '
      '${date.year}';
}