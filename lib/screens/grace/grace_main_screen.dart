import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../providers/grace_provider.dart';
import 'morning_routine_screen.dart';
import 'evening_routine_screen.dart';

class GraceMainScreen extends StatefulWidget {
  const GraceMainScreen({Key? key}) : super(key: key);

  @override
  _GraceMainScreenState createState() => _GraceMainScreenState();
}

class _GraceMainScreenState extends State<GraceMainScreen> {
  String? _activeRoutine; // 'morning' or 'evening' or null

  Widget _buildHomeContent(BuildContext context, GraceProvider provider, bool isDark) {
    final todayStatus = provider.todayStatus;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF3B82F6).withOpacity(0.4) : const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.heart, size: 20, color: Color(0xFF3B82F6)),
            ),
            const SizedBox(width: 10),
            Text(
              '그레이스 습관',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Center(
          child: Column(
            children: [
              Text(
                DateFormat('M월 d일 EEEE', 'ko').format(DateTime.now()),
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Text('오늘의 여정', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Streak Card
        Container(
          padding: const EdgeInsets.all(24),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('연속 기록', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 14)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('${provider.streak}', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 40, fontWeight: FontWeight.w900)),
                      const SizedBox(width: 4),
                      Text('일째', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3B82F6).withOpacity(0.2) : const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.award, color: Color(0xFF3B82F6), size: 32),
              )
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Morning Routine Button
        _buildRoutineButton(
          title: '아침 기도',
          desc: '오늘 하루를 기도로 준비하세요',
          icon: LucideIcons.sun,
          iconColor: const Color(0xFFF59E0B),
          timeStr: '06:00',
          isDone: todayStatus.morningDone,
          isDark: isDark,
          onTap: () {
            if (!todayStatus.morningDone) {
              setState(() => _activeRoutine = 'morning');
            }
          },
        ),
        
        const SizedBox(height: 16),
        
        // Evening Routine Button
        _buildRoutineButton(
          title: '저녁 기도',
          desc: '하루를 돌아보며 감사를 나눠요',
          icon: LucideIcons.moon,
          iconColor: const Color(0xFF818CF8),
          timeStr: '22:00',
          isDone: todayStatus.eveningDone,
          isDark: isDark,
          onTap: () {
            if (!todayStatus.eveningDone) {
              setState(() => _activeRoutine = 'evening');
            }
          },
        ),
      ],
    );
  }

  Widget _buildRoutineButton({
    required String title,
    required String desc,
    required IconData icon,
    required Color iconColor,
    required String timeStr,
    required bool isDone,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDone 
            ? (isDark ? const Color(0xFF1E293B).withOpacity(0.5) : const Color(0xFFF1F5F9)) 
            : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDone ? Colors.transparent : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
          boxShadow: [
            if (!isDone && !isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDone ? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)) : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(isDone ? LucideIcons.checkCircle2 : icon, color: isDone ? const Color(0xFF10B981) : iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDone ? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)) : (isDark ? Colors.white : const Color(0xFF0F172A)))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E3A8A).withOpacity(0.3) : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.bell, size: 10, color: Color(0xFF3B82F6)),
                            const SizedBox(width: 4),
                            Text('$timeStr 알림', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6))),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(isDone ? '완료되었습니다' : desc, style: TextStyle(fontSize: 12, color: isDone ? (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)) : const Color(0xFF64748B))),
                ],
              ),
            ),
            if (!isDone)
              const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(LucideIcons.arrowRight, color: Color(0xFFCBD5E1), size: 18),
              )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<GraceProvider>(context);

    // If a routine is active, show it full screen
    if (_activeRoutine == 'morning') {
      return MorningRoutineScreen(
        onCancel: () => setState(() => _activeRoutine = null),
        onComplete: () {
          provider.completeRoutine('morning', {'note': '아침 기도를 마쳤습니다.'});
          setState(() => _activeRoutine = null);
        },
      );
    } else if (_activeRoutine == 'evening') {
      return EveningRoutineScreen(
        onCancel: () => setState(() => _activeRoutine = null),
        onComplete: (data) {
          provider.completeRoutine('evening', data);
          setState(() => _activeRoutine = null);
        },
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100), // extra padding for bottom nav
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                ),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHomeContent(context, provider, isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
