import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/faith_record.dart';
import '../providers/faith_provider.dart';

class HomeScreen extends StatefulWidget {
  final FaithRecord record;
  final Function(FaithRecord) onUpdate;
  final Function(String, FaithRecord) onMemoOpen;

  const HomeScreen({
    Key? key,
    required this.record,
    required this.onUpdate,
    required this.onMemoOpen,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late FaithRecord _record;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko', null);
    _record = widget.record;
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.record != widget.record) {
      _record = widget.record;
    }
  }

  void _toggleDiscipline(String key) {
    FaithRecord updated = _record;
    switch (key) {
      case 'isWord':
        updated = _record.copyWith(isWord: !_record.isWord);
        break;
      case 'isPrayer':
        updated = _record.copyWith(isPrayer: !_record.isPrayer);
        break;
      case 'isFellowship':
        updated = _record.copyWith(isFellowship: !_record.isFellowship);
        break;
      case 'isEvangelism':
        updated = _record.copyWith(isEvangelism: !_record.isEvangelism);
        break;
    }
    widget.onUpdate(updated);
  }

  int get _completedCount {
    int count = 0;
    if (_record.isWord) count++;
    if (_record.isPrayer) count++;
    if (_record.isFellowship) count++;
    if (_record.isEvangelism) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC), // slate-950 or slate-50
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: _buildHeader(isDark),
            ),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 120),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: [
                  _buildDisciplineCard(
                    label: '말씀',
                    icon: LucideIcons.bookOpen,
                    keyStr: 'isWord',
                    checked: _record.isWord,
                    memo: _record.wordMemo,
                    isDark: isDark,
                  ),
                  _buildDisciplineCard(
                    label: '기도',
                    icon: LucideIcons.mic,
                    keyStr: 'isPrayer',
                    checked: _record.isPrayer,
                    memo: _record.prayerMemo,
                    isDark: isDark,
                  ),
                  _buildDisciplineCard(
                    label: '교제',
                    icon: LucideIcons.users,
                    keyStr: 'isFellowship',
                    checked: _record.isFellowship,
                    memo: _record.fellowshipMemo,
                    isDark: isDark,
                  ),
                  _buildDisciplineCard(
                    label: '전도',
                    icon: LucideIcons.send,
                    keyStr: 'isEvangelism',
                    checked: _record.isEvangelism,
                    memo: _record.evangelismMemo,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('M월 d일 EEEE', 'ko').format(DateTime.now()),
                  style: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '오늘의 훈련',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark ? null : [
                  BoxShadow(
                    color: const Color(0xFFBFDBFE),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                '${_record.completionRate.round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '진행도',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    '4개 중 $_completedCount개 완료',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              LayoutBuilder(
                builder: (context, constraints) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      height: 12,
                      width: double.infinity,
                      color: isDark ? const Color(0xFF1E3A8A).withOpacity(0.3) : const Color(0xFFDBEAFE),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            width: constraints.maxWidth * (_record.completionRate / 100),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6),
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDisciplineCard({
    required String label,
    required IconData icon,
    required String keyStr,
    required bool checked,
    required String? memo,
    required bool isDark,
  }) {
    bool hasMemo = memo != null && memo.isNotEmpty;

    return GestureDetector(
      onTap: () => _toggleDiscipline(keyStr),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: checked ? const Color(0xFF3B82F6) : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: checked 
              ? Colors.transparent 
              : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
          ),
          boxShadow: checked && !isDark ? [
            const BoxShadow(
              color: Color(0xFFBFDBFE),
              blurRadius: 15,
              offset: Offset(0, 5),
            )
          ] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: checked ? Colors.white.withOpacity(0.2) : (isDark ? const Color(0xFF1E3A8A).withOpacity(0.2) : const Color(0xFFEFF6FF)),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: checked ? Colors.white : const Color(0xFF3B82F6),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: checked ? Colors.white : Colors.transparent,
                    border: Border.all(
                      color: checked ? Colors.white : (isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0)),
                      width: 2,
                    ),
                  ),
                  child: checked 
                    ? const Icon(LucideIcons.checkCircle2, size: 16, color: Color(0xFF3B82F6))
                    : null,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: checked ? Colors.white : (isDark ? Colors.white : const Color(0xFF0F172A)),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (hasMemo)
                      Expanded(
                        child: Row(
                          children: [
                            Icon(LucideIcons.stickyNote, size: 10, color: checked ? Colors.white.withOpacity(0.8) : const Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                memo,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: checked ? Colors.white.withOpacity(0.8) : const Color(0xFF64748B),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    else
                      const SizedBox(height: 14),
                    
                    if (checked)
                      GestureDetector(
                        onTap: () => widget.onMemoOpen(keyStr, _record),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(LucideIcons.edit2, size: 12, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
