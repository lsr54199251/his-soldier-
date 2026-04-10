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
    };
  }

  factory FaithRecord.fromJson(Map<String, dynamic> json) {
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
