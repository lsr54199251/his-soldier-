import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EveningRoutineScreen extends StatefulWidget {
  final Function(Map<String, String>) onComplete;
  final VoidCallback onCancel;

  const EveningRoutineScreen({Key? key, required this.onComplete, required this.onCancel}) : super(key: key);

  @override
  _EveningRoutineScreenState createState() => _EveningRoutineScreenState();
}

class _EveningRoutineScreenState extends State<EveningRoutineScreen> {
  int _step = 0;
  final Map<String, String> _data = {'gratitude': '', 'concern': '', 'reflection': ''};
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, dynamic>> _steps = [
    {'key': 'gratitude', 'title': '감사한 일', 'desc': '오늘 하루 중 작더라도 감사했던 일을 적어보세요.', 'icon': LucideIcons.heart, 'color': const Color(0xFFFB7185)},
    {'key': 'concern', 'title': '맡기는 걱정', 'desc': '해결되지 않은 고민을 내려놓는 기도를 적습니다.', 'icon': LucideIcons.messageSquare, 'color': const Color(0xFF38BDF8)},
    {'key': 'reflection', 'title': '오늘의 기도 메모', 'desc': '오늘 하루 나를 지탱해준 생각을 기록하세요.', 'icon': LucideIcons.bookOpen, 'color': const Color(0xFF34D399)},
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextStep() {
    final key = _steps[_step]['key'];
    _data[key] = _controller.text;

    if (_step < 2) {
      setState(() {
        _step++;
        _controller.text = _data[_steps[_step]['key']] ?? '';
      });
    } else {
      widget.onComplete(_data);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final current = _steps[_step];

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
                  Row(
                    children: List.generate(3, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 32,
                        height: 6,
                        decoration: BoxDecoration(
                          color: index <= _step ? const Color(0xFF6366F1) : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),
                  _step < 2 ? IconButton(
                    onPressed: _nextStep,
                    icon: const Icon(LucideIcons.arrowRight, color: Color(0xFF6366F1)),
                  ) : const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 48),

              Icon(current['icon'], size: 48, color: current['color']),
              const SizedBox(height: 24),

              Text(current['title'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(current['desc'], style: const TextStyle(color: Color(0xFF64748B))),

              const SizedBox(height: 32),

              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: '이곳에 기록하세요...',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                    ),
                  ),
                ),
              ),

              if (_step == 2) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 10,
                      shadowColor: const Color(0xFF6366F1).withOpacity(0.5),
                    ),
                    child: const Text('저녁 기도 완료', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ));
  }
}
