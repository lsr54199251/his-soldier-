import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../features/faith/providers/faith_provider.dart';
import '../features/faith/screens/home_screen.dart';
import '../features/grace/screens/grace_main_screen.dart';
import '../features/prayer_journal/screens/prayer_journal_screen.dart';
import '../features/stats/screens/stats_screen.dart';
import '../features/history/screens/history_screen.dart';
import '../core/widgets/memo_bottom_sheet.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final faithProvider = Provider.of<FaithProvider>(context);

    if (!faithProvider.isLoaded) {
      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF3B82F6),
          ),
        ),
      );
    }

    final todayRecord = faithProvider.getRecordForDate(DateTime.now());

    Widget currentScreen;
    if (_currentIndex == 0) {
      currentScreen = HomeScreen(
        record: todayRecord,
        onUpdate: faithProvider.updateRecord,
        onMemoOpen: (keyStr, record) => showMemoBottomSheet(context, record, keyStr),
      );
    } else if (_currentIndex == 1) {
      currentScreen = const GraceMainScreen();
    } else if (_currentIndex == 2) {
      currentScreen = const PrayerJournalScreen();
    } else if (_currentIndex == 3) {
      currentScreen = StatsScreen(records: faithProvider.records);
    } else {
      currentScreen = HistoryScreen(
        records: faithProvider.records,
        onEditDate: (date) {
          final record = faithProvider.getRecordForDate(date);
          showEditBottomSheet(context, record);
        },
      );
    }

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (_currentIndex != 0) {
            setState(() {
              _currentIndex = 0;
            });
          }
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: SizedBox(
                key: ValueKey<int>(_currentIndex),
                width: double.infinity,
                height: double.infinity,
                child: currentScreen,
              ),
            ),
            Positioned(
              bottom: 16,
              left: 20,
              right: 20,
              child: _buildBottomNav(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F172A).withOpacity(0.8)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, LucideIcons.home, '홈', isDark),
          _buildNavItem(1, LucideIcons.heart, '그레이스', isDark),
          _buildNavItem(2, LucideIcons.book, '기도수첩', isDark),
          _buildNavItem(3, LucideIcons.barChart2, '통계', isDark),
          _buildNavItem(4, LucideIcons.history, '히스토리', isDark),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    bool isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isSelected && !isDark
                ? [
                    const BoxShadow(
                        color: Color(0xFFBFDBFE),
                        blurRadius: 10,
                        offset: Offset(0, 5))
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 20,
                  color: isSelected ? Colors.white : const Color(0xFF94A3B8)),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
