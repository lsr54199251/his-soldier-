import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/faith_record.dart';
import 'package:uuid/uuid.dart';

class FaithProvider with ChangeNotifier {
  List<FaithRecord> _records = [];
  static const String _storageKey = 'faith_records_v1';
  bool _isInitialized = false;
  bool _isLoading = false;

  List<FaithRecord> get records => _records;
  bool get isLoaded => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized || _isLoading) return;

    _isLoading = true;
    debugPrint("Initializing FaithProvider...");
    await _loadRecords();

    // Set initialized to true BEFORE creating today's record so save works
    _isInitialized = true;

    // Ensure today's record exists
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (!_records.any((r) => r.date == todayStr)) {
      debugPrint("Creating today's record for $todayStr");
      _records.add(FaithRecord(
        id: const Uuid().v4(),
        date: todayStr,
      ));
      await _saveRecords();
    }

    _isLoading = false;
    notifyListeners();
    debugPrint("FaithProvider initialized with ${_records.length} records.");
  }

  Future<void> _loadRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        final List<FaithRecord> loadedRecords = [];

        for (var item in decoded) {
          try {
            loadedRecords
                .add(FaithRecord.fromJson(item as Map<String, dynamic>));
          } catch (e) {
            debugPrint("Error parsing individual record: $e");
          }
        }
        _records = loadedRecords;
        debugPrint("Loaded ${_records.length} records successfully.");
      } else {
        _records = [];
        debugPrint("No records found in storage.");
      }
    } catch (e) {
      debugPrint("Fatal error loading records: $e");
    }
  }

  Future<void> _saveRecords() async {
    if (!_isInitialized) {
      debugPrint("Warning: Attempted to save before initialization. Aborting.");
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString =
          jsonEncode(_records.map((r) => r.toJson()).toList());
      final bool success = await prefs.setString(_storageKey, jsonString);

      if (success) {
        debugPrint("Saved ${_records.length} records successfully.");
      } else {
        debugPrint("Failed to save records to SharedPreferences.");
      }
    } catch (e) {
      debugPrint("Error saving records: $e");
    }
  }

  FaithRecord getRecordForDate(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    final index = _records.indexWhere((r) => r.date == dateStr);

    if (index != -1) {
      return _records[index];
    }

    final newRecord = FaithRecord(
      id: const Uuid().v4(),
      date: dateStr,
    );

    _records.add(newRecord);
    _saveRecords();

    return newRecord;
  }

  Future<void> updateRecord(FaithRecord record) async {
    final index =
        _records.indexWhere((r) => r.id == record.id || r.date == record.date);

    if (index >= 0) {
      _records[index] = record;
    } else {
      _records.add(record);
    }

    notifyListeners();
    await _saveRecords();
  }
}
