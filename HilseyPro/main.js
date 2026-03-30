const app = {
    state: {
        pin: "1234",
        // This is your data (Products and Services)
        marketData: [
            { id: 1, type: 'product', name: 'Accounting Ledger Pro', vendor: 'Hilsey Tech', price: '25,000 TZS' },
            { id: 2, type: 'service', name: 'BACC Audit Prep', vendor: 'William Edward', price: '15,000 TZS' },
            { id: 3, type: 'product', name: 'Python for IT Students', vendor: 'CodeHub', price: '10,000 TZS' }
        ]
    },

    init() {
        this.dom = {
            login: document.getElementById('login-screen'),
            dash: document.getElementById('dashboard'),
            display: document.getElementById('display-area'),
            pin: document.getElementById('pin-input')
        };
    },

    login() {
        if (this.dom.pin.value === this.state.pin) {
            this.dom.login.classList.add('hidden');
            this.dom.dash.classList.remove('hidden');
            this.renderHome();
        } else { alert("WRONG PIN"); }
    },

    renderHome() {
        this.dom.display.innerHTML = `
            <div onclick="app.renderMarket()" class="p-8 bg-slate-900 border border-slate-800 rounded-3xl cursor-pointer hover:border-blue-500 transition-all">
                <h3 class="text-2xl font-bold text-blue-400">🛒 Marketplace</h3>
                <p class="text-slate-500 mt-2 text-sm">Products & Services for Students.</p>
            </div>
        `;
    },

    // THIS IS THE MARKETPLACE CODE YOU WANTED (Simplified)
    renderMarket() {
        this.dom.display.innerHTML = `
            <div class="col-span-full space-y-6 animate-ui">
                <div class="flex justify-between items-center">
                    <h2 class="text-3xl font-bold">Hilsey Marketplace</h2>
                    <button onclick="app.renderHome()" class="text-xs underline">Back</button>
                </div>
                
                <input id="m-search" oninput="app.filterMarket()" type="text" placeholder="Search products or vendors..." class="w-full bg-slate-900 p-4 rounded-xl border border-slate-800 outline-none focus:border-blue-500">

                <div id="market-results" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    ${this.generateCards(this.state.marketData)}
                </div>
            </div>
        `;
    },

    generateCards(items) {
        return items.map(item => `
            <div class="p-6 bg-slate-900 border border-slate-800 rounded-2xl">
                <span class="text-[10px] uppercase tracking-widest text-blue-500 font-bold">${item.type}</span>
                <h4 class="text-lg font-bold mt-1">${item.name}</h4>
                <p class="text-slate-500 text-xs italic">by ${item.vendor}</p>
                <div class="mt-4 flex justify-between items-center">
                    <span class="font-mono text-green-400">${item.price}</span>
                    <button class="bg-blue-600 px-3 py-1 rounded-lg text-xs font-bold">Buy Now</button>
                </div>
            </div>
        `).join('');
    },

    filterMarket() {
        const query = document.getElementById('m-search').value.toLowerCase();
        const filtered = this.state.marketData.filter(item => 
            item.name.toLowerCase().includes(query) || 
            item.vendor.toLowerCase().includes(query)
        );
        document.getElementById('market-results').innerHTML = this.generateCards(filtered);
    }
};

document.addEventListener('DOMContentLoaded', () => app.init());
