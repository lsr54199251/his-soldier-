import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  late FaithRecord _record;
  late DateTime _selectedDate;
  final TextEditingController _todoController = TextEditingController();
  final FocusNode _todoFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko', null);
    _record = widget.record;
    _selectedDate = DateTime.parse(_record.date);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.record != widget.record) {
      _record = widget.record;
      _selectedDate = DateTime.parse(_record.date);
    }
  }

  @override
  void dispose() {
    _todoController.dispose();
    _todoFocus.dispose();
    super.dispose();
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

  void _addTodo() {
    final text = _todoController.text.trim();
    if (text.isEmpty) return;
    
    final newItem = CheckItem(id: const Uuid().v4(), text: text);
    final targetDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    if (targetDateStr == _record.date) {
      final updated = _record.copyWith(todos: [newItem, ..._record.todos]);
      widget.onUpdate(updated);
    } else {
      final faithProvider = Provider.of<FaithProvider>(context, listen: false);
      final targetRecord = faithProvider.getRecordForDate(_selectedDate);
      final updatedTarget = targetRecord.copyWith(todos: [newItem, ...targetRecord.todos]);
      faithProvider.updateRecord(updatedTarget);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${DateFormat('M월 d일', 'ko').format(_selectedDate)} 할 일로 추가되었습니다.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
    
    _todoController.clear();
    setState(() {});
  }

  void _toggleTodo(String id) {
    final targetDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    if (targetDateStr == _record.date) {
      final newList = _record.todos.map((t) {
        return t.id == id ? t.copyWith(completed: !t.completed) : t;
      }).toList();
      widget.onUpdate(_record.copyWith(todos: newList));
    } else {
      final faithProvider = Provider.of<FaithProvider>(context, listen: false);
      final targetRecord = faithProvider.getRecordForDate(_selectedDate);
      final newList = targetRecord.todos.map((t) {
        return t.id == id ? t.copyWith(completed: !t.completed) : t;
      }).toList();
      faithProvider.updateRecord(targetRecord.copyWith(todos: newList));
      setState(() {});
    }
  }

  void _deleteTodo(String id) {
    final targetDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    if (targetDateStr == _record.date) {
      final newList = _record.todos.where((t) => t.id != id).toList();
      widget.onUpdate(_record.copyWith(todos: newList));
    } else {
      final faithProvider = Provider.of<FaithProvider>(context, listen: false);
      final targetRecord = faithProvider.getRecordForDate(_selectedDate);
      final newList = targetRecord.todos.where((t) => t.id != id).toList();
      faithProvider.updateRecord(targetRecord.copyWith(todos: newList));
      setState(() {});
    }
  }

  void _moveTodo(int index, int direction) {
    final targetDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    if (targetDateStr == _record.date) {
      final newIndex = index + direction;
      if (newIndex < 0 || newIndex >= _record.todos.length) return;
      final newList = List<CheckItem>.from(_record.todos);
      final temp = newList[index];
      newList[index] = newList[newIndex];
      newList[newIndex] = temp;
      widget.onUpdate(_record.copyWith(todos: newList));
    } else {
      final faithProvider = Provider.of<FaithProvider>(context, listen: false);
      final targetRecord = faithProvider.getRecordForDate(_selectedDate);
      final newIndex = index + direction;
      if (newIndex < 0 || newIndex >= targetRecord.todos.length) return;
      final newList = List<CheckItem>.from(targetRecord.todos);
      final temp = newList[index];
      newList[index] = newList[newIndex];
      newList[newIndex] = temp;
      faithProvider.updateRecord(targetRecord.copyWith(todos: newList));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: _buildHeader(isDark),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                delegate: SliverChildListDelegate([
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
                ]),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                child: _buildChecklist(isDark),
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
                  const BoxShadow(
                    color: Color(0xFFBFDBFE),
                    blurRadius: 15,
                    offset: Offset(0, 5),
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
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF94A3B8),
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
                      color: isDark
                          ? const Color(0xFF1E3A8A).withOpacity(0.3)
                          : const Color(0xFFDBEAFE),
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
                    color: checked
                        ? Colors.white.withOpacity(0.2)
                        : (isDark ? const Color(0xFF1E3A8A).withOpacity(0.2) : const Color(0xFFEFF6FF)),
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
                            Icon(LucideIcons.stickyNote,
                                size: 10,
                                color: checked ? Colors.white.withOpacity(0.8) : const Color(0xFF64748B)),
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

  Widget _buildChecklist(bool isDark) {
    final targetDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    List<CheckItem> todos;
    if (targetDateStr == _record.date) {
      todos = _record.todos;
    } else {
      final faithProvider = Provider.of<FaithProvider>(context);
      todos = faithProvider.getRecordForDate(_selectedDate).todos;
    }

    return Container(
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
          // 타이틀
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF064E3B).withOpacity(0.4)
                      : const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.checkCircle2,
                    size: 20, color: Color(0xFF10B981)),
              ),
              const SizedBox(width: 10),
              Text(
                '체크리스트',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 입력창 및 날짜 선택
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: isDark
                              ? const ColorScheme.dark(
                                  primary: Color(0xFF3B82F6),
                                  onPrimary: Colors.white,
                                  surface: Color(0xFF1E293B),
                                  onSurface: Colors.white,
                                )
                              : const ColorScheme.light(
                                  primary: Color(0xFF3B82F6),
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                  onSurface: Color(0xFF0F172A),
                                ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.calendar, size: 16, color: const Color(0xFF94A3B8)),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('yyyy-MM-dd').format(_selectedDate) == DateFormat('yyyy-MM-dd').format(DateTime.now())
                            ? '오늘'
                            : DateFormat('M/d').format(_selectedDate),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _todoController,
                  focusNode: _todoFocus,
                  onSubmitted: (_) => _addTodo(),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    hintText: '추가할 일을 입력하세요...',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _addTodo,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isDark ? null : [
                      const BoxShadow(
                        color: Color(0xFFBFDBFE),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(LucideIcons.plus, size: 20, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 목록
          if (todos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  '오늘의 할 일이 없습니다.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: todos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final todo = todos[index];
                return _buildTodoItem(todo, index, todos.length, isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTodoItem(CheckItem todo, int index, int total, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? const Color(0xFF0F172A).withOpacity(0.5) : const Color(0xFFF8FAFC),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Row(
        children: [
          // 체크박스
          GestureDetector(
            onTap: () => _toggleTodo(todo.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: todo.completed ? const Color(0xFF10B981) : Colors.transparent,
                border: Border.all(
                  color: todo.completed
                      ? const Color(0xFF10B981)
                      : (isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0)),
                  width: 2,
                ),
              ),
              child: todo.completed
                  ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // 텍스트
          Expanded(
            child: Text(
              todo.text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: todo.completed
                    ? const Color(0xFF94A3B8)
                    : (isDark ? Colors.white : const Color(0xFF334155)),
                decoration: todo.completed ? TextDecoration.lineThrough : null,
                decorationColor: const Color(0xFF94A3B8),
              ),
            ),
          ),

          // 위/아래/삭제 버튼
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _iconBtn(
                icon: LucideIcons.chevronUp,
                onTap: index > 0 ? () => _moveTodo(index, -1) : null,
                isDark: isDark,
              ),
              _iconBtn(
                icon: LucideIcons.chevronDown,
                onTap: index < total - 1 ? () => _moveTodo(index, 1) : null,
                isDark: isDark,
              ),
              _iconBtn(
                icon: LucideIcons.trash2,
                onTap: () => _deleteTodo(todo.id),
                isDark: isDark,
                danger: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isDark,
    bool danger = false,
  }) {
    final bool disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          size: 16,
          color: disabled
              ? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
              : danger
                  ? const Color(0xFFEF4444).withOpacity(0.7)
                  : const Color(0xFF94A3B8),
        ),
      ),
    );
  }
}
