import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/grace_routine.dart';
import 'package:uuid/uuid.dart';

class GraceProvider with ChangeNotifier {
  int _streak = 0;
  GraceTodayStatus _todayStatus = GraceTodayStatus(date: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  List<GraceRoutine> _history = [];
  bool _isInitialized = false;

  int get streak => _streak;
  GraceTodayStatus get todayStatus => _todayStatus;
  List<GraceRoutine> get history => _history;
  bool get isLoaded => _isInitialized;

  static const String _keyStreak = 'grace_habit_streak';
  static const String _keyStatus = 'grace_habit_today_status';
  static const String _keyHistory = 'grace_habit_history';

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _streak = prefs.getInt(_keyStreak) ?? 0;
      
      final String? statusJson = prefs.getString(_keyStatus);
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      if (statusJson != null) {
        final loadedStatus = GraceTodayStatus.fromJson(jsonDecode(statusJson));
        if (loadedStatus.date == todayStr) {
          _todayStatus = loadedStatus;
        } else {
          // New day
          _todayStatus = GraceTodayStatus(date: todayStr);
          await _saveStatus(prefs);
        }
      } else {
        _todayStatus = GraceTodayStatus(date: todayStr);
        await _saveStatus(prefs);
      }

      final String? historyJson = prefs.getString(_keyHistory);
      if (historyJson != null) {
        final List<dynamic> decoded = jsonDecode(historyJson);
        _history = decoded.map((e) => GraceRoutine.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Error initializing GraceProvider: $e");
    }
    
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveStatus(SharedPreferences prefs) async {
    await prefs.setString(_keyStatus, jsonEncode(_todayStatus.toJson()));
  }

  Future<void> _saveHistory(SharedPreferences prefs) async {
    await prefs.setString(_keyHistory, jsonEncode(_history.map((e) => e.toJson()).toList()));
  }

  Future<void> _saveStreak(SharedPreferences prefs) async {
    await prefs.setInt(_keyStreak, _streak);
  }

  Future<void> completeRoutine(String type, Map<String, dynamic> data) async {
    if (type == 'morning' && _todayStatus.morningDone) return;
    if (type == 'evening' && _todayStatus.eveningDone) return;

    final prefs = await SharedPreferences.getInstance();

    // Update status
    if (type == 'morning') {
      _todayStatus = _todayStatus.copyWith(morningDone: true);
    } else {
      _todayStatus = _todayStatus.copyWith(eveningDone: true);
      _streak += 1;
      await _saveStreak(prefs);
    }
    await _saveStatus(prefs);

    // Update history
    final newRoutine = GraceRoutine(
      id: const Uuid().v4(),
      type: type,
      timestamp: DateTime.now().toIso8601String(),
      note: data['note'],
      gratitude: data['gratitude'],
      concern: data['concern'],
      reflection: data['reflection'],
    );
    
    _history.add(newRoutine);
    await _saveHistory(prefs);

    notifyListeners();
  }
}
