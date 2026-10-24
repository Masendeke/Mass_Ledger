
import 'package:flutter/material.dart';
import 'package:mass_ledger/ViewModel/ledger_viewmodel.dart';
import 'package:provider/provider.dart';

import 'calendar_screen.dart';
import 'week_overview_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LedgerViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 20),

              // =====================================================
              // LOGO
              // =====================================================

              Center(
                child: Container(
                  width: 80,
                  height: 80,

                  decoration: BoxDecoration(
                    color: const Color(0xFF102B55),
                    borderRadius: BorderRadius.circular(22),
                  ),

                  child: const Icon(
                    Icons.bar_chart,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // =====================================================
              // APP NAME
              // =====================================================

              const Center(
                child: Text(
                  'Mass Ledger',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF102B55),
                  ),
                ),
              ),

              const SizedBox(height: 5),

              const Center(
                child: Text(
                  'Track. Analyze. Grow.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // =====================================================
              // WELCOME
              // =====================================================

              const Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Keep track of your daily profit and loss '
                'and understand how your money is moving.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 25),

              // =====================================================
              // OPEN CALENDAR
              // =====================================================

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CalendarScreen(),
                      ),
                    );
                  },

                  icon: const Icon(
                    Icons.calendar_month,
                    color: Colors.white,
                  ),

                  label: const Text(
                    'Open Calendar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF102B55),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // =====================================================
              // QUICK OVERVIEW
              // =====================================================

              const Text(
                'Quick Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // -----------------------------------------------------
              // PROFIT + LOSS
              // -----------------------------------------------------

              Row(
                children: [
                  Expanded(
                    child: _overviewCard(
                      title: 'Profit',
                      amount:
                          'R ${vm.totalProfit.toStringAsFixed(2)}',
                      icon: Icons.trending_up,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _overviewCard(
                      title: 'Loss',
                      amount:
                          'R ${vm.totalLoss.toStringAsFixed(2)}',
                      icon: Icons.trending_down,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // -----------------------------------------------------
              // NET + ENTRIES
              // -----------------------------------------------------

              Row(
                children: [
                  Expanded(
                    child: _overviewCard(
                      title: 'Net',
                      amount:
                          'R ${vm.netResult.toStringAsFixed(2)}',
                      icon: Icons.account_balance_wallet,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _overviewCard(
                      title: 'Entries',
                      amount: '${vm.entries.length}',
                      icon: Icons.receipt_long,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // =====================================================
              // FEATURES
              // =====================================================

              const Text(
                'What you can do',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // =====================================================
              // CALENDAR
              // =====================================================

              _featureTile(
                icon: Icons.calendar_month,
                title: 'Calendar',
                subtitle:
                    'View your daily profit and loss.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CalendarScreen(),
                    ),
                  );
                },
              ),

              // =====================================================
              // WEEK OVERVIEW
              // =====================================================

              _featureTile(
                icon: Icons.view_week,
                title: 'Week Overview',
                subtitle:
                    'See your results for the week.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WeekOverviewScreen(),
                    ),
                  );
                },
              ),

              // =====================================================
              // HISTORY
              // =====================================================

              _featureTile(
                icon: Icons.history,
                title: 'History',
                subtitle:
                    'View your previous entries.',
                onTap: () {
                  // Navigation is handled by AppShell.
                  // This button can be connected later if needed.
                },
              ),

              // =====================================================
              // ANALYTICS
              // =====================================================

              _featureTile(
                icon: Icons.bar_chart,
                title: 'Analytics',
                subtitle:
                    'Analyze your financial performance.',
                onTap: () {
                  // Navigation is handled by AppShell.
                  // This button can be connected later if needed.
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // OVERVIEW CARD
  // ============================================================

  Widget _overviewCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),

        border: Border.all(
          color: Colors.black12,
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),

              const SizedBox(width: 7),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            amount,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FEATURE TILE
  // ============================================================

  Widget _featureTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),

        border: Border.all(
          color: Colors.black12,
        ),
      ),

      child: ListTile(
        onTap: onTap,

        leading: Container(
          width: 45,
          height: 45,

          decoration: BoxDecoration(
            color: const Color(0xFF102B55)
                .withValues(alpha: 0.08),

            borderRadius: BorderRadius.circular(12),
          ),

          child: Icon(
            icon,
            color: const Color(0xFF102B55),
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          subtitle,
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
      ),
    );
  }
}

