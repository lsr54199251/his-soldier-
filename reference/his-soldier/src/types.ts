export interface FaithRecord {
  id: string;
  date: string; // ISO format YYYY-MM-DD
  isWord: boolean;
  isPrayer: boolean;
  isFellowship: boolean;
  isEvangelism: boolean;
  wordMemo?: string;
  prayerMemo?: string;
  fellowshipMemo?: string;
  evangelismMemo?: string;
}

export type DisciplineKey = 'isWord' | 'isPrayer' | 'isFellowship' | 'isEvangelism';
export type MemoKey = 'wordMemo' | 'prayerMemo' | 'fellowshipMemo' | 'evangelismMemo';

export const DISCIPLINES: { key: DisciplineKey; memoKey: MemoKey; label: string; icon: string }[] = [
  { key: 'isWord', memoKey: 'wordMemo', label: '말씀', icon: 'BookOpen' },
  { key: 'isPrayer', memoKey: 'prayerMemo', label: '기도', icon: 'Mic' },
  { key: 'isFellowship', memoKey: 'fellowshipMemo', label: '교제', icon: 'Users' },
  { key: 'isEvangelism', memoKey: 'evangelismMemo', label: '전도', icon: 'Send' },
];

export function calculateCompletionRate(record: FaithRecord): number {
  const tasks = [record.isWord, record.isPrayer, record.isFellowship, record.isEvangelism];
  const completed = tasks.filter(Boolean).length;
  return (completed / tasks.length) * 100;
}
