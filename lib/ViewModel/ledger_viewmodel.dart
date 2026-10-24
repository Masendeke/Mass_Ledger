import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
 
import 'package:mass_ledger/model/daily_entry.dart'; 
import 'package:mass_ledger/model/user_profile.dart'; 
 
// ================================================================ 
// LEDGER VIEW MODEL 
// ================================================================ 
// 
// Controls: 
//   - Daily ledger entries 
//   - Selected calendar date 
//   - Visible calendar month 
//   - Today's date 
//   - Profit / loss calculations 
//   - User profile 
//   - Supabase loading 
//   - Supabase saving 
//   - Supabase deleting 
//   - Supabase connection/authentication testing 
// 
// ================================================================ 
 
class LedgerViewModel extends ChangeNotifier { 
  // ============================================================== 
  // CONSTRUCTOR 
  // ============================================================== 
 
  LedgerViewModel() {
    _initialize();
    _listenToAuthChanges();
  }

  // ==============================================================
  // AUTH LISTENER
  // ==============================================================
  //
  // Loads the user's data when they log in and clears it when they
  // log out, so one account never sees another account's entries.

  StreamSubscription<AuthState>? _authSubscription;

  String? _loadedUserId;

  void _listenToAuthChanges() {
    _authSubscription =
        _supabase.auth.onAuthStateChange.listen(
      (data) {
        final user = data.session?.user;

        if (data.event == AuthChangeEvent.signedOut) {
          _loadedUserId = null;
          _entries.clear();
          _profile = const UserProfile(
            name: '',
            email: '',
            currency: 'South African Rand (R)',
          );
          notifyListeners();
          return;
        }

        if (data.event == AuthChangeEvent.signedIn &&
            user != null &&
            user.id != _loadedUserId) {
          loadData();
        }
      },
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
 
  // ============================================================== 
  // SUPABASE 
  // ============================================================== 
 
  final SupabaseClient _supabase = 
      Supabase.instance.client; 
 
  // ============================================================== 
  // DATA 
  // ============================================================== 
 
  final List<DailyEntry> _entries = []; 
 
  // ============================================================== 
  // LOADING 
  // ============================================================== 
 
  bool _isLoading = false; 
 
  bool get isLoading => _isLoading; 
 
  // ============================================================== 
  // ERROR 
  // ============================================================== 
 
  String? _errorMessage; 
 
  String? get errorMessage => _errorMessage; 
 
  // ============================================================== 
  // USER PROFILE 
  // ============================================================== 
 
  UserProfile _profile = const UserProfile(
    name: '',
    email: '',
    currency: 'South African Rand (R)',
  );
 
  // ============================================================== 
  // DATES 
  // ============================================================== 
 
  DateTime _selectedDate = 
      _dateOnly(DateTime.now()); 
 
  DateTime _visibleMonth = DateTime( 
    DateTime.now().year, 
    DateTime.now().month, 
    1, 
  ); 
 
  // ============================================================== 
  // TODAY 
  // ============================================================== 
 
  // Today's date is ALWAYS calculated from DateTime.now(). 
  // 
  // Selecting another date does NOT change today. 
 
  DateTime get today => 
      _dateOnly(DateTime.now()); 
 
  // ============================================================== 
  // GETTERS 
  // ============================================================== 
 
  List<DailyEntry> get entries => 
      List.unmodifiable(_entries); 
 
  UserProfile get profile => _profile; 
 
  DateTime get selectedDate => 
      _selectedDate; 
 
  DateTime get visibleMonth => 
      _visibleMonth; 
 
  // ============================================================== 
  // IS TODAY 
  // ============================================================== 
 
  bool isToday(DateTime date) { 
    return _sameDay(date, today); 
  } 
 
  // ============================================================== 
  // IS SELECTED DATE 
  // ============================================================== 
 
  bool isSelectedDate(DateTime date) { 
    return _sameDay( 
      date, 
      _selectedDate, 
    ); 
  } 
 
  // ============================================================== 
  // INITIALIZE 
  // ============================================================== 
 
  Future<void> _initialize() async { 
    await loadData(); 
  } 
 
  // ============================================================== 
  // STEP 13 
  // SUPABASE CONNECTION / USER TEST 
  // ============================================================== 
  // 
  // This checks whether a user is currently logged in. 
  // 
  // You can see the result in the Flutter debug console. 
 
  Future<bool> testSupabaseConnection() async { 
    try { 
      final user = 
          _supabase.auth.currentUser; 
 
      if (user == null) { 
        debugPrint( 
          'STEP 13: Supabase connected, but no user is logged in.', 
        ); 
 
        return false; 
      } 
 
      debugPrint( 
        'STEP 13: Supabase connected successfully.', 
      ); 
 
      debugPrint( 
        'STEP 13: Logged in user ID: ${user.id}', 
      ); 
 
      debugPrint( 
        'STEP 13: Logged in email: ${user.email}', 
      ); 
 
      return true; 
    } catch (e) { 
      debugPrint( 
        'STEP 13: Supabase connection error: $e', 
      ); 
 
      _setError( 
        'Unable to connect to Supabase: $e', 
      ); 
 
      return false; 
    } 
  } 
 
  // ============================================================== 
  // LOAD ALL DATA 
  // ============================================================== 
 
  Future<void> loadData() async { 
    _setLoading(true); 
    _clearError(); 
 
    try { 
      // Step 13 connection/authentication check. 
      await testSupabaseConnection(); 
 
      await loadEntriesFromSupabase(); 
 
      await loadProfileFromSupabase(); 
    } catch (e) { 
      _setError( 
        'Unable to load your ledger data: $e', 
      ); 
    } finally { 
      _setLoading(false); 
    } 
  } 
 
  // ============================================================== 
  // LOAD ENTRIES FROM SUPABASE 
  // ============================================================== 
 
  Future<void> loadEntriesFromSupabase() async { 
    final user = 
        _supabase.auth.currentUser; 
 
    // User is not logged in.
    if (user == null) {
      _entries.clear();
      notifyListeners();
      return;
    }

    _loadedUserId = user.id;

    try { 
      final response = await _supabase 
          .from('daily_entries') 
          .select() 
          .eq('user_id', user.id) 
          .order( 
            'date', 
            ascending: true, 
          ); 
 
      _entries.clear(); 
 
      for (final row in response) { 
        _entries.add( 
          DailyEntry.fromMap( 
            Map<String, dynamic>.from(row), 
          ), 
        ); 
      } 
 
      _recalculateAllEntries(); 
 
      notifyListeners(); 
    } catch (e) { 
      _setError( 
        'Unable to load ledger entries: $e', 
      ); 
    } 
  } 
 
  // ============================================================== 
  // LOAD PROFILE FROM SUPABASE 
  // ============================================================== 
 
  Future<void> loadProfileFromSupabase() async { 
    final user = 
        _supabase.auth.currentUser; 
 
    if (user == null) { 
      return; 
    } 
 
    try { 
      final response = await _supabase 
          .from('user_profiles') 
          .select() 
          .eq('user_id', user.id) 
          .maybeSingle(); 
 
      // Profile does not exist yet. 
      if (response == null) { 
        _profile = UserProfile( 
          name: user.userMetadata?['name'] 
                  ?.toString() ?? 
              'User', 
          email: user.email ?? '', 
          currency: 
              'South African Rand (R)', 
        ); 
 
        notifyListeners(); 
        return; 
      } 
 
      _profile = UserProfile( 
        name: 
            response['name']?.toString() ?? 
                'User', 
        email: 
            response['email']?.toString() ?? 
                user.email ?? 
                '', 
        currency: 
            response['currency']?.toString() ?? 
                'South African Rand (R)', 
      ); 
 
      notifyListeners(); 
    } catch (e) { 
      _setError( 
        'Unable to load your profile: $e', 
      ); 
    } 
  } 
 
  // ============================================================== 
  // FIND ENTRY FOR DATE 
  // ============================================================== 
 
  DailyEntry? entryFor(DateTime date) { 
    for (final entry in _entries) { 
      if (_sameDay(entry.date, date)) { 
        return entry; 
      } 
    } 
 
    return null; 
  } 
 
  // ============================================================== 
  // FIRST ENTRY DATE 
  // ============================================================== 
 
  DateTime? get firstEntryDate { 
    if (_entries.isEmpty) { 
      return null; 
    } 
 
    DateTime first = 
        _entries.first.date; 
 
    for (final entry in _entries) { 
      if (_dateOnly(entry.date).isBefore( 
        _dateOnly(first), 
      )) { 
        first = entry.date; 
      } 
    } 
 
    return _dateOnly(first); 
  } 
 
  // ============================================================== 
  // LATEST ENTRY DATE 
  // ============================================================== 
 
  DateTime? get latestEntryDate { 
    if (_entries.isEmpty) { 
      return null; 
    } 
 
    DateTime latest = 
        _entries.first.date; 
 
    for (final entry in _entries) { 
      if (_dateOnly(entry.date).isAfter( 
        _dateOnly(latest), 
      )) { 
        latest = entry.date; 
      } 
    } 
 
    return _dateOnly(latest); 
  } 
 
  // ============================================================== 
  // TRACKING STARTED 
  // ============================================================== 
 
  bool hasStarted(DateTime date) { 
    final first = firstEntryDate; 
 
    if (first == null) { 
      return false; 
    } 
 
    return !_dateOnly(date).isBefore(first); 
  } 
 
  // ============================================================== 
  // DATE WITHIN TRACKING PERIOD 
  // ============================================================== 
 
  bool isWithinTrackingPeriod( 
    DateTime date, 
  ) { 
    final first = firstEntryDate; 
    final latest = latestEntryDate; 
 
    if (first == null || latest == null) { 
      return false; 
    } 
 
    final cleanDate = 
        _dateOnly(date); 
 
    return !cleanDate.isBefore(first) && 
        !cleanDate.isAfter(latest); 
  } 
 
  // ============================================================== 
  // SELECT DATE 
  // ============================================================== 
 
  void selectDate(DateTime date) { 
    _selectedDate = 
        _dateOnly(date); 
 
    _visibleMonth = DateTime( 
      date.year, 
      date.month, 
      1, 
    ); 
 
    notifyListeners(); 
  } 
 
  // ============================================================== 
  // SELECT TODAY 
  // ============================================================== 
 
  void selectToday() { 
    final currentToday = today; 
 
    _selectedDate = 
        currentToday; 
 
    _visibleMonth = DateTime( 
      currentToday.year, 
      currentToday.month, 
      1, 
    ); 
 
    notifyListeners(); 
  } 
 
  // ============================================================== 
  // CHANGE MONTH 
  // ============================================================== 
 
  void changeMonth(int delta) { 
    _visibleMonth = DateTime( 
      _visibleMonth.year, 
      _visibleMonth.month + delta, 
      1, 
    ); 
 
    notifyListeners(); 
  } 
 
  // ============================================================== 
  // SET VISIBLE MONTH 
  // ============================================================== 
 
  void setVisibleMonth( 
    DateTime month, 
  ) { 
    _visibleMonth = DateTime( 
      month.year, 
      month.month, 
      1, 
    ); 
 
    notifyListeners(); 
  } 
 
  // ============================================================== 
  // SET MONTH 
  // ============================================================== 
 
  void setMonth(DateTime month) { 
    setVisibleMonth(month); 
  } 
 
  // ============================================================== 
  // TOTAL PROFIT 
  // ============================================================== 
 
  double get totalProfit { 
    return _entries 
        .where( 
          (entry) => 
              entry.type == 
              ResultType.profit, 
        ) 
        .fold( 
          0.0, 
          (sum, entry) => 
              sum + entry.amount, 
        ); 
  } 
 
  // ============================================================== 
  // TOTAL LOSS 
  // ============================================================== 
 
  double get totalLoss { 
    return _entries 
        .where( 
          (entry) => 
              entry.type == 
              ResultType.loss, 
        ) 
        .fold( 
          0.0, 
          (sum, entry) => 
              sum + entry.amount, 
        ); 
  } 
 
  // ============================================================== 
  // NET RESULT 
  // ============================================================== 
 
  double get netResult { 
    return totalProfit - totalLoss; 
  } 
 
  // ============================================================== 
  // AUTOMATIC RESULT CALCULATION 
  // ============================================================== 
 
  ResultType calculateResultType( 
    DateTime date, 
    double amount, 
  ) { 
    final previousAmount = 
        _previousAmountBefore(date); 
 
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
 
  // ============================================================== 
  // PREVIOUS AMOUNT 
  // ============================================================== 
 
  double? _previousAmountBefore( 
    DateTime date, 
  ) { 
    final previousEntries = 
        _entries 
            .where( 
              (entry) => 
                  _dateOnly(entry.date) 
                      .isBefore( 
                _dateOnly(date), 
              ), 
            ) 
            .toList() 
          ..sort( 
            (a, b) => 
                b.date.compareTo( 
              a.date, 
            ), 
          ); 
 
    if (previousEntries.isEmpty) { 
      return null; 
    } 
 
    return previousEntries.first.amount; 
  } 
 
  // ============================================================== 
  // STEP 12 
  // SAVE ENTRY AUTOMATICALLY 
  // ============================================================== 
 
  Future<void> saveEntryAutomatically({ 
    required DateTime date, 
    required double amount, 
    required String note, 
  }) async { 
    // Make sure amount is positive. 
    if (amount < 0) { 
      amount = amount.abs(); 
    } 
 
    final cleanDate = 
        _dateOnly(date); 
 
    // Check if an entry already exists 
    // for this date. 
    final existingIndex = 
        _entries.indexWhere( 
      (entry) => _sameDay( 
        entry.date, 
        cleanDate, 
      ), 
    ); 
 
    // ========================================================== 
    // CALCULATE TYPE 
    // ========================================================== 
 
    ResultType type; 
 
    if (existingIndex >= 0) { 
      // Temporarily remove the old entry 
      // when calculating the result. 
      final oldEntry = 
          _entries[existingIndex]; 
 
      _entries.removeAt( 
        existingIndex, 
      ); 
 
      type = calculateResultType( 
        cleanDate, 
        amount, 
      ); 
 
      // Put old entry back temporarily. 
      _entries.insert( 
        existingIndex, 
        oldEntry, 
      ); 
    } else { 
      type = calculateResultType( 
        cleanDate, 
        amount, 
      ); 
    } 
 
    // ========================================================== 
    // EXISTING ENTRY 
    // ========================================================== 
 
    if (existingIndex >= 0) { 
      final oldEntry = 
          _entries[existingIndex]; 
 
      final entry = DailyEntry( 
        id: oldEntry.id, 
        date: cleanDate, 
        type: type, 
        amount: amount, 
        note: note.trim(), 
        updatedAt: DateTime.now(), 
      ); 
 
      // Update local data. 
      _entries[existingIndex] = 
          entry; 
 
      _recalculateAllEntries(); 
 
      final updatedEntry = 
          entryFor(cleanDate); 
 
      if (updatedEntry == null) { 
        _setError( 
          'Unable to prepare the entry for saving.', 
        ); 
        return; 
      } 
 
      _selectedDate = 
          cleanDate; 
 
      _visibleMonth = DateTime( 
        cleanDate.year, 
        cleanDate.month, 
        1, 
      ); 
 
      notifyListeners(); 
 
      // Step 12: update Supabase. 
      await _updateEntryInSupabase( 
        updatedEntry, 
      ); 
 
      return; 
    } 
 
    // ========================================================== 
    // NEW ENTRY 
    // ========================================================== 
    // 
    // IMPORTANT: 
    // 
    // Do NOT create: 
    // 
    // DateTime.now().microsecondsSinceEpoch 
    // 
    // as the ID if the Supabase id column is UUID. 
    // 
    // Supabase will create the UUID automatically. 
 
    final temporaryEntry = 
        DailyEntry( 
      id: '', 
      date: cleanDate, 
      type: type, 
      amount: amount, 
      note: note.trim(), 
      updatedAt: DateTime.now(), 
    ); 
 
    // Update local data temporarily. 
    _entries.add( 
      temporaryEntry, 
    ); 
 
    _recalculateAllEntries(); 
 
    final updatedEntry = 
        entryFor(cleanDate); 
 
    if (updatedEntry == null) { 
      _setError( 
        'Unable to prepare the entry for saving.', 
      ); 
      return; 
    } 
 
    _selectedDate = 
        cleanDate; 
 
    _visibleMonth = DateTime( 
      cleanDate.year, 
      cleanDate.month, 
      1, 
    ); 
 
    notifyListeners(); 
 
    // Step 12: insert into Supabase. 
    await _insertEntryIntoSupabase( 
      updatedEntry, 
    ); 
  } 
 
  // ============================================================== 
  // STEP 12 
  // INSERT NEW ENTRY INTO SUPABASE 
  // ============================================================== 
 
  Future<void> _insertEntryIntoSupabase( 
    DailyEntry entry, 
  ) async { 
    final user = 
        _supabase.auth.currentUser; 
 
    if (user == null) { 
      _setError( 
        'You must be logged in to save an entry.', 
      ); 
      return; 
    } 
 
    try { 
      debugPrint( 
        'STEP 12: Inserting new ledger entry.', 
      ); 
 
      final response = await _supabase 
          .from('daily_entries') 
          .insert({ 
            'user_id': user.id, 
            'date': entry.date 
                .toIso8601String() 
                .split('T') 
                .first, 
            'type': entry.type.name, 
            'amount': entry.amount, 
            'note': entry.note, 
            'updated_at': 
                entry.updatedAt 
                    .toIso8601String(), 
          }) 
          .select() 
          .single(); 
 
      // Convert Supabase response 
      // into DailyEntry. 
      final savedEntry = 
          DailyEntry.fromMap( 
        Map<String, dynamic>.from( 
          response, 
        ), 
      ); 
 
      // Replace temporary local entry 
      // with the real Supabase entry. 
      final index = 
          _entries.indexWhere( 
        (item) => _sameDay( 
          item.date, 
          entry.date, 
        ), 
      ); 
 
      if (index >= 0) { 
        _entries[index] = 
            savedEntry; 
      } else { 
        _entries.add( 
          savedEntry, 
        ); 
      } 
 
      _recalculateAllEntries(); 
 
      _clearError(); 
 
      debugPrint( 
        'STEP 12: Entry saved successfully.', 
      ); 
 
      debugPrint( 
        'STEP 12: Supabase entry ID: ${savedEntry.id}', 
      ); 
 
      notifyListeners(); 
    } catch (e) { 
      debugPrint( 
        'STEP 12: Error inserting entry: $e', 
      ); 
 
      // Remove temporary entry 
      // if Supabase save failed. 
      _entries.removeWhere( 
        (item) => _sameDay( 
          item.date, 
          entry.date, 
        ), 
      ); 
 
      _recalculateAllEntries(); 
 
      notifyListeners(); 
 
      _setError( 
        'Unable to save the entry: $e', 
      ); 
    } 
  } 
 
  // ============================================================== 
  // STEP 12 
  // UPDATE EXISTING ENTRY IN SUPABASE 
  // ============================================================== 
 
  Future<void> _updateEntryInSupabase( 
    DailyEntry entry, 
  ) async { 
    final user = 
        _supabase.auth.currentUser; 
 
    if (user == null) { 
      _setError( 
        'You must be logged in to save an entry.', 
      ); 
      return; 
    } 
 
    try { 
      debugPrint( 
        'STEP 12: Updating ledger entry ${entry.id}', 
      ); 
 
      await _supabase 
          .from('daily_entries') 
          .update({ 
            'date': entry.date 
                .toIso8601String() 
                .split('T') 
                .first, 
            'type': entry.type.name, 
            'amount': entry.amount, 
            'note': entry.note, 
            'updated_at': 
                entry.updatedAt 
                    .toIso8601String(), 
          }) 
          .eq('id', entry.id) 
          .eq('user_id', user.id); 
 
      _clearError(); 
 
      debugPrint( 
        'STEP 12: Entry updated successfully.', 
      ); 
 
      notifyListeners(); 
    } catch (e) { 
      debugPrint( 
        'STEP 12: Error updating entry: $e', 
      ); 
 
      _setError( 
        'Unable to save the entry: $e', 
      ); 
    } 
  } 
 
  // ============================================================== 
  // RECALCULATE ALL ENTRIES 
  // ============================================================== 
 
  void _recalculateAllEntries() { 
    _entries.sort( 
      (a, b) => 
          a.date.compareTo(b.date), 
    ); 
 
    double? previousAmount; 
 
    for (int i = 0; 
        i < _entries.length; 
        i++) { 
      final oldEntry = 
          _entries[i]; 
 
      ResultType type; 
 
      if (previousAmount == null) { 
        type = ResultType.profit; 
      } else if (oldEntry.amount > 
          previousAmount) { 
        type = ResultType.profit; 
      } else if (oldEntry.amount < 
          previousAmount) { 
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
        updatedAt: 
            oldEntry.updatedAt, 
      ); 
 
      previousAmount = 
          oldEntry.amount; 
    } 
  } 
 
  // ============================================================== 
  // OLD SAVE METHOD 
  // ============================================================== 
 
  Future<void> saveEntry({ 
    required DateTime date, 
    required ResultType type, 
    required double amount, 
    required String note, 
  }) async { 
    await saveEntryAutomatically( 
      date: date, 
      amount: amount, 
      note: note, 
    ); 
  } 
 
  // ============================================================== 
  // DELETE ENTRY 
  // ============================================================== 
 
  Future<void> deleteEntry( 
    DateTime date, 
  ) async { 
    final entry = 
        entryFor(date); 
 
    if (entry == null) { 
      return; 
    } 
 
    final user = 
        _supabase.auth.currentUser; 
 
    // ========================================================== 
    // REMOVE LOCALLY 
    // ========================================================== 
 
    _entries.removeWhere( 
      (item) => _sameDay( 
        item.date, 
        date, 
      ), 
    ); 
 
    _recalculateAllEntries(); 
 
    notifyListeners(); 
 
    // ========================================================== 
    // DELETE FROM SUPABASE 
    // ========================================================== 
 
    if (user != null) { 
      try { 
        await _supabase 
            .from('daily_entries') 
            .delete() 
            .eq('id', entry.id) 
            .eq('user_id', user.id); 
 
        _clearError(); 
 
        debugPrint( 
          'Entry deleted successfully.', 
        ); 
      } catch (e) { 
        _setError( 
          'Unable to delete the entry: $e', 
        ); 
      } 
    } 
  } 
 
  // ============================================================== 
  // UPDATE PROFILE 
  // ============================================================== 
 
  Future<void> updateProfile({ 
    String? name, 
    String? email, 
    String? currency, 
  }) async { 
    _profile = 
        _profile.copyWith( 
      name: name, 
      email: email, 
      currency: currency, 
    ); 
 
    notifyListeners(); 
 
    final user = 
        _supabase.auth.currentUser; 
 
    if (user == null) { 
      return; 
    } 
 
    try { 
      await _supabase 
          .from('user_profiles') 
          .upsert({ 
            'user_id': user.id, 
            'name': _profile.name, 
            'email': _profile.email, 
            'currency': 
                _profile.currency, 
          }); 
 
      _clearError(); 
 
      notifyListeners(); 
    } catch (e) { 
      _setError( 
        'Unable to update your profile: $e', 
      ); 
    } 
  } 
 
  // ============================================================== 
  // MONTH ENTRIES 
  // ============================================================== 
 
  List<DailyEntry> entriesForMonth( 
    DateTime month, 
  ) { 
    return _entries 
        .where( 
          (entry) => 
              entry.date.year == 
                  month.year && 
              entry.date.month == 
                  month.month, 
        ) 
        .toList() 
      ..sort( 
        (a, b) => 
            a.date.compareTo( 
          b.date, 
        ), 
      ); 
  } 
 
  // ============================================================== 
  // MONTH TOTAL 
  // ============================================================== 
 
  double totalForMonth( 
    DateTime month, 
  ) { 
    return entriesForMonth( 
      month, 
    ).fold( 
      0.0, 
      (sum, entry) => 
          sum + entry.signedAmount, 
    ); 
  } 
 
  // ============================================================== 
  // MONTH PROFIT 
  // ============================================================== 
 
  double profitForMonth( 
    DateTime month, 
  ) { 
    return entriesForMonth(month) 
        .where( 
          (entry) => 
              entry.type == 
              ResultType.profit, 
        ) 
        .fold( 
          0.0, 
          (sum, entry) => 
              sum + entry.amount, 
        ); 
  } 
 
  // ============================================================== 
  // MONTH LOSS 
  // ============================================================== 
 
  double lossForMonth( 
    DateTime month, 
  ) { 
    return entriesForMonth(month) 
        .where( 
          (entry) => 
              entry.type == 
              ResultType.loss, 
        ) 
        .fold( 
          0.0, 
          (sum, entry) => 
              sum + entry.amount, 
        ); 
  } 
 
  // ============================================================== 
  // NO MOVEMENT COUNT 
  // ============================================================== 
 
  int noMovementCount( 
    DateTime month, 
  ) { 
    return entriesForMonth(month) 
        .where( 
          (entry) => 
              entry.type == 
              ResultType.noMovement, 
        ) 
        .length; 
  } 
 
  // ============================================================== 
  // SKIPPED DAYS COUNT 
  // ============================================================== 
 
  int skippedDaysCount( 
    DateTime month, 
  ) { 
    final first = 
        firstEntryDate; 
 
    final latest = 
        latestEntryDate; 
 
    if (first == null || 
        latest == null) { 
      return 0; 
    } 
 
    int count = 0; 
 
    DateTime current = first; 
 
    while (!current.isAfter( 
      latest, 
    )) { 
      if (current.year == 
              month.year && 
          current.month == 
              month.month) { 
        if (entryFor(current) == 
            null) { 
          count++; 
        } 
      } 
 
      current = current.add( 
        const Duration( 
          days: 1, 
        ), 
      ); 
    } 
 
    return count; 
  } 
 
  // ============================================================== 
  // TOTAL NO MOVEMENT COUNT 
  // ============================================================== 
 
  int totalNoMovementCount( 
    DateTime month, 
  ) { 
    return noMovementCount( 
          month, 
        ) + 
        skippedDaysCount( 
          month, 
        ); 
  } 
 
  // ============================================================== 
  // WEEK ENTRIES 
  // ============================================================== 
 
  List<DailyEntry> entriesForWeek( 
    DateTime date, 
  ) { 
    final monday = 
        date.subtract( 
      Duration( 
        days: date.weekday - 1, 
      ), 
    ); 
 
    final sunday = 
        monday.add( 
      const Duration( 
        days: 6, 
      ), 
    ); 
 
    return _entries 
        .where( 
          (entry) => 
              !_dateOnly( 
                entry.date, 
              ).isBefore( 
                _dateOnly(monday), 
              ) && 
              !_dateOnly( 
                entry.date, 
              ).isAfter( 
                _dateOnly(sunday), 
              ), 
        ) 
        .toList() 
      ..sort( 
        (a, b) => 
            a.date.compareTo( 
          b.date, 
        ), 
      ); 
  } 
 
  // ============================================================== 
  // WEEK TOTAL 
  // ============================================================== 
 
  double totalForWeek( 
    DateTime date, 
  ) { 
    return entriesForWeek( 
      date, 
    ).fold( 
      0.0, 
      (sum, entry) => 
          sum + entry.signedAmount, 
    ); 
  } 
 
  // ============================================================== 
  // WEEKLY TOTALS 
  // ============================================================== 
 
  Map<String, double> weeklyTotals( 
    DateTime month, 
  ) { 
    final result = 
        <String, double>{}; 
 
    for (int week = 0; 
        week < 5; 
        week++) { 
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
                !entry.date 
                    .isBefore(start) && 
                !entry.date 
                    .isAfter(end), 
          ) 
          .fold( 
            0.0, 
            (sum, entry) => 
                sum + 
                entry.signedAmount, 
          ); 
 
      result[ 
          'Week ${week + 1}'] = total; 
    } 
 
    return result; 
  } 
 
  // ============================================================== 
  // RECENT ENTRIES 
  // ============================================================== 
 
  List<DailyEntry> recentEntries() { 
    return _entries.toList() 
      ..sort( 
        (a, b) => 
            b.date.compareTo( 
          a.date, 
        ), 
      ); 
  } 
 
  // ============================================================== 
  // SEARCH 
  // ============================================================== 
 
  List<DailyEntry> searchEntries( 
    String query, 
  ) { 
    final search = 
        query.trim().toLowerCase(); 
 
    if (search.isEmpty) { 
      return recentEntries(); 
    } 
 
    return _entries.where( 
      (entry) { 
        final date = entry.date; 
 
        final dateFormats = [ 
          '${date.day}', 
          '${date.month}', 
          '${date.year}', 
          '${date.day}/${date.month}/${date.year}', 
          '${date.day}-${date.month}-${date.year}', 
          _monthName(date.month), 
          _monthName(date.month) 
              .substring(0, 3), 
          _dayName(date.weekday), 
          _dayName(date.weekday) 
              .substring(0, 3), 
        ]; 
 
        final dateText = 
            dateFormats.join(' '); 
 
        final note = 
            entry.note.toLowerCase(); 
 
        final amount = 
            entry.amount 
                .toStringAsFixed(2); 
 
        final type = 
            _typeLabel(entry.type) 
                .toLowerCase(); 
 
        final signedAmount = 
            entry.signedAmount 
                .toStringAsFixed(2); 
 
        return dateText.contains( 
              search, 
            ) || 
            note.contains(search) || 
            amount.contains(search) || 
            signedAmount.contains( 
              search, 
            ) || 
            type.contains(search); 
      }, 
    ).toList() 
      ..sort( 
        (a, b) => 
            b.date.compareTo( 
          a.date, 
        ), 
      ); 
  } 
 
  // ============================================================== 
  // DATE STATUS 
  // ============================================================== 
 
  ResultType? statusForDate( 
    DateTime date, 
  ) { 
    final first = 
        firstEntryDate; 
 
    final latest = 
        latestEntryDate; 
 
    if (first == null || 
        latest == null) { 
      return null; 
    } 
 
    final cleanDate = 
        _dateOnly(date); 
 
    if (cleanDate.isBefore(first)) { 
      return null; 
    } 
 
    if (cleanDate.isAfter(latest)) { 
      return null; 
    } 
 
    final entry = 
        entryFor(cleanDate); 
 
    if (entry != null) { 
      return entry.type; 
    } 
 
    return ResultType.noMovement; 
  } 
 
  // ============================================================== 
  // CALENDAR TYPE 
  // ============================================================== 
 
  ResultType? calendarTypeFor( 
    DateTime date, 
  ) { 
    return statusForDate(date); 
  } 
 
  // ============================================================== 
  // DISPLAY AMOUNT FOR DATE 
  // ============================================================== 
 
  String amountForDate( 
    DateTime date, 
  ) { 
    final entry = 
        entryFor(date); 
 
    if (entry == null) { 
      return ''; 
    } 
 
    return entry.amount 
        .toStringAsFixed(2); 
  } 
 
  // ============================================================== 
  // SET LOADING 
  // ============================================================== 
 
  void _setLoading( 
    bool value, 
  ) { 
    _isLoading = value; 
    notifyListeners(); 
  } 
 
  // ============================================================== 
  // SET ERROR 
  // ============================================================== 
 
  void _setError( 
    String message, 
  ) { 
    _errorMessage = message; 
    notifyListeners(); 
  } 
 
  // ============================================================== 
  // CLEAR ERROR 
  // ============================================================== 
 
  void _clearError() { 
    _errorMessage = null; 
  } 
 
  // ============================================================== 
  // SAME DAY 
  // ============================================================== 
 
  static bool _sameDay( 
    DateTime a, 
    DateTime b, 
  ) { 
    return a.year == b.year && 
        a.month == b.month && 
        a.day == b.day; 
  } 
 
  // ============================================================== 
  // DATE ONLY 
  // ============================================================== 
 
  static DateTime _dateOnly( 
    DateTime date, 
  ) { 
    return DateTime( 
      date.year, 
      date.month, 
      date.day, 
    ); 
  } 
 
  // ============================================================== 
  // MONTH NAME 
  // ============================================================== 
 
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
 
  // ============================================================== 
  // DAY NAME 
  // ============================================================== 
 
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
 
  // ============================================================== 
  // TYPE LABEL 
  // ============================================================== 
 
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