import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/faith_record.dart';
import 'package:uuid/uuid.dart';
// Note: since shared_preferences might not be available or fail, we use a simple in-memory cache for this demo.
// In a real app, SharedPreferences would load/save this list.

class FaithProvider with ChangeNotifier {
  List<FaithRecord> _records = [];

  List<FaithRecord> get records => _records;

  FaithProvider() {
    // Starting fresh without dummy data
  }

  FaithRecord getRecordForDate(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    try {
      return _records.firstWhere((r) => r.date == dateStr);
    } catch (e) {
      final newRecord = FaithRecord(
        id: const Uuid().v4(),
        date: dateStr,
      );
      _records.add(newRecord);
      // Let's schedule notifyListeners so we don't build and notify at the same time
      Future.microtask(() => notifyListeners());
      return newRecord;
    }
  }

  void updateRecord(FaithRecord record) {
    final index = _records.indexWhere((r) => r.date == record.date);
    if (index >= 0) {
      _records[index] = record;
    } else {
      _records.add(record);
    }
    notifyListeners();
  }
}
