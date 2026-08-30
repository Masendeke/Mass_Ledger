import 'package:flutter/material.dart';
import 'package:mass_ledger/ViewModel/ledger_viewmodel.dart';
import 'package:mass_ledger/model/daily_entry.dart';
import 'package:provider/provider.dart';

import 'add_edit_screen.dart';
import 'date_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({
    super.key,
  });

  @override
  State<CalendarScreen> createState() =>
      _CalendarScreenState();
}

class _CalendarScreenState
    extends State<CalendarScreen> {
  String _viewMode = 'Compact';

  @override
  Widget build(BuildContext context) {
    final vm =
        context.watch<LedgerViewModel>();

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor: Colors.white,

        titleSpacing: 4,

        leading: IconButton(
          tooltip: 'View options',
          icon: const Icon(Icons.menu),
          onPressed: () {
            _showViewOptions(context);
          },
        ),

        title: _monthSelector(
          context,
          vm,
        ),

        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearch(context);
            },
          ),

          IconButton(
            tooltip: 'Add entry',
            icon: const Icon(Icons.add),
            onPressed: () {
              _openAddScreen(context);
            },
          ),

          const SizedBox(width: 4),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            14,
            12,
            14,
            20,
          ),
          child: Column(
            children: [
              _monthlySummary(
                context,
                vm,
              ),

              const SizedBox(height: 14),

              _calendarHeader(),

              const SizedBox(height: 8),

              _calendar(
                context,
                vm,
              ),

              const SizedBox(height: 18),

              _legend(),

              const SizedBox(height: 14),

              Align(
                alignment:
                    Alignment.centerLeft,
                child: Text(
                  'View: $_viewMode',
                  style:
                      const TextStyle(
                    fontSize: 11,
                    color: Colors.black45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MONTH SELECTOR
  // ============================================================

  Widget _monthSelector(
    BuildContext context,
    LedgerViewModel vm,
  ) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(8),
      onTap: () {
        _showMonthYearPicker(
          context,
          vm,
        );
      },
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 8,
        ),
        child: Row(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Text(
              '${_monthName(vm.visibleMonth.month)} '
              '${vm.visibleMonth.year}',
              style:
                  const TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
                color:
                    Color(0xFF09275F),
              ),
            ),
            const SizedBox(width: 3),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color:
                  Color(0xFF09275F),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MONTHLY SUMMARY
  // ============================================================

  Widget _monthlySummary(
    BuildContext context,
    LedgerViewModel vm,
  ) {
    final entries =
        vm.entriesForMonth(
      vm.visibleMonth,
    );

    final hasData = entries.isNotEmpty;

    final total = hasData
        ? vm.totalForMonth(
            vm.visibleMonth,
          )
        : 0.0;

    final profit = hasData
        ? vm.profitForMonth(
            vm.visibleMonth,
          )
        : 0.0;

    final loss = hasData
        ? vm.lossForMonth(
            vm.visibleMonth,
          )
        : 0.0;

    final noMovement = hasData
        ? vm.noMovementCount(
            vm.visibleMonth,
          )
        : 0;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
            children: [
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Profit',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    hasData
                        ? _money(total)
                        : '',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight:
                          FontWeight.bold,
                      color: total >= 0
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
              if (!hasData)
                const Text(
                  'No entries yet',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        Colors.black45,
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _summaryCard(
                'Profit',
                profit,
                Colors.green,
                showValue: hasData,
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: _summaryCard(
                'Loss',
                loss,
                Colors.red,
                showValue: hasData,
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: _summaryCard(
                'No Movement',
                noMovement.toDouble(),
                Colors.orange,
                isCount: true,
                showValue: hasData,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard(
    String title,
    double value,
    Color color, {
    bool isCount = false,
    bool showValue = true,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(
                  color: color,
                  shape:
                      BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  title,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            showValue
                ? (isCount
                    ? value.toInt().toString()
                    : _money(value))
                : '',
            style: TextStyle(
              color: color,
              fontWeight:
                  FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CALENDAR HEADER
  // ============================================================

  Widget _calendarHeader() {
    const days = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return Row(
      children: [
        for (final day in days)
          Expanded(
            child: Center(
              child: Text(
                day,
                style:
                    const TextStyle(
                  fontSize: 11,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Colors.black54,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // CALENDAR
  // ============================================================

  Widget _calendar(
    BuildContext context,
    LedgerViewModel vm,
  ) {
    switch (_viewMode) {
      case 'Stacked':
        return _stackedCalendar(
          context,
          vm,
        );

      case 'Details':
        return _detailsCalendar(
          context,
          vm,
        );

      case 'List':
        return _listCalendar(
          context,
          vm,
        );

      default:
        return _compactCalendar(
          context,
          vm,
        );
    }
  }

  // ============================================================
  // COMPACT CALENDAR
  // ============================================================

  Widget _compactCalendar(
    BuildContext context,
    LedgerViewModel vm,
  ) {
    final month = vm.visibleMonth;

    final firstDay = DateTime(
      month.year,
      month.month,
      1,
    );

    final daysInMonth = DateTime(
      month.year,
      month.month + 1,
      0,
    ).day;

    final leading =
        firstDay.weekday - 1;

    final totalCells =
        ((leading + daysInMonth) / 7)
                .ceil() *
            7;

    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        childAspectRatio: .82,
      ),
      itemBuilder:
          (context, index) {
        if (index < leading ||
            index >=
                leading +
                    daysInMonth) {
          return const SizedBox();
        }

        final day =
            index - leading + 1;

        final date = DateTime(
          month.year,
          month.month,
          day,
        );

        return _calendarDay(
          context,
          vm,
          date,
        );
      },
    );
  }

  // ============================================================
  // CALENDAR DAY
  // ============================================================

  Widget _calendarDay(
    BuildContext context,
    LedgerViewModel vm,
    DateTime date,
  ) {
    final entry = vm.entryFor(date);

    final status =
        vm.statusForDate(date);

    // ----------------------------------------------------------
    // TODAY
    // ----------------------------------------------------------
    // This is deliberately calculated separately from
    // vm.selectedDate.
    //
    // Therefore today ALWAYS remains red.
    // ----------------------------------------------------------

    final now = DateTime.now();

    final isToday =
        date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    // ----------------------------------------------------------
    // SELECTED DATE
    // ----------------------------------------------------------

    final isSelected = _sameDay(
      date,
      vm.selectedDate,
    );

    // ----------------------------------------------------------
    // BACKGROUND
    // ----------------------------------------------------------

    Color? background;

    if (status != null) {
      background =
          _entryColor(status)
              .withValues(alpha: .12);
    }

    // ----------------------------------------------------------
    // BORDER
    // ----------------------------------------------------------
    //
    // TODAY     -> RED
    // SELECTED  -> BLUE
    // NORMAL    -> GREY
    //
    // Today gets priority over selected.
    // ----------------------------------------------------------

    Color borderColor;
    double borderWidth;

    if (isToday) {
      borderColor = Colors.red;
      borderWidth = 2.5;
    } else if (isSelected) {
      borderColor =
          const Color(0xFF09275F);
      borderWidth = 2;
    } else {
      borderColor =
          Colors.grey.shade200;
      borderWidth = 1;
    }

    return InkWell(
      borderRadius:
          BorderRadius.circular(10),

      onTap: () {
        // This changes the selected date only.
        // It does NOT change today's date.
        vm.selectDate(date);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const DateDetailScreen(),
          ),
        );
      },

      child: Container(
        decoration: BoxDecoration(
          color:
              background ?? Colors.white,

          borderRadius:
              BorderRadius.circular(10),

          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
        ),

        padding:
            const EdgeInsets.symmetric(
          vertical: 6,
          horizontal: 2,
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            // --------------------------------------------------
            // DATE NUMBER
            // --------------------------------------------------

            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    FontWeight.bold,

                // TODAY = RED
                // SELECTED = BLUE
                // NORMAL = GREY
                color: isToday
                    ? Colors.red
                    : isSelected
                        ? const Color(
                            0xFF09275F,
                          )
                        : Colors.black54,
              ),
            ),

            const SizedBox(height: 4),

            // --------------------------------------------------
            // STATUS
            // --------------------------------------------------

            if (status == null)

              // Before tracking starts
              // or after latest entry.
              const SizedBox(height: 10)

            else if (entry == null)

              // Missing date between tracking dates.
              const Text(
                'No movement',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 7,
                  fontWeight:
                      FontWeight.bold,
                  color: Colors.orange,
                ),
              )

            else

              // Existing entry.
              Text(
                _shortAmount(entry),
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight:
                      FontWeight.bold,
                  color: _entryColor(
                    entry.type,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STACKED
  // ============================================================

  Widget _stackedCalendar(
    BuildContext context,
    LedgerViewModel vm,
  ) {
    final entries =
        vm.entriesForMonth(
      vm.visibleMonth,
    );

    if (entries.isEmpty) {
      return _emptyCalendarMessage();
    }

    return Column(
      children: [
        for (final entry in entries)
          _stackedEntry(
            context,
            vm,
            entry,
          ),
      ],
    );
  }

  Widget _stackedEntry(
    BuildContext context,
    LedgerViewModel vm,
    DailyEntry entry,
  ) {
    final isToday = _isToday(entry.date);
    final isSelected = _sameDay(
      entry.date,
      vm.selectedDate,
    );

    return InkWell(
      onTap: () {
        vm.selectDate(entry.date);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const DateDetailScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin:
            const EdgeInsets.only(
          bottom: 8,
        ),
        padding:
            const EdgeInsets.all(14),
        decoration:
            BoxDecoration(
          color: _entryColor(
            entry.type,
          ).withValues(
            alpha: .12,
          ),
          borderRadius:
              BorderRadius.circular(12),
          border: Border.all(
            color: isToday
                ? Colors.red
                : isSelected
                    ? const Color(
                        0xFF09275F,
                      )
                    : _entryColor(
                        entry.type,
                      ).withValues(
                        alpha: .35,
                      ),
            width: isToday || isSelected
                ? 2
                : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 45,
              decoration:
                  BoxDecoration(
                color:
                    _entryColor(
                  entry.type,
                ),
                borderRadius:
                    BorderRadius.circular(
                  5,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_dayName(entry.date.weekday)}, '
                    '${entry.date.day} '
                    '${_monthName(entry.date.month)}',
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    typeLabel(
                      entry.type,
                    ),
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          _entryColor(
                        entry.type,
                      ),
                    ),
                  ),

                  if (entry.note.isNotEmpty)
                    Text(
                      entry.note,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 11,
                        color:
                            Colors.black54,
                      ),
                    ),
                ],
              ),
            ),

            Text(
              _displayAmount(entry),
              style: TextStyle(
                color:
                    _entryColor(
                  entry.type,
                ),
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DETAILS
  // ============================================================

  Widget _detailsCalendar(
    BuildContext context,
    LedgerViewModel vm,
  ) {
    final entries =
        vm.entriesForMonth(
      vm.visibleMonth,
    );

    if (entries.isEmpty) {
      return _emptyCalendarMessage();
    }

    return Column(
      children: [
        for (final entry in entries)
          Card(
            elevation: 0,
            margin:
                const EdgeInsets.only(
              bottom: 8,
            ),
            child: ListTile(
              onTap: () {
                vm.selectDate(
                  entry.date,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const DateDetailScreen(),
                  ),
                );
              },

              leading: CircleAvatar(
                backgroundColor:
                    _entryColor(
                  entry.type,
                ),
                child: Text(
                  '${entry.date.day}',
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              title: Text(
                '${_dayName(entry.date.weekday)}, '
                '${entry.date.day} '
                '${_monthName(entry.date.month)}',
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              subtitle: Text(
                entry.note.isEmpty
                    ? typeLabel(
                        entry.type,
                      )
                    : entry.note,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
              ),

              trailing: Text(
                _displayAmount(entry),
                style: TextStyle(
                  color:
                      _entryColor(
                    entry.type,
                  ),
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // LIST
  // ============================================================

  Widget _listCalendar(
    BuildContext context,
    LedgerViewModel vm,
  ) {
    final entries =
        vm.entriesForMonth(
      vm.visibleMonth,
    );

    if (entries.isEmpty) {
      return _emptyCalendarMessage();
    }

    return Container(
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0;
              i < entries.length;
              i++)
            ListTile(
              onTap: () {
                vm.selectDate(
                  entries[i].date,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const DateDetailScreen(),
                  ),
                );
              },

              leading: Text(
                '${entries[i].date.day}',
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              title: Text(
                '${_dayName(entries[i].date.weekday)} '
                '${_monthName(entries[i].date.month)}',
              ),

              subtitle:
                  entries[i].note.isEmpty
                      ? null
                      : Text(
                          entries[i].note,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                        ),

              trailing: Text(
                _displayAmount(
                  entries[i],
                ),
                style: TextStyle(
                  color:
                      _entryColor(
                    entries[i].type,
                  ),
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _emptyCalendarMessage() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(30),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 40,
            color: Colors.black26,
          ),

          SizedBox(height: 10),

          Text(
            'No entries yet',
            style:
                TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          SizedBox(height: 5),

          Text(
            'Add an update to start tracking.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              fontSize: 12,
              color:
                  Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LEGEND
  // ============================================================

  Widget _legend() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(15),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Calendar Legend',
            style:
                TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _legendItem(
                  'Profit',
                  Colors.green,
                ),
              ),
              Expanded(
                child: _legendItem(
                  'Loss',
                  Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _legendItem(
                  'No Movement',
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _legendItem(
                  'No Data',
                  Colors.grey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ------------------------------------------------------
          // TODAY / SELECTED LEGEND
          // ------------------------------------------------------

          Row(
            children: [
              Expanded(
                child: _legendItem(
                  'Today',
                  Colors.red,
                ),
              ),
              Expanded(
                child: _legendItem(
                  'Selected',
                  const Color(0xFF09275F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(
    String title,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration:
              BoxDecoration(
            color: color,
            shape:
                BoxShape.circle,
          ),
        ),

        const SizedBox(width: 7),

        Flexible(
          child: Text(
            title,
            style:
                const TextStyle(
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // VIEW OPTIONS
  // ============================================================

  void _showViewOptions(
    BuildContext context,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Colors.white,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              15,
              20,
              20,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Calendar View',
                  style:
                      TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                _viewOption(
                  context,
                  'Compact',
                  Icons.calendar_view_month,
                ),

                _viewOption(
                  context,
                  'Stacked',
                  Icons.view_agenda_outlined,
                ),

                _viewOption(
                  context,
                  'Details',
                  Icons.article_outlined,
                ),

                _viewOption(
                  context,
                  'List',
                  Icons.list,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _viewOption(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final selected =
        _viewMode == title;

    return ListTile(
      contentPadding:
          EdgeInsets.zero,

      leading: Icon(
        icon,
        color: selected
            ? const Color(0xFF09275F)
            : Colors.black54,
      ),

      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),

      trailing: selected
          ? const Icon(
              Icons.check,
              color:
                  Color(0xFF09275F),
            )
          : null,

      onTap: () {
        setState(() {
          _viewMode = title;
        });

        Navigator.pop(context);
      },
    );
  }

  // ============================================================
  // MONTH/YEAR PICKER
  // ============================================================

  void _showMonthYearPicker(
    BuildContext context,
    LedgerViewModel vm,
  ) {
    int selectedYear =
        vm.visibleMonth.year;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.white,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder:
              (context, setModalState) {
            return SizedBox(
              height:
                  MediaQuery.of(context)
                          .size
                          .height *
                      .65,

              child: Column(
                children: [
                  const SizedBox(height: 15),

                  const Text(
                    'Select Month',
                    style:
                        TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          setModalState(() {
                            selectedYear--;
                          });
                        },
                        icon:
                            const Icon(
                          Icons.chevron_left,
                        ),
                      ),

                      Text(
                        '$selectedYear',
                        style:
                            const TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          setModalState(() {
                            selectedYear++;
                          });
                        },
                        icon:
                            const Icon(
                          Icons.chevron_right,
                        ),
                      ),
                    ],
                  ),

                  const Divider(),

                  Expanded(
                    child:
                        GridView.builder(
                      padding:
                          const EdgeInsets
                              .all(18),

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),

                      itemCount: 12,

                      itemBuilder:
                          (context, index) {
                        final month =
                            index + 1;

                        final selected =
                            vm.visibleMonth
                                        .year ==
                                    selectedYear &&
                                vm.visibleMonth
                                        .month ==
                                    month;

                        return InkWell(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),

                          onTap: () {
                            vm.setVisibleMonth(
                              DateTime(
                                selectedYear,
                                month,
                                1,
                              ),
                            );

                            Navigator.pop(
                              context,
                            );
                          },

                          child:
                              Container(
                            alignment:
                                Alignment
                                    .center,

                            decoration:
                                BoxDecoration(
                              color: selected
                                  ? const Color(
                                      0xFF09275F,
                                    )
                                  : Colors
                                      .grey
                                      .shade100,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                12,
                              ),
                            ),

                            child: Text(
                              _monthName(
                                month,
                              ),
                              style:
                                  TextStyle(
                                color: selected
                                    ? Colors
                                        .white
                                    : Colors
                                        .black87,
                                fontWeight:
                                    selected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _showSearch(
    BuildContext context,
  ) {
    final controller =
        TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
              const Text(
            'Search Entries',
          ),

          content: TextField(
            controller: controller,
            autofocus: true,
            decoration:
                const InputDecoration(
              hintText:
                  'Search date, amount or description',
              prefixIcon:
                  Icon(Icons.search),
            ),
            onSubmitted: (_) {
              Navigator.pop(
                dialogContext,
              );

              _performSearch(
                context,
                controller.text,
              );
            },
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
                  const Text('Close'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                _performSearch(
                  context,
                  controller.text,
                );
              },
              child:
                  const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _performSearch(
    BuildContext context,
    String query,
  ) {
    final vm =
        context.read<LedgerViewModel>();

    final results =
        vm.searchEntries(query);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            results.isEmpty
                ? 'No Results'
                : '${results.length} Result(s)',
          ),

          content: SizedBox(
            width: double.maxFinite,
            height: 350,

            child: results.isEmpty
                ? const Center(
                    child: Text(
                      'Nothing matched your search.',
                    ),
                  )
                : ListView.builder(
                    itemCount:
                        results.length,

                    itemBuilder:
                        (context, index) {
                      final entry =
                          results[index];

                      return ListTile(
                        leading:
                            CircleAvatar(
                          backgroundColor:
                              _entryColor(
                            entry.type,
                          ),
                          child: Text(
                            '${entry.date.day}',
                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        title: Text(
                          '${entry.date.day} '
                          '${_monthName(entry.date.month)} '
                          '${entry.date.year}',
                        ),

                        subtitle:
                            Text(
                          entry.note.isEmpty
                              ? typeLabel(
                                  entry.type,
                                )
                              : entry.note,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                        ),

                        trailing:
                            Text(
                          _displayAmount(
                            entry,
                          ),
                          style:
                              TextStyle(
                            color:
                                _entryColor(
                              entry.type,
                            ),
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        onTap: () {
                          Navigator.pop(
                            context,
                          );

                          vm.selectDate(
                            entry.date,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const DateDetailScreen(),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  // ============================================================
  // ADD
  // ============================================================

  void _openAddScreen(
    BuildContext context,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const AddEditScreen(),
      ),
    );
  }

  // ============================================================
  // CHECK TODAY
  // ============================================================

  bool _isToday(DateTime date) {
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _monthName(int month) {
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

  String _dayName(int weekday) {
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

  String _money(num amount) {
    return 'R ${amount.toStringAsFixed(2)}';
  }

  String _shortAmount(
    DailyEntry entry,
  ) {
    if (entry.type ==
        ResultType.noMovement) {
      return 'R 0';
    }

    if (entry.type ==
        ResultType.loss) {
      return '-R ${entry.amount.toStringAsFixed(0)}';
    }

    return 'R ${entry.amount.toStringAsFixed(0)}';
  }

  String _displayAmount(
    DailyEntry entry,
  ) {
    if (entry.type ==
        ResultType.loss) {
      return '-R ${entry.amount.toStringAsFixed(2)}';
    }

    return 'R ${entry.amount.toStringAsFixed(2)}';
  }

  Color _entryColor(
    ResultType type,
  ) {
    switch (type) {
      case ResultType.profit:
        return Colors.green;

      case ResultType.loss:
        return Colors.red;

      case ResultType.noMovement:
        return Colors.orange;
    }
  }

  String typeLabel(
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

  bool _sameDay(
    DateTime a,
    DateTime b,
  ) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }
}