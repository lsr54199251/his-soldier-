import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/faith_record.dart';

class HistoryScreen extends StatefulWidget {
  final List<FaithRecord> records;
  final Function(DateTime) onEditDate;

  const HistoryScreen({
    Key? key,
    required this.records,
    required this.onEditDate,
  }) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 24, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '히스토리',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 24),
              _buildCalendarHeader(isDark),
              const SizedBox(height: 20),
              _buildDaysOfWeek(isDark),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 120),
                  children: [
                    _buildCalendarGrid(isDark),
                    const SizedBox(height: 32),
                    _buildLegend(isDark),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: _prevMonth,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: Icon(LucideIcons.chevronLeft, size: 20, color: isDark ? Colors.white : const Color(0xFF0F172A)),
          ),
        ),
        Text(
          DateFormat('yyyy년 M월').format(_focusedMonth),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        GestureDetector(
          onTap: _nextMonth,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: Icon(LucideIcons.chevronRight, size: 20, color: isDark ? Colors.white : const Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }

  Widget _buildDaysOfWeek(bool isDark) {
    const days = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: day == '일' 
                    ? const Color(0xFFEF4444)
                    : day == '토' 
                        ? const Color(0xFF3B82F6) 
                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid(bool isDark) {
    int daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    int firstWeekday = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday;
    int startOffset = firstWeekday == 7 ? 0 : firstWeekday;

    int totalCells = daysInMonth + startOffset;
    int totalRows = (totalCells / 7).ceil();

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: totalRows * 7,
      itemBuilder: (context, index) {
        if (index < startOffset || index >= totalCells) {
          return const SizedBox.shrink();
        }

        int day = index - startOffset + 1;
        DateTime cellDate = DateTime(_focusedMonth.year, _focusedMonth.month, day);
        bool isToday = DateFormat('yyyy-MM-dd').format(cellDate) == DateFormat('yyyy-MM-dd').format(DateTime.now());

        return _buildDayCell(isDark, cellDate, isToday);
      },
    );
  }

  Widget _buildDayCell(bool isDark, DateTime date, bool isToday) {
    String dateStr = DateFormat('yyyy-MM-dd').format(date);
    double rate = 0.0;
    try {
      final record = widget.records.firstWhere((r) => r.date == dateStr);
      rate = record.completionRate;
    } catch (_) {}

    Color bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    Color textColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    if (rate > 0) {
      if (rate <= 25) {
        bgColor = const Color(0xFF3B82F6).withOpacity(0.2);
        textColor = isDark ? Colors.white : const Color(0xFF1D4ED8);
        borderColor = Colors.transparent;
      } else if (rate <= 50) {
        bgColor = const Color(0xFF3B82F6).withOpacity(0.4);
        textColor = isDark ? Colors.white : const Color(0xFF1E3A8A);
        borderColor = Colors.transparent;
      } else if (rate <= 75) {
        bgColor = const Color(0xFF3B82F6).withOpacity(0.7);
        textColor = Colors.white;
        borderColor = Colors.transparent;
      } else {
        bgColor = const Color(0xFF3B82F6);
        textColor = Colors.white;
        borderColor = Colors.transparent;
      }
    }

    if (isToday) {
      borderColor = const Color(0xFF3B82F6);
    }

    return GestureDetector(
      onTap: () => widget.onEditDate(date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: isToday ? 2 : 1,
          ),
          boxShadow: rate == 100 && !isDark ? [
            BoxShadow(
              color: const Color(0xFFBFDBFE),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ] : [],
        ),
        child: Center(
          child: Text(
            date.day.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: rate > 0 || isToday ? FontWeight.w900 : FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '달성도 (히트맵)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          Row(
            children: [
              _buildLegendDot(const Color(0xFF3B82F6).withOpacity(0.2)),
              const SizedBox(width: 4),
              _buildLegendDot(const Color(0xFF3B82F6).withOpacity(0.4)),
              const SizedBox(width: 4),
              _buildLegendDot(const Color(0xFF3B82F6).withOpacity(0.7)),
              const SizedBox(width: 4),
              _buildLegendDot(const Color(0xFF3B82F6)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
