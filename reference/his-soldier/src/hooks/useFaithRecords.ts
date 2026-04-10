import { useState, useEffect } from 'react';
import { format, startOfMonth, endOfMonth, eachDayOfInterval, isSameDay } from 'date-fns';
import { FaithRecord } from '../types';

const STORAGE_KEY = 'his_soldier_records';

export function useFaithRecords() {
  const [records, setRecords] = useState<FaithRecord[]>([]);

  useEffect(() => {
    const saved = localStorage.getItem(STORAGE_KEY);
    if (saved) {
      setRecords(JSON.parse(saved));
    }
  }, []);

  const saveRecords = (newRecords: FaithRecord[]) => {
    setRecords(newRecords);
    localStorage.setItem(STORAGE_KEY, JSON.stringify(newRecords));
  };

  const getRecordForDate = (date: Date) => {
    const dateStr = format(date, 'yyyy-MM-dd');
    return records.find(r => r.date === dateStr) || {
      id: crypto.randomUUID(),
      date: dateStr,
      isWord: false,
      isPrayer: false,
      isFellowship: false,
      isEvangelism: false,
    };
  };

  const updateRecord = (record: FaithRecord) => {
    const index = records.findIndex(r => r.date === record.date);
    let newRecords;
    if (index >= 0) {
      newRecords = [...records];
      newRecords[index] = record;
    } else {
      newRecords = [...records, record];
    }
    saveRecords(newRecords);
  };

  return { records, getRecordForDate, updateRecord };
}
