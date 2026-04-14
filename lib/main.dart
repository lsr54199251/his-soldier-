import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import 'providers/faith_provider.dart';
import 'models/faith_record.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/history_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final faithProvider = FaithProvider();
  await faithProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<FaithProvider>.value(value: faithProvider),
      ],
      child: const HisSoldierApp(),
    ),
  );
}

class HisSoldierApp extends StatelessWidget {
  const HisSoldierApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'His Soldier',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFF020617),
        useMaterial3: true,
      ),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  Future<FaithRecord?> _showMemoBottomSheet(
      FaithRecord record, String disciplineKey) {
    String label = '';
    String memoKey = '';
    switch (disciplineKey) {
      case 'isWord':
        label = '말씀';
        memoKey = 'wordMemo';
        break;
      case 'isPrayer':
        label = '기도';
        memoKey = 'prayerMemo';
        break;
      case 'isFellowship':
        label = '교제';
        memoKey = 'fellowshipMemo';
        break;
      case 'isEvangelism':
        label = '전도';
        memoKey = 'evangelismMemo';
        break;
    }

    String initialMemo = '';
    if (memoKey == 'wordMemo') initialMemo = record.wordMemo ?? '';
    if (memoKey == 'prayerMemo') initialMemo = record.prayerMemo ?? '';
    if (memoKey == 'fellowshipMemo') initialMemo = record.fellowshipMemo ?? '';
    if (memoKey == 'evangelismMemo') initialMemo = record.evangelismMemo ?? '';

    TextEditingController _controller =
        TextEditingController(text: initialMemo);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet<FaithRecord>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(48)),
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E3A8A).withOpacity(0.2)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(LucideIcons.stickyNote,
                              color: Color(0xFF3B82F6)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$label 메모',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            Text(
                              DateFormat('M월 d일')
                                  .format(DateTime.parse(record.date)),
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        // Auto-save on manual close
                        FaithRecord up = record;
                        if (memoKey == 'wordMemo') up = up.copyWith(wordMemo: _controller.text);
                        if (memoKey == 'prayerMemo') up = up.copyWith(prayerMemo: _controller.text);
                        if (memoKey == 'fellowshipMemo') up = up.copyWith(fellowshipMemo: _controller.text);
                        if (memoKey == 'evangelismMemo') up = up.copyWith(evangelismMemo: _controller.text);
                        
                        Provider.of<FaithProvider>(context, listen: false).updateRecord(up);
                        Navigator.pop(context, up);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.check,
                            size: 20, color: Color(0xFF3B82F6)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _controller,
                  maxLines: 5,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: '오늘의 훈련 내용을 기록해보세요...',
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                      borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFF1F5F9)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                      borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFF1F5F9)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                      borderSide:
                          const BorderSide(color: Color(0xFF3B82F6), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    '닫으면 자동으로 저장됩니다',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditBottomSheet(FaithRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            bool isDark = Theme.of(context).brightness == Brightness.dark;

            Widget buildEditRow(String label, IconData icon, String keyStr,
                bool isChecked, String? memo) {
              return GestureDetector(
                onTap: () {
                  setModalState(() {
                    if (keyStr == 'isWord')
                      record = record.copyWith(isWord: !record.isWord);
                    if (keyStr == 'isPrayer')
                      record = record.copyWith(isPrayer: !record.isPrayer);
                    if (keyStr == 'isFellowship')
                      record =
                          record.copyWith(isFellowship: !record.isFellowship);
                    if (keyStr == 'isEvangelism')
                      record =
                          record.copyWith(isEvangelism: !record.isEvangelism);
                  });
                  // Auto-save on every toggle
                  Provider.of<FaithProvider>(context, listen: false).updateRecord(record);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isChecked
                        ? (isDark
                            ? const Color(0xFF1E3A8A).withOpacity(0.2)
                            : const Color(0xFFEFF6FF))
                        : (isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF8FAFC)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isChecked
                          ? (isDark
                              ? const Color(0xFF1E40AF)
                              : const Color(0xFFBFDBFE))
                          : (isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFF1F5F9)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(icon,
                              size: 20,
                              color: isChecked
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFF94A3B8)),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(label,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              if (memo != null && memo.isNotEmpty)
                                Text(
                                  memo.length > 10
                                      ? '${memo.substring(0, 10)}...'
                                      : memo,
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B)),
                                )
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (isChecked)
                            GestureDetector(
                              onTap: () async {
                                final res =
                                    await _showMemoBottomSheet(record, keyStr);
                                if (res != null) {
                                  setModalState(() {
                                    record = res;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFE2E8F0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(LucideIcons.stickyNote,
                                    size: 18, color: Color(0xFF475569)),
                              ),
                            ),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isChecked
                                  ? const Color(0xFF3B82F6)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isChecked
                                    ? const Color(0xFF3B82F6)
                                    : (isDark
                                        ? const Color(0xFF475569)
                                        : const Color(0xFFE2E8F0)),
                                width: 2,
                              ),
                            ),
                            child: isChecked
                                ? const Icon(LucideIcons.checkCircle2,
                                    size: 16, color: Colors.white)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(48)),
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('M월 d일 기록 수정', 'ko')
                            .format(DateTime.parse(record.date)),
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.check, size: 20, color: Color(0xFF3B82F6)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  buildEditRow('말씀', LucideIcons.bookOpen, 'isWord',
                      record.isWord, record.wordMemo),
                  buildEditRow('기도', LucideIcons.mic, 'isPrayer',
                      record.isPrayer, record.prayerMemo),
                  buildEditRow('교제', LucideIcons.users, 'isFellowship',
                      record.isFellowship, record.fellowshipMemo),
                  buildEditRow('전도', LucideIcons.send, 'isEvangelism',
                      record.isEvangelism, record.evangelismMemo),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      '변경사항은 즉시 저장됩니다',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                        fontWeight: FontWeight.bold
                      ),
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
        onMemoOpen: (keyStr, record) => _showMemoBottomSheet(record, keyStr),
      );
    } else if (_currentIndex == 1) {
      currentScreen = StatsScreen(records: faithProvider.records);
    } else {
      currentScreen = HistoryScreen(
        records: faithProvider.records,
        onEditDate: (date) {
           final record = faithProvider.getRecordForDate(date);
           _showEditBottomSheet(record);
        },
      );
    }

    return Scaffold(
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
          _buildNavItem(1, LucideIcons.barChart2, '통계', isDark),
          _buildNavItem(2, LucideIcons.history, '히스토리', isDark),
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
