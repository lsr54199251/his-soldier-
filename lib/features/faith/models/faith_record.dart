class CheckItem {
  final String id;
  final String text;
  final bool completed;

  const CheckItem({
    required this.id,
    required this.text,
    this.completed = false,
  });

  CheckItem copyWith({String? id, String? text, bool? completed}) {
    return CheckItem(
      id: id ?? this.id,
      text: text ?? this.text,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'text': text, 'completed': completed};

  factory CheckItem.fromJson(Map<String, dynamic> json) {
    return CheckItem(
      id: json['id'] as String,
      text: json['text'] as String,
      completed: json['completed'] as bool? ?? false,
    );
  }
}

class FaithRecord {
  final String id;
  final String date; // YYYY-MM-DD
  final bool isWord;
  final bool isPrayer;
  final bool isFellowship;
  final bool isEvangelism;
  final String? wordMemo;
  final String? prayerMemo;
  final String? fellowshipMemo;
  final String? evangelismMemo;
  final String? bibleMemo;
  final List<CheckItem> todos;

  FaithRecord({
    required this.id,
    required this.date,
    this.isWord = false,
    this.isPrayer = false,
    this.isFellowship = false,
    this.isEvangelism = false,
    this.wordMemo,
    this.prayerMemo,
    this.fellowshipMemo,
    this.evangelismMemo,
    this.bibleMemo,
    this.todos = const [],
  });

  FaithRecord copyWith({
    String? id,
    String? date,
    bool? isWord,
    bool? isPrayer,
    bool? isFellowship,
    bool? isEvangelism,
    String? wordMemo,
    String? prayerMemo,
    String? fellowshipMemo,
    String? evangelismMemo,
    String? bibleMemo,
    List<CheckItem>? todos,
  }) {
    return FaithRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      isWord: isWord ?? this.isWord,
      isPrayer: isPrayer ?? this.isPrayer,
      isFellowship: isFellowship ?? this.isFellowship,
      isEvangelism: isEvangelism ?? this.isEvangelism,
      wordMemo: wordMemo ?? this.wordMemo,
      prayerMemo: prayerMemo ?? this.prayerMemo,
      fellowshipMemo: fellowshipMemo ?? this.fellowshipMemo,
      evangelismMemo: evangelismMemo ?? this.evangelismMemo,
      bibleMemo: bibleMemo ?? this.bibleMemo,
      todos: todos ?? this.todos,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'isWord': isWord,
      'isPrayer': isPrayer,
      'isFellowship': isFellowship,
      'isEvangelism': isEvangelism,
      'wordMemo': wordMemo,
      'prayerMemo': prayerMemo,
      'fellowshipMemo': fellowshipMemo,
      'evangelismMemo': evangelismMemo,
      'bibleMemo': bibleMemo,
      'todos': todos.map((t) => t.toJson()).toList(),
    };
  }

  factory FaithRecord.fromJson(Map<String, dynamic> json) {
    final rawTodos = json['todos'];
    final todos = rawTodos is List
        ? rawTodos.map((e) => CheckItem.fromJson(e as Map<String, dynamic>)).toList()
        : <CheckItem>[];
    return FaithRecord(
      id: json['id'] as String,
      date: json['date'] as String,
      isWord: json['isWord'] as bool? ?? false,
      isPrayer: json['isPrayer'] as bool? ?? false,
      isFellowship: json['isFellowship'] as bool? ?? false,
      isEvangelism: json['isEvangelism'] as bool? ?? false,
      wordMemo: json['wordMemo'] as String?,
      prayerMemo: json['prayerMemo'] as String?,
      fellowshipMemo: json['fellowshipMemo'] as String?,
      evangelismMemo: json['evangelismMemo'] as String?,
      bibleMemo: json['bibleMemo'] as String?,
      todos: todos,
    );
  }

  double get completionRate {
    int count = 0;
    if (isWord) count++;
    if (isPrayer) count++;
    if (isFellowship) count++;
    if (isEvangelism) count++;
    return (count / 4) * 100;
  }
}
