import 'dart:async';
import 'package:flutter/material.dart';

class MorningRoutineScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const MorningRoutineScreen({Key? key, required this.onComplete, required this.onCancel}) : super(key: key);

  @override
  _MorningRoutineScreenState createState() => _MorningRoutineScreenState();
}

class _MorningRoutineScreenState extends State<MorningRoutineScreen> {
  static const int INITIAL_TIME = 600; // 10 minutes
  int _timer = INITIAL_TIME;
  bool _isActive = false;
  Timer? _timerObj;

  @override
  void dispose() {
    _timerObj?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isActive) {
      _timerObj?.cancel();
      setState(() {
        _isActive = false;
      });
    } else {
      if (_timer > 0) {
        setState(() {
          _isActive = true;
        });
        _timerObj = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_timer > 0) {
            setState(() {
              _timer--;
            });
          } else {
            timer.cancel();
            setState(() {
              _isActive = false;
            });
          }
        });
      }
    }
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          widget.onCancel();
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
        body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('취소', style: TextStyle(color: Color(0xFF94A3B8))),
                  ),
                  Container(
                    width: 32,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 48),

              const Text('아침 기도: 10분', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('평안한 마음으로 오늘 하루의 시작을 기도로 채워보세요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B))),

              const Spacer(),

              SizedBox(
                width: 240,
                height: 240,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 8,
                      valueColor: AlwaysStoppedAnimation<Color>(isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                    ),
                    CircularProgressIndicator(
                      value: _timer / INITIAL_TIME,
                      strokeWidth: 8,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_formatTime(_timer), style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, letterSpacing: -2)),
                          const Text('남은 시간', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              OutlinedButton(
                onPressed: _toggleTimer,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF6366F1), width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  foregroundColor: const Color(0xFF6366F1),
                ),
                child: Text(_isActive ? '잠시 멈춤' : _timer == INITIAL_TIME ? '기도 시작' : _timer == 0 ? '기도 완료' : '다시 계속',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_timer > 0 && !_isActive && _timer != INITIAL_TIME) || _timer == 0 ? widget.onComplete : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 10,
                    shadowColor: const Color(0xFF6366F1).withOpacity(0.5),
                  ),
                  child: Text(_timer == 0 ? '기도 완료' : '지금 완료하기', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
