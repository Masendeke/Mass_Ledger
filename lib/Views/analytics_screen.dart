import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mass_ledger/ViewModel/ledger_viewmodel.dart';
import 'package:provider/provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  // ============================================================
  // MONEY FORMATTER
  // ============================================================
  //
  // Formats numbers as South African Rand.
  //
  String money(double amount) {
    return 'R ${amount.abs().toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LedgerViewModel>();

    final month = vm.visibleMonth;

    final profit = vm.profitForMonth(month).toDouble();

    final loss = vm.lossForMonth(month).toDouble();

    final noMovement = vm.noMovementCount(month);

    final total = profit + loss;

    final netProfit = profit - loss;

    // ============================================================
    // PERCENTAGES
    // ============================================================

    final double profitPercentage =
        total == 0.0 ? 0.0 : profit / total;

    final double lossPercentage =
        total == 0.0 ? 0.0 : loss / total;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analytics',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          Container(
            margin: const EdgeInsets.only(
              right: 12,
            ),

            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),

            child: const Center(
              child: Text(
                'This Month',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(14),

        children: [
          // ==================================================
          // DONUT CHART
          // ==================================================

          Container(
            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(
                14,
              ),

              border: Border.all(
                color: Colors.grey,
              ),
            ),

            child: Column(
              children: [
                SizedBox(
                  height: 230,

                  child: CustomPaint(
                    painter: _DonutPainter(
                      profit: profit,
                      loss: loss,
                    ),

                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          Text(
                            money(netProfit),

                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const Text(
                            'Net Profit',

                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                // ==========================================
                // BREAKDOWN
                // ==========================================

                _BreakdownRow(
                  title: 'Profit',

                  amount: profit,

                  percentage: profitPercentage,

                  color: Colors.green,
                ),

                _BreakdownRow(
                  title: 'Loss',

                  amount: -loss,

                  percentage: lossPercentage,

                  color: const Color.fromARGB(
                    255,
                    236,
                    45,
                    45,
                  ),
                ),

                _BreakdownRow(
                  title: 'No Movement',

                  amount: 0.0,

                  percentage: 0.0,

                  color: Colors.deepOrange,

                  count: noMovement,
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          // ==================================================
          // SUMMARY
          // ==================================================

          const Text(
            'Summary',

            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Profit',

                  amount: profit,

                  color: Colors.green,
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child: _SummaryCard(
                  title: 'Loss',

                  amount: loss,

                  color: const Color.fromARGB(
                    255,
                    236,
                    45,
                    45,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          _SummaryCard(
            title: 'Net Result',

            amount: netProfit,

            color: netProfit >= 0
                ? Colors.green
                : const Color.fromARGB(
                    255,
                    236,
                    45,
                    45,
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DONUT PAINTER
// ============================================================

class _DonutPainter extends CustomPainter {
  final double profit;

  final double loss;

  _DonutPainter({
    required this.profit,
    required this.loss,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final double total = profit + loss;

    final center = size.center(
      Offset.zero,
    );

    final radius =
        math.min(
              size.width,
              size.height,
            ) /
            2 -
        15;

    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30;

    if (total == 0.0) {
      paint.color = Colors.grey;

      canvas.drawCircle(
        center,
        radius,
        paint,
      );

      return;
    }

    final double profitSweep =
        2 * math.pi * (profit / total);

    paint.color = Colors.green;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      profitSweep,
      false,
      paint,
    );

    paint.color = const Color.fromARGB(
      255,
      236,
      45,
      45,
    );

    canvas.drawArc(
      rect,
      -math.pi / 2 + profitSweep,
      2 * math.pi - profitSweep,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _DonutPainter oldDelegate,
  ) {
    return oldDelegate.profit != profit ||
        oldDelegate.loss != loss;
  }
}

// ============================================================
// BREAKDOWN ROW
// ============================================================

class _BreakdownRow extends StatelessWidget {
  final String title;

  final double amount;

  final double percentage;

  final Color color;

  final int? count;

  const _BreakdownRow({
    required this.title,
    required this.amount,
    required this.percentage,
    required this.color,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),

      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,

            decoration: BoxDecoration(
              color: color,

              borderRadius:
                  BorderRadius.circular(
                3,
              ),
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Text(
              title,
            ),
          ),

          Text(
            count != null
                ? '$count entries'
                : '${amount < 0 ? '-' : ''}'
                    'R ${amount.abs().toStringAsFixed(2)}',

            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          Text(
            '(${(percentage * 100).toStringAsFixed(1)}%)',

            style: const TextStyle(
              color: Colors.black54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SUMMARY CARD
// ============================================================

class _SummaryCard extends StatelessWidget {
  final String title;

  final double amount;

  final Color color;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              color: Colors.black54,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            'R ${amount.abs().toStringAsFixed(2)}',

            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}