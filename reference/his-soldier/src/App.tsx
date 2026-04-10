import { useState, useMemo, MouseEvent } from 'react';
import { format, startOfMonth, endOfMonth, eachDayOfInterval, isSameDay, parseISO } from 'date-fns';
import { ko } from 'date-fns/locale';
import { 
  Home, 
  BarChart2, 
  History, 
  BookOpen, 
  Mic, 
  Users, 
  Send,
  CheckCircle2,
  ChevronRight,
  Search,
  Filter,
  StickyNote,
  X
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { 
  LineChart, 
  Line, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer,
  AreaChart,
  Area
} from 'recharts';
import { cn } from '@/src/lib/utils';
import { FaithRecord, DISCIPLINES, calculateCompletionRate, DisciplineKey } from './types';
import { useFaithRecords } from './hooks/useFaithRecords';

// --- Components ---

const ProgressBar = ({ progress }: { progress: number }) => (
  <div className="w-full bg-blue-100 dark:bg-blue-900/30 rounded-full h-3 overflow-hidden">
    <motion.div 
      className="bg-blue-500 h-full rounded-full"
      initial={{ width: 0 }}
      animate={{ width: `${progress}%` }}
      transition={{ type: "spring", stiffness: 50, damping: 15 }}
    />
  </div>
);

const DisciplineCard = ({ 
  label, 
  icon: Icon, 
  checked, 
  onToggle,
  onMemoClick,
  hasMemo
}: { 
  label: string; 
  icon: any; 
  checked: boolean; 
  onToggle: () => void;
  onMemoClick: (e: MouseEvent) => void;
  hasMemo: boolean;
}) => (
  <motion.div 
    whileTap={{ scale: 0.98 }}
    onClick={onToggle}
    className={cn(
      "flex items-center justify-between p-3.5 rounded-[1.5rem] cursor-pointer transition-all duration-300",
      checked 
        ? "bg-blue-500 text-white shadow-lg shadow-blue-200 dark:shadow-none" 
        : "bg-white dark:bg-slate-800 border border-slate-100 dark:border-slate-700"
    )}
  >
    <div className="flex items-center gap-3">
      <div className={cn(
        "p-2 rounded-xl",
        checked ? "bg-white/20" : "bg-blue-50 dark:bg-blue-900/20 text-blue-500"
      )}>
        <Icon size={18} />
      </div>
      <div className="flex flex-col">
        <span className="font-black text-sm leading-tight">{label}</span>
        {hasMemo && (
          <span className="text-[8px] opacity-80 flex items-center gap-1 mt-0.5 font-bold">
            <StickyNote size={8} /> 기록됨
          </span>
        )}
      </div>
    </div>
    <div className="flex items-center gap-2">
      {checked && (
        <button 
          onClick={onMemoClick}
          className={cn(
            "p-1.5 rounded-lg transition-colors",
            checked ? "bg-white/20 hover:bg-white/30" : "bg-slate-100 dark:bg-slate-700"
          )}
        >
          <StickyNote size={16} />
        </button>
      )}
      <div className={cn(
        "w-5 h-5 rounded-full border-2 flex items-center justify-center transition-colors",
        checked ? "bg-white border-white" : "border-slate-200 dark:border-slate-600"
      )}>
        {checked && <CheckCircle2 size={14} className="text-blue-500" />}
      </div>
    </div>
  </motion.div>
);

// --- Screens ---

const HomeScreen = ({ 
  record, 
  onUpdate,
  onMemoOpen
}: { 
  record: FaithRecord; 
  onUpdate: (r: FaithRecord) => void;
  onMemoOpen: (key: DisciplineKey) => void;
}) => {
  const completionRate = calculateCompletionRate(record);

  const toggleDiscipline = (key: DisciplineKey) => {
    onUpdate({ ...record, [key]: !record[key] });
  };

  return (
    <div className="flex flex-col h-screen max-h-screen overflow-hidden bg-slate-50 dark:bg-slate-950">
      <header className="px-5 pt-5 pb-3">
        <div className="flex justify-between items-center mb-3">
          <div>
            <motion.p 
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              className="text-slate-500 dark:text-slate-400 text-[10px] font-bold uppercase tracking-wider"
            >
              {format(new Date(), 'M월 d일 EEEE', { locale: ko })}
            </motion.p>
            <motion.h1 
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.1 }}
              className="text-xl font-black text-slate-900 dark:text-white"
            >
              오늘의 훈련
            </motion.h1>
          </div>
          <motion.div 
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            className="bg-blue-500 text-white px-4 py-1.5 rounded-2xl shadow-lg shadow-blue-200 dark:shadow-none"
          >
            <span className="text-lg font-black">{Math.round(completionRate)}%</span>
          </motion.div>
        </div>
        
        <motion.div 
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="bg-white dark:bg-slate-800 p-3.5 rounded-[1.5rem] shadow-sm border border-slate-100 dark:border-slate-700"
        >
          <div className="flex justify-between items-center mb-1.5">
            <span className="text-slate-500 dark:text-slate-400 text-[10px] font-black">진행도</span>
            <span className="text-slate-400 text-[9px] font-bold">4개 중 {Object.values(record).filter(v => v === true).length}개 완료</span>
          </div>
          <ProgressBar progress={completionRate} />
        </motion.div>
      </header>

      <section className="px-5 flex flex-col gap-2.5 flex-1 overflow-hidden pb-28">
        {DISCIPLINES.map((d, i) => {
          const Icon = d.key === 'isWord' ? BookOpen : d.key === 'isPrayer' ? Mic : d.key === 'isFellowship' ? Users : Send;
          const memoKey = d.memoKey;
          return (
            <motion.div
              key={d.key}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.3 + i * 0.1 }}
            >
              <DisciplineCard 
                label={d.label}
                icon={Icon}
                checked={record[d.key as DisciplineKey]}
                onToggle={() => toggleDiscipline(d.key as DisciplineKey)}
                onMemoClick={(e) => {
                  e.stopPropagation();
                  onMemoOpen(d.key as DisciplineKey);
                }}
                hasMemo={!!record[memoKey]}
              />
            </motion.div>
          );
        })}
      </section>
    </div>
  );
};

