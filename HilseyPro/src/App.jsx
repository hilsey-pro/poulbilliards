import { useState, useMemo } from "react";
import { ShoppingBag, Wrench, Search, ShoppingCart, Package, X, Trash2 } from "lucide-react";

// --- REFACTORED COMPONENTS ---
const ProductCard = ({ product, onAddToCart }) => (
  <div className="bg-slate-900 border border-slate-800 p-4 rounded-2xl hover:border-blue-500 transition-all group">
    <div className="aspect-square bg-slate-950 rounded-xl mb-4 flex items-center justify-center text-slate-800 group-hover:text-blue-900 transition-colors">
      <Package size={48} />
    </div>
    <h3 className="font-bold text-white">{product.name}</h3>
    <p className="text-xs text-slate-500">Vendor: {product.vendor}</p>
    <div className="mt-4 flex justify-between items-center">
      <span className="text-blue-400 font-mono font-bold">
        {new Intl.NumberFormat('en-TZ').format(product.price)} TZS
      </span>
      <button 
        onClick={() => onAddToCart(product)}
        className="bg-blue-600 hover:bg-blue-500 text-white px-3 py-1.5 rounded-lg text-xs font-bold transition-colors flex items-center gap-1"
      >
        <ShoppingCart size={14} /> Add
      </button>
    </div>
  </div>
);

const Marketplace = () => {
  const [search, setSearch] = useState("");
  const [category, setCategory] = useState("All");
  const [cart, setCart] = useState([]);
  const [isCartOpen, setIsCartOpen] = useState(false);

  const products = [
    { id: 1, name: "Audit Master Notes", vendor: "William", category: "Academic", price: 25000 },
    { id: 2, name: "Financial Calc Pro", vendor: "Hilsey", category: "Tools", price: 65000 },
    { id: 3, name: "Tax Law Handbook", vendor: "BACC Dept", category: "Academic", price: 15000 },
  ];

  const addToCart = (item) => {
    setCart([...cart, { ...item, cartId: Date.now() }]);
    setIsCartOpen(true);
  };

  const removeFromCart = (cartId) => {
    setCart(cart.filter(item => item.cartId !== cartId));
  };

  const cartTotal = cart.reduce((sum, item) => sum + item.price, 0);

  const filteredProducts = useMemo(() => {
    return products.filter((p) => 
      (category === "All" || p.category === category) &&
      (p.name.toLowerCase().includes(search.toLowerCase()) || p.vendor.toLowerCase().includes(search.toLowerCase()))
    );
  }, [search, category]);

  return (
    <div className="relative max-w-7xl mx-auto p-8 space-y-10 bg-slate-950 min-h-screen text-slate-200 overflow-x-hidden">
      
      {/* HEADER SECTION */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <h1 className="flex items-center gap-3 text-5xl font-black italic tracking-tighter text-white">
          <ShoppingBag className="text-blue-500" size={40} /> HILSEY MARKETPLACE
        </h1>
        
        <button 
          onClick={() => setIsCartOpen(true)}
          className="relative p-4 bg-slate-900 border border-slate-800 rounded-2xl hover:bg-slate-800 transition-all"
        >
          <ShoppingCart size={24} className="text-blue-400" />
          {cart.length > 0 && (
            <span className="absolute -top-2 -right-2 bg-red-600 text-white text-[10px] font-bold px-2 py-1 rounded-full animate-bounce">
              {cart.length}
            </span>
          )}
        </button>
      </div>

      {/* SEARCH & FILTERS */}
      <div className="flex flex-col gap-6">
        <div className="relative max-w-2xl">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-500" size={20} />
          <input 
            value={search} 
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search resources..." 
            className="w-full bg-slate-900 border border-slate-800 p-4 pl-12 rounded-2xl outline-none focus:border-blue-500 transition-all"
          />
        </div>

        <div className="flex gap-4 overflow-x-auto pb-2 no-scrollbar">
          {["All", "Academic", "Tools", "Tech"].map((cat) => (
            <button 
              key={cat}
              onClick={() => setCategory(cat)} 
              className={`whitespace-nowrap py-2 px-6 rounded-full text-xs font-bold tracking-widest uppercase transition-all ${
                category === cat ? 'bg-blue-600 text-white' : 'bg-slate-900 text-slate-500 border border-slate-800 hover:text-white'
              }`}
            >
              {cat}
            </button>
          ))}
        </div>
      </div>

      {/* PRODUCT GRID */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        {filteredProducts.map(p => (
          <ProductCard key={p.id} product={p} onAddToCart={addToCart} />
        ))}
      </div>

      {/* CART SIDEBAR (THE FLEX) */}
      {isCartOpen && (
        <div className="fixed inset-0 z-[100] flex justify-end">
          <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={() => setIsCartOpen(false)} />
          <div className="relative w-full max-w-md bg-slate-950 border-l border-slate-800 h-full p-8 shadow-2xl flex flex-col animate-ui">
            <div className="flex justify-between items-center mb-8">
              <h2 className="text-2xl font-black italic">YOUR CART</h2>
              <button onClick={() => setIsCartOpen(false)}><X size={24} /></button>
            </div>

            <div className="flex-grow overflow-y-auto space-y-4 pr-2">
              {cart.length === 0 ? (
                <p className="text-slate-500 text-center py-20">Empty. Add some BACC fuel.</p>
              ) : (
                cart.map((item) => (
                  <div key={item.cartId} className="bg-slate-900 p-4 rounded-xl border border-slate-800 flex justify-between items-center">
                    <div>
                      <h4 className="font-bold text-sm">{item.name}</h4>
                      <p className="text-[10px] text-blue-400">{item.price.toLocaleString()} TZS</p>
                    </div>
                    <button onClick={() => removeFromCart(item.cartId)} className="text-slate-600 hover:text-red-500 transition-colors">
                      <Trash2 size={16} />
                    </button>
                  </div>
                ))
              )}
            </div>

            <div className="pt-8 border-t border-slate-900">
              <div className="flex justify-between mb-4">
                <span className="text-slate-500">Total Amount:</span>
                <span className="text-xl font-bold text-white">{cartTotal.toLocaleString()} TZS</span>
              </div>
              <button 
                disabled={cart.length === 0}
                className="w-full bg-blue-600 hover:bg-blue-500 disabled:opacity-50 disabled:bg-slate-800 py-4 rounded-2xl font-black text-lg transition-all"
              >
                CHECKOUT SYSTEM
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Marketplace;
