import { BookOpen, Download, FileText, Search } from 'lucide-react';

const resources = [
  { id: '1', title: 'Financial Accounting 101', type: 'Note', category: 'BACC' },
  { id: '2', title: 'IT Systems Analysis 2024', type: 'Past Paper', category: 'BIT' },
  { id: '3', title: 'Partnership Accounts - Adjustments', type: 'Note', category: 'BACC' },
];

export default function ResourcesPage() {
  return (
    <div className="max-w-6xl mx-auto">
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 gap-4">
        <div>
          <h1 className="text-3xl font-bold text-slate-900 tracking-tight">Academic Vault</h1>
          <p className="text-slate-500">BACC & BIT Study Materials</p>
        </div>
        
        <div className="relative w-full md:w-64">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
          <input 
            type="text" 
            placeholder="Search notes..." 
            className="w-full pl-10 pr-4 py-2 border border-slate-200 rounded-xl focus:ring-2 focus:ring-blue-500 outline-none"
          />
        </div>
      </div>

      <div className="grid grid-cols-1 gap-3">
        {resources.map((item) => (
          <div key={item.id} className="bg-white p-4 rounded-2xl border border-slate-100 flex items-center justify-between hover:border-blue-200 hover:shadow-sm transition-all group">
            <div className="flex items-center gap-4">
              <div className={`p-3 rounded-xl ${item.type === 'Note' ? 'bg-blue-50 text-blue-600' : 'bg-indigo-50 text-indigo-600'}`}>
                {item.type === 'Note' ? <BookOpen size={22} /> : <FileText size={22} />}
              </div>
              <div>
                <h3 className="font-semibold text-slate-800 group-hover:text-blue-600 transition-colors">{item.title}</h3>
                <div className="flex gap-2 mt-1">
                  <span className="text-[10px] font-bold bg-slate-100 text-slate-600 px-2 py-0.5 rounded uppercase">{item.category}</span>
                  <span className="text-[10px] font-bold bg-slate-100 text-slate-600 px-2 py-0.5 rounded uppercase">{item.type}</span>
                </div>
              </div>
            </div>
            <button className="bg-slate-50 hover:bg-blue-600 hover:text-white p-2.5 rounded-xl transition-all text-slate-400">
              <Download size={18} />
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}