const StatsScreen = ({ records }: { records: FaithRecord[] }) => {
  const chartData = useMemo(() => {
    const today = new Date();
    const start = startOfMonth(today);
    const end = endOfMonth(today);
    const days = eachDayOfInterval({ start, end });

    return days.map(day => {
      const dateStr = format(day, 'yyyy-MM-dd');
      const record = records.find(r => r.date === dateStr);
      return {
        name: format(day, 'd'),
        rate: record ? calculateCompletionRate(record) : 0,
        fullDate: format(day, 'M/d')
      };
    });
  }, [records]);

  const avgRate = useMemo(() => {
    const currentMonthRecords = records.filter(r => {
      const date = parseISO(r.date);
      const now = new Date();
      return date.getMonth() === now.getMonth() && date.getFullYear() === now.getFullYear();
    });
    if (currentMonthRecords.length === 0) return 0;
    const sum = currentMonthRecords.reduce((acc, r) => acc + calculateCompletionRate(r), 0);
    return sum / currentMonthRecords.length;
  }, [records]);

  return (
    <div className="flex flex-col h-screen max-h-screen overflow-hidden px-5 pt-6">
      <h1 className="text-2xl font-bold text-slate-900 dark:text-white mb-4">월간 통계</h1>
      
      <div className="flex-1 overflow-y-auto pb-32 flex flex-col gap-4">
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="bg-white dark:bg-slate-800 p-4 rounded-3xl shadow-sm border border-slate-100 dark:border-slate-700 h-48 shrink-0"
        >
          <p className="text-slate-500 dark:text-slate-400 text-xs font-bold mb-2">일별 완료율 추이</p>
          <ResponsiveContainer width="100%" height="100%">
            <AreaChart data={chartData}>
              <defs>
                <linearGradient id="colorRate" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#3b82f6" stopOpacity={0.3}/>
                  <stop offset="95%" stopColor="#3b82f6" stopOpacity={0}/>
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
              <XAxis 
                dataKey="name" 
                axisLine={false} 
                tickLine={false} 
                tick={{ fontSize: 8, fill: '#94a3b8' }}
                interval={4}
              />
              <Tooltip 
                contentStyle={{ borderRadius: '1rem', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)', fontSize: '12px' }}
                labelStyle={{ fontWeight: 'bold' }}
              />
              <Area 
                type="monotone" 
                dataKey="rate" 
                stroke="#3b82f6" 
                strokeWidth={2}
                fillOpacity={1} 
                fill="url(#colorRate)" 
              />
            </AreaChart>
          </ResponsiveContainer>
        </motion.div>

        <div className="grid grid-cols-2 gap-3">
          <motion.div 
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.2 }}
            className="bg-blue-500 p-4 rounded-3xl text-white"
          >
            <p className="text-blue-100 text-[10px] font-medium mb-1">이번 달 평균</p>
            <h3 className="text-xl font-bold">{Math.round(avgRate)}%</h3>
          </motion.div>
          <motion.div 
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.3 }}
            className="bg-white dark:bg-slate-800 p-4 rounded-3xl border border-slate-100 dark:border-slate-700"
          >
            <p className="text-slate-500 dark:text-slate-400 text-[10px] font-medium mb-1">기록된 일수</p>
            <h3 className="text-xl font-bold text-slate-900 dark:text-white">
              {records.filter(r => {
                const d = parseISO(r.date);
                const now = new Date();
                return d.getMonth() === now.getMonth();
              }).length}일
            </h3>
          </motion.div>
        </div>

        <div className="flex flex-col gap-2">
          <h3 className="font-bold text-slate-900 dark:text-white text-sm px-1">이번 달 기록</h3>
          {chartData.filter(d => d.rate > 0).reverse().map((d, i) => (
            <div key={i} className="flex items-center justify-between p-3 bg-white dark:bg-slate-800 rounded-2xl border border-slate-50 dark:border-slate-700">
              <span className="text-xs font-bold text-slate-600 dark:text-slate-300">{d.fullDate}</span>
              <div className="flex items-center gap-2">
                <div className="w-16 bg-slate-100 dark:bg-slate-700 h-1.5 rounded-full overflow-hidden">
                  <div className="bg-blue-500 h-full" style={{ width: `${d.rate}%` }} />
                </div>
                <span className="text-[10px] font-black text-blue-500">{d.rate}%</span>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

const HistoryScreen = ({ 
  records, 
  onEdit 
}: { 
  records: FaithRecord[]; 
  onEdit: (r: FaithRecord) => void 
}) => {
  const sortedRecords = [...records].sort((a, b) => b.date.localeCompare(a.date));

  return (
    <div className="flex flex-col h-screen max-h-screen overflow-hidden px-5 pt-6">
      <div className="flex items-center justify-between mb-4">
        <h1 className="text-2xl font-bold text-slate-900 dark:text-white">히스토리</h1>
        <div className="flex gap-2">
          <button className="p-1.5 bg-slate-100 dark:bg-slate-800 rounded-full text-slate-500">
            <Search size={18} />
          </button>
          <button className="p-1.5 bg-slate-100 dark:bg-slate-800 rounded-full text-slate-500">
            <Filter size={18} />
          </button>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto pb-32 flex flex-col gap-3">
        {sortedRecords.length === 0 ? (
          <div className="py-20 text-center text-slate-400">
            <p className="text-sm">아직 기록이 없습니다.</p>
          </div>
        ) : (
          sortedRecords.map((record, i) => (
            <motion.div
              key={record.id}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.05 }}
              onClick={() => onEdit(record)}
              className="bg-white dark:bg-slate-800 p-4 rounded-3xl border border-slate-100 dark:border-slate-700 flex items-center justify-between cursor-pointer active:scale-[0.98] transition-transform"
            >
              <div className="flex flex-col gap-1">
                <span className="font-bold text-sm text-slate-900 dark:text-white">
                  {format(parseISO(record.date), 'M월 d일 (E)', { locale: ko })}
                </span>
                <div className="flex gap-1.5">
                  {DISCIPLINES.map(d => {
                    const Icon = d.key === 'isWord' ? BookOpen : d.key === 'isPrayer' ? Mic : d.key === 'isFellowship' ? Users : Send;
                    return (
                      <div 
                        key={d.key} 
                        className={cn(
                          "p-0.5 rounded",
                          record[d.key] ? "text-blue-500 bg-blue-50 dark:bg-blue-900/10" : "text-slate-200 dark:text-slate-700"
                        )}
                      >
                        <Icon size={12} />
                      </div>
                    );
                  })}
                </div>
              </div>
              <div className="flex items-center gap-2">
                <span className="text-base font-black text-blue-500">{Math.round(calculateCompletionRate(record))}%</span>
                <ChevronRight size={16} className="text-slate-300" />
              </div>
            </motion.div>
          ))
        )}
      </div>
    </div>
  );
};

// --- Main App ---

export default function App() {
  const [activeTab, setActiveTab] = useState<'home' | 'stats' | 'history'>('home');
  const { records, getRecordForDate, updateRecord } = useFaithRecords();
  const [editingRecord, setEditingRecord] = useState<FaithRecord | null>(null);
  const [memoTarget, setMemoTarget] = useState<{ record: FaithRecord; key: DisciplineKey } | null>(null);
  const [memoText, setMemoText] = useState('');

  const todayRecord = getRecordForDate(new Date());

  const openMemo = (record: FaithRecord, key: DisciplineKey) => {
    const discipline = DISCIPLINES.find(d => d.key === key);
    if (!discipline) return;
    setMemoTarget({ record, key });
    setMemoText(record[discipline.memoKey] || '');
  };

  const saveMemo = () => {
    if (!memoTarget) return;
    const discipline = DISCIPLINES.find(d => d.key === memoTarget.key);
    if (!discipline) return;
    
    const updatedRecord = {
      ...memoTarget.record,
      [discipline.memoKey]: memoText
    };
    updateRecord(updatedRecord);
    
    // If we were editing in history, update that state too
    if (editingRecord && editingRecord.id === updatedRecord.id) {
      setEditingRecord(updatedRecord);
    }
    
    setMemoTarget(null);
  };

  return (
    <div className="min-h-screen bg-slate-50 dark:bg-slate-950 text-slate-900 dark:text-slate-100 font-sans selection:bg-blue-100 selection:text-blue-600">
      <main className="max-w-md mx-auto min-h-screen relative overflow-hidden">
        <AnimatePresence mode="wait">
          {activeTab === 'home' && (
            <motion.div
              key="home"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              transition={{ duration: 0.2 }}
            >
              <HomeScreen 
                record={todayRecord} 
                onUpdate={updateRecord} 
                onMemoOpen={(key) => openMemo(todayRecord, key)}
              />
            </motion.div>
          )}
          {activeTab === 'stats' && (
            <motion.div
              key="stats"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              transition={{ duration: 0.2 }}
            >
              <StatsScreen records={records} />
            </motion.div>
          )}
          {activeTab === 'history' && (
            <motion.div
              key="history"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              transition={{ duration: 0.2 }}
            >
              <HistoryScreen records={records} onEdit={setEditingRecord} />
            </motion.div>
          )}
        </AnimatePresence>

        {/* Bottom Navigation */}
        <nav className="fixed bottom-4 left-1/2 -translate-x-1/2 w-[calc(100%-2.5rem)] max-w-[calc(448px-2.5rem)] bg-white/80 dark:bg-slate-900/80 backdrop-blur-xl border border-white/20 dark:border-slate-800/50 rounded-[2rem] p-1.5 flex justify-around items-center shadow-2xl z-50">
          <button 
            onClick={() => setActiveTab('home')}
            className={cn(
              "flex flex-col items-center gap-0.5 p-2.5 rounded-[1.5rem] transition-all duration-300 flex-1",
              activeTab === 'home' ? "bg-blue-500 text-white shadow-lg shadow-blue-200 dark:shadow-none" : "text-slate-400"
            )}
          >
            <Home size={20} />
            <span className="text-[9px] font-black">홈</span>
          </button>
          <button 
            onClick={() => setActiveTab('stats')}
            className={cn(
              "flex flex-col items-center gap-0.5 p-2.5 rounded-[1.5rem] transition-all duration-300 flex-1",
              activeTab === 'stats' ? "bg-blue-500 text-white shadow-lg shadow-blue-200 dark:shadow-none" : "text-slate-400"
            )}
          >
            <BarChart2 size={20} />
            <span className="text-[9px] font-black">통계</span>
          </button>
          <button 
            onClick={() => setActiveTab('history')}
            className={cn(
              "flex flex-col items-center gap-0.5 p-2.5 rounded-[1.5rem] transition-all duration-300 flex-1",
              activeTab === 'history' ? "bg-blue-500 text-white shadow-lg shadow-blue-200 dark:shadow-none" : "text-slate-400"
            )}
          >
            <History size={20} />
            <span className="text-[9px] font-black">히스토리</span>
          </button>
        </nav>

        {/* Edit Bottom Sheet */}
        <AnimatePresence>
          {editingRecord && (
            <>
              <motion.div 
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                onClick={() => setEditingRecord(null)}
                className="fixed inset-0 bg-black/40 backdrop-blur-sm z-[60]"
              />
              <motion.div 
                initial={{ y: "100%" }}
                animate={{ y: 0 }}
                exit={{ y: "100%" }}
                transition={{ type: "spring", damping: 25, stiffness: 200 }}
                className="fixed bottom-0 left-0 right-0 bg-white dark:bg-slate-900 rounded-t-[3rem] p-8 z-[70] shadow-2xl max-w-md mx-auto"
              >
                <div className="w-12 h-1.5 bg-slate-200 dark:bg-slate-800 rounded-full mx-auto mb-8" />
                <h3 className="text-2xl font-bold mb-6">
                  {format(parseISO(editingRecord.date), 'M월 d일 기록 수정', { locale: ko })}
                </h3>
                <div className="flex flex-col gap-4 mb-8">
                  {DISCIPLINES.map(d => {
                    const Icon = d.key === 'isWord' ? BookOpen : d.key === 'isPrayer' ? Mic : d.key === 'isFellowship' ? Users : Send;
                    return (
                      <div 
                        key={d.key}
                        className={cn(
                          "flex items-center justify-between p-4 rounded-2xl border transition-all",
                          editingRecord[d.key] 
                            ? "bg-blue-50 border-blue-200 dark:bg-blue-900/20 dark:border-blue-800" 
                            : "bg-slate-50 border-slate-100 dark:bg-slate-800 dark:border-slate-700"
                        )}
                      >
                        <div 
                          className="flex items-center gap-3 flex-1 cursor-pointer"
                          onClick={() => setEditingRecord({ ...editingRecord, [d.key]: !editingRecord[d.key] })}
                        >
                          <Icon size={20} className={editingRecord[d.key] ? "text-blue-500" : "text-slate-400"} />
                          <div className="flex flex-col">
                            <span className="font-semibold">{d.label}</span>
                            {editingRecord[d.memoKey] && (
                              <span className="text-[10px] text-slate-500 dark:text-slate-400 truncate max-w-[150px]">
                                {editingRecord[d.memoKey]}
                              </span>
                            )}
                          </div>
                        </div>
                        <div className="flex items-center gap-3">
                          {editingRecord[d.key] && (
                            <button 
                              onClick={() => openMemo(editingRecord, d.key as DisciplineKey)}
                              className="p-2 bg-slate-200 dark:bg-slate-700 rounded-xl text-slate-600 dark:text-slate-300"
                            >
                              <StickyNote size={18} />
                            </button>
                          )}
                          <div 
                            onClick={() => setEditingRecord({ ...editingRecord, [d.key]: !editingRecord[d.key] })}
                            className={cn(
                              "w-6 h-6 rounded-full border-2 flex items-center justify-center cursor-pointer",
                              editingRecord[d.key] ? "bg-blue-500 border-blue-500" : "border-slate-200 dark:border-slate-600"
                            )}
                          >
                            {editingRecord[d.key] && <CheckCircle2 size={16} className="text-white" />}
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
                <button 
                  onClick={() => {
                    updateRecord(editingRecord);
                    setEditingRecord(null);
                  }}
                  className="w-full bg-blue-500 text-white py-4 rounded-2xl font-bold text-lg shadow-lg shadow-blue-200 dark:shadow-none active:scale-[0.98] transition-transform"
                >
                  저장하기
                </button>
              </motion.div>
            </>
          )}
        </AnimatePresence>

        {/* Memo Bottom Sheet */}
        <AnimatePresence>
          {memoTarget && (
            <>
              <motion.div 
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                onClick={() => setMemoTarget(null)}
                className="fixed inset-0 bg-black/40 backdrop-blur-sm z-[80]"
              />
              <motion.div 
                initial={{ y: "100%" }}
                animate={{ y: 0 }}
                exit={{ y: "100%" }}
                transition={{ type: "spring", damping: 25, stiffness: 200 }}
                className="fixed bottom-0 left-0 right-0 bg-white dark:bg-slate-900 rounded-t-[3rem] p-8 z-[90] shadow-2xl max-w-md mx-auto"
              >
                <div className="flex items-center justify-between mb-6">
                  <div className="flex items-center gap-3">
                    <div className="p-3 bg-blue-50 dark:bg-blue-900/20 text-blue-500 rounded-2xl">
                      <StickyNote size={24} />
                    </div>
                    <div>
                      <h3 className="text-xl font-bold">
                        {DISCIPLINES.find(d => d.key === memoTarget.key)?.label} 메모
                      </h3>
                      <p className="text-slate-500 text-xs">
                        {format(parseISO(memoTarget.record.date), 'M월 d일')}
                      </p>
                    </div>
                  </div>
                  <button 
                    onClick={() => setMemoTarget(null)}
                    className="p-2 bg-slate-100 dark:bg-slate-800 rounded-full text-slate-500"
                  >
                    <X size={20} />
                  </button>
                </div>
                
                <textarea 
                  value={memoText}
                  onChange={(e) => setMemoText(e.target.value)}
                  placeholder="오늘의 훈련 내용을 기록해보세요..."
                  className="w-full h-40 p-5 bg-slate-50 dark:bg-slate-800 rounded-[2rem] border border-slate-100 dark:border-slate-700 focus:outline-none focus:ring-2 focus:ring-blue-500/20 transition-all resize-none mb-6"
                  autoFocus
                />

                <div className="flex gap-3">
                  <button 
                    onClick={() => setMemoTarget(null)}
                    className="flex-1 bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300 py-4 rounded-2xl font-bold active:scale-[0.98] transition-transform"
                  >
                    취소
                  </button>
                  <button 
                    onClick={saveMemo}
                    className="flex-[2] bg-blue-500 text-white py-4 rounded-2xl font-bold shadow-lg shadow-blue-200 dark:shadow-none active:scale-[0.98] transition-transform"
                  >
                    기록 완료
                  </button>
                </div>
              </motion.div>
            </>
          )}
        </AnimatePresence>
      </main>
    </div>
  );
}
