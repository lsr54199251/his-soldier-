import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PrayerJournalScreen extends StatefulWidget {
  const PrayerJournalScreen({Key? key}) : super(key: key);

  @override
  State<PrayerJournalScreen> createState() => _PrayerJournalScreenState();
}

class _PrayerJournalScreenState extends State<PrayerJournalScreen> {
  DateTime _selectedDate = DateTime.now();
  late SharedPreferences _prefs;
  bool _isLoading = true;

  final List<String> _quotes = [
    "기도는 아침의 열쇠이고 밤의 자물쇠입니다",
    "기도 없는 하루는 은혜와 축복이 없는 하루이며, 기도 없는 일생은 주님의 도우심과 인도가 없는 일생입니다",
    "하나님과 함께 한 1시간은 사람과 함께 한 일생보다 더 큰 가치가 있습니다",
    "성경은 우리에게 항상 설교해야 한다고 말하지 않지만, 항상 기도해야 한다고 말하고 있습니다",
    "그리스도인들이 기도에 게으르기 때문에 복음은 느린 속도로 전해지고 있습니다",
    "만일 기도가 그대의 생활에서 죄를 다스리지 않는다면 죄가 기도를 다스릴 것입니다",
    "우리 모두는 기도할 마음을 가지고 있지만 기도하는 사람은 아주 적습니다",
    "기도는 하나님이 원하지 않는 것을 억지로 빼앗는 것이 아니라 하나님이 기꺼이 주시는 것을 받는 것입니다"
  ];

  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (int i = 1; i <= 13; i++) {
      _controllers['p$i'] = TextEditingController();
    }
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadData();
    setState(() {
      _isLoading = false;
    });
  }

  void _loadData() {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    for (int i = 1; i <= 13; i++) {
      final key = 'prayer_journal_${dateStr}_p$i';
      final value = _prefs.getString(key) ?? '';
      _controllers['p$i']!.text = value;
    }
  }

  void _saveData(String id, String value) {
    if (_isLoading) return;
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final key = 'prayer_journal_${dateStr}_$id';
    _prefs.setString(key, value);
  }

  String _getQuote() {
    final days = _selectedDate.millisecondsSinceEpoch ~/ (1000 * 60 * 60 * 24);
    return _quotes[days % _quotes.length];
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E3A8A).withOpacity(0.4)
                  : const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.bookOpen,
                size: 20, color: Color(0xFF3B82F6)),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String id, String label, String hint, bool isDark, {int minLines = 2}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _controllers[id],
          onChanged: (val) => _saveData(id, val),
          maxLines: null,
          minLines: minLines,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
            ),
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
              borderSide: const BorderSide(
                color: Color(0xFF3B82F6),
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E3A8A).withOpacity(0.4) : const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(LucideIcons.book, size: 20, color: Color(0xFF3B82F6)),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '기도수첩',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text(
                    DateFormat('yyyy.MM.dd').format(DateTime.now()),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    alignment: Alignment.center,
                    child: Text(
                      '"${_getQuote()}"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5),
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),

                  _buildSectionTitle('1. 찬양과 감사', isDark),
                  _buildTextField('p1', '찬양 부름', '찬양 가사나 고백 한 줄...', isDark),
                  _buildTextField('p2', '영혼 구원에 대한 감사', '구원하신 은혜에 대하여...', isDark),
                  _buildTextField('p3', '기도 응답에 대한 감사', '오늘의 구체적인 감사...', isDark),

                  _buildSectionTitle('2. 자복과 회개', isDark),
                  _buildTextField('p4', '고범죄(알고 지은 죄)에 대한 자복/통회', '통회하는 마음으로...', isDark),
                  _buildTextField('p5', '부지불식간(모르고 지은 죄)의 자백', '연약함을 고백합니다...', isDark),
                  _buildTextField('p6', '선악간의 죄 / 상처 준 형제자매 용서', '주님의 마음으로 품습니다...', isDark),

                  _buildSectionTitle('3. 중보 기도', isDark),
                  _buildTextField('p7', '전도집회 및 교회 행사', '사역의 열매를 위해...', isDark),
                  _buildTextField('p8', '교구, 구역, 전국·해외 교회', '교회 공동체를 위해...', isDark),
                  _buildTextField('p9', '전도 대상자 (태신자) 기도', '그 이름을 불러가며...', isDark),
                  _buildTextField('p10', '기도 부탁 / 조용히 중보할 이들', '함께 짐을 지는 마음으로...', isDark),
                  _buildTextField('p11', '직분자 및 가족 기도', '강건함과 평안을 위해...', isDark),

                  _buildSectionTitle('4. 간구와 신앙 성장', isDark),
                  _buildTextField('p12', '개인적인 간구', '주님께 맡기는 제목...', isDark),
                  _buildTextField('p13', '자신의 신앙 성장을 위한 기도', '더 깊은 믿음을 위해...', isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
