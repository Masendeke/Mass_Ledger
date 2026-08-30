import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'calendar_screen.dart';
import 'history_screen.dart';
import 'analytics_screen.dart';
import 'week_overview_screen.dart';

class AppShell extends StatefulWidget {
  final int initialIndex;

  const AppShell({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const CalendarScreen(),
      const WeekOverviewScreen(),
      const HistoryScreen(),
      const AnalyticsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,

        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        height: 70,

        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.calendar_month_outlined,
            ),
            selectedIcon: Icon(
              Icons.calendar_month,
            ),
            label: 'Calendar',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.view_week_outlined,
            ),
            selectedIcon: Icon(
              Icons.view_week,
            ),
            label: 'Week',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.history_outlined,
            ),
            selectedIcon: Icon(
              Icons.history,
            ),
            label: 'History',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.bar_chart_outlined,
            ),
            selectedIcon: Icon(
              Icons.bar_chart,
            ),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}