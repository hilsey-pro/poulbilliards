import { useState, useMemo } from "react";
import { ShoppingBag, Wrench, Search, ShoppingCart, Package } from "lucide-react";

// --- REFACTORED COMPONENTS ---
const ProductCard = ({ product }) => (
  <div className="bg-slate-900 border border-slate-800 p-4 rounded-2xl hover:border-blue-500 transition-all group">
    <div className="aspect-square bg-slate-950 rounded-xl mb-4 flex items-center justify-center text-slate-800 font-bold group-hover:text-blue-900 transition-colors">
      <Package size={48} />
    </div>
    <h3 className="font-bold text-white">{product.name}</h3>
    <p className="text-xs text-slate-500">Vendor: {product.vendor}</p>
    <div className="mt-4 flex justify-between items-center">
      <span className="text-blue-400 font-mono font-bold">
        {new Intl.NumberFormat('en-TZ').format(product.price)} TZS
      </span>
      <button 
        onClick={() => alert(`Initiating purchase for: ${product.name}`)}
        className="bg-blue-600 hover:bg-blue-500 text-white px-3 py-1.5 rounded-lg text-xs font-bold transition-colors"
      >
        Buy
      </button>
    </div>
  </div>
);

const ServiceCard = ({ service }) => (
  <div className="bg-slate-900 border border-slate-800 p-6 rounded-2xl flex justify-between items-center hover:border-green-500 transition-all">
    <div className="flex items-center gap-4">
      <div className="p-3 bg-slate-950 rounded-full text-green-500">
        <Wrench size={20} />
      </div>
      <div>
        <h3 className="font-bold text-white text-lg">{service.name}</h3>
        <p className="text-sm text-slate-400 italic">Expert: {service.vendor}</p>
      </div>
    </div>
    <button 
      onClick={() => alert(`Booking session with ${service.vendor}`)}
      className="bg-green-600 hover:bg-green-500 text-white px-5 py-2 rounded-xl font-bold transition-all shadow-lg shadow-green-900/20"
    >
      Book Now
    </button>
  </div>
);

const Marketplace = () => {
  const [search, setSearch] = useState("");
  const [category, setCategory] = useState("All");

  const products = [
    { id: 1, name: "Audit Master Notes", vendor: "William", category: "Academic", price: 25000 },
    { id: 2, name: "Financial Calc Pro", vendor: "Hilsey", category: "Tools", price: 65000 },
    { id: 3, name: "Tax Law Handbook", vendor: "BACC Dept", category: "Academic", price: 15000 },
  ];
  
  const services = [
    { id: 1, name: "Prisma DB Setup", vendor: "IT Expert", category: "Tech" },
    { id: 2, name: "DSE Analysis Review", vendor: "Accounting Pro", category: "Academic" },
    { id: 3, name: "UI/UX Consultation", vendor: "Hilsey Design", category: "Tech" },
  ];

  // FIXED: Search now respects reality for both lists
  const filteredProducts = useMemo(() => {
    return products.filter((p) => 
      (category === "All" || p.category === category) &&
      (p.name.toLowerCase().includes(search.toLowerCase()) || p.vendor.toLowerCase().includes(search.toLowerCase()))
    );
  }, [search, category]);

  const filteredServices = useMemo(() => {
    return services.filter((s) => 
      (category === "All" || s.category === category) &&
      (s.name.toLowerCase().includes(search.toLowerCase()) || s.vendor.toLowerCase().includes(search.toLowerCase()))
    );
  }, [search, category]);

  return (
    <div className="max-w-7xl mx-auto p-8 space-y-10 bg-slate-950 min-h-screen text-slate-200">
      {/* Header with proper Icon usage */}
      <div className="flex flex-col gap-6">
        <h1 className="flex items-center gap-3 text-5xl font-black italic tracking-tighter text-white">
          <ShoppingBag className="text-blue-500" size={40} /> HILSEY MARKETPLACE
        </h1>
        
        <div className="relative max-w-2xl">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-500" size={20} />
          <input 
            value={search} 
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search products, services, or vendors..." 
            className="w-full bg-slate-900 border border-slate-800 p-4 pl-12 rounded-2xl outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500 transition-all"
          />
        </div>
      </div>

      {/* Category Tabs using className correctly */}
      <div className="flex gap-8 border-b border-slate-900 pb-1">
        {["All", "Academic", "Tools", "Tech"].map((cat) => (
          <button 
            key={cat}
            onClick={() => setCategory(cat)} 
            className={`pb-4 px-2 text-sm font-bold tracking-widest uppercase transition-all ${
              category === cat ? 'border-b-2 border-blue-500 text-white' : 'text-slate-500 hover:text-slate-300'
            }`}
          >
            {cat}
          </button>
        ))}
      </div>

      {/* Products Grid with Empty State */}
      <div className="space-y-6">
        <h2 className="flex items-center gap-2 text-xl font-bold text-slate-400 italic uppercase tracking-wider">
          <ShoppingCart size={18} /> Available Products
        </h2>
        {filteredProducts.length === 0 ? (
          <div className="py-20 text-center border-2 border-dashed border-slate-900 rounded-3xl text-slate-600">
            No products match your current filters.
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {filteredProducts.map(p => <ProductCard key={p.id} product={p} />)}
          </div>
        )}
      </div>
      
      {/* Services List with Empty State */}
      <div className="space-y-6">
        <h2 className="flex items-center gap-2 text-xl font-bold text-slate-400 italic uppercase tracking-wider">
          <Wrench size={18}/> Expert Services
        </h2>
        {filteredServices.length === 0 ? (
          <p className="text-slate-600 italic">No services found in this category.</p>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {filteredServices.map(s => <ServiceCard key={s.id} service={s} />)}
          </div>
        )}
      </div>
    </div>
  );
};

export default Marketplace;
