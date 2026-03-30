// 1. DATA BANK (Frozen for safety)
const studyData = Object.freeze([
    { title: "Three Column Cash Book", detail: "Mr. Mwalongo: April 1st Balances are Cash 11M and Bank 38.5M.", tag: "Accounting" },
    { title: "Verification of Assets", detail: "Focus on physical inspection of buildings and checking Title Deeds.", tag: "Audit" },
    { title: "DS: Population Pressure", detail: "Rapid growth leads to deforestation and soil erosion in developing regions.", tag: "Development" },
    { title: "The Debt Problem", detail: "Causes: High interest rates, weak tax systems, and currency depreciation.", tag: "Development" }
]);

const careerData = Object.freeze([
    { name: "NMB Bank PLC", analysis: "12.5% Horizontal Growth", type: "Banking" },
    { name: "CRDB Bank PLC", analysis: "8.2% Vertical Strength", type: "Banking" },
    { name: "DSE Market", analysis: "Stable Dividends 2026", type: "Market" }
]);

// 2. CACHE DOM (Your clean optimization)
const DOM = {
    chat: document.getElementById('ai-chat'),
    input: document.getElementById('ai-input'),
    chatBox: document.getElementById('chat-box'),
    grid: document.getElementById('hub-grid'),
    title: document.getElementById('main-title')
};

// 3. UTILITIES
const escapeHTML = (str) => {
    return str.replace(/[&<>"']/g, (tag) => ({
        '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
    }[tag]));
};

// 4. AI CO-PILOT ENGINE
const aiRules = [
    {
        keywords: ["cash", "mwalongo", "balance"],
        response: "AI: Mr. Mwalongo's Cash Book starts with TZS 11,000,000 (Cash) and TZS 38,500,000 (Bank). Remember to track discounts separately!"
    },
    {
        keywords: ["nmb", "crdb", "growth"],
        response: "AI: NMB shows a 12.5% horizontal growth. For your assignment, compare this to the industry average in Tanzania."
    },
    {
        keywords: ["debt", "loans"],
        response: "AI: Developing nations face debt due to 'Reliance on external borrowing to fill domestic saving gaps' (per your DS notes)."
    },
    {
        keywords: ["population", "resource"],
        response: "AI: Population pressure causes deforestation. In many regions, this leads to soil erosion and lower agricultural productivity."
    }
];

window.toggleAI = () => {
    if (!DOM.chat) return;
    DOM.chat.style.display = DOM.chat.style.display === 'block' ? 'none' : 'block';
};

window.askAI = () => {
    const raw = DOM.input.value.trim();
    if (!raw) return;

    const query = raw.toLowerCase();
    DOM.chatBox.innerHTML += `<p class="text-right text-gray-400 font-bold mb-2">You: ${escapeHTML(raw)}</p>`;

    let response = "AI: I'm still learning that. Try asking about 'Cash Book', 'NMB', or 'Debt'.";
    
    for (let rule of aiRules) {
        if (rule.keywords.some(k => query.includes(k))) {
            response = rule.response;
            break;
        }
    }

    setTimeout(() => {
        DOM.chatBox.innerHTML += `<div class="bg-blue-900/30 p-2 rounded-lg mb-4 text-blue-300 italic border border-blue-500/20">${response}</div>`;
        DOM.chatBox.scrollTop = DOM.chatBox.scrollHeight;
    }, 400);

    DOM.input.value = "";
};

// 5. RENDERING ENGINE
const render = (data, type) => {
    if (!data.length) return `<p class="text-gray-400">No data available</p>`;

    return data.map(item => {
        if (type === "study") {
            return `
                <div class="p-4 bg-slate-800 border border-slate-700 rounded-xl hover:border-blue-500 transition-colors">
                    <h4 class="text-blue-400 font-bold">${escapeHTML(item.title)}</h4>
                    <p class="text-xs text-gray-400 mt-1">${escapeHTML(item.detail)}</p>
                </div>
            `;
        }
        return `
            <div class="flex justify-between items-center p-4 bg-slate-800 border-l-4 border-green-500 rounded hover:bg-slate-750 transition-colors">
                <div>
                    <p class="font-bold text-gray-200">${escapeHTML(item.name)}</p>
                    <p class="text-[10px] text-gray-500">${escapeHTML(item.type)}</p>
                </div>
                <span class="text-green-400 font-mono font-bold">${escapeHTML(item.analysis)}</span>
            </div>
        `;
    }).join('');
};

// 6. HUB TRIGGERS
window.openStudyHub = () => {
    DOM.title.textContent = "Study Hub: Assignment Archive";
    DOM.grid.innerHTML = `<div class="col-span-1 md:col-span-2 space-y-4">${render(studyData, "study")}</div>`;
};

window.openCareerHub = () => {
    DOM.title.textContent = "Career Hub: DSE Market Analysis";
    DOM.grid.innerHTML = `<div class="col-span-1 md:col-span-2 space-y-4">${render(careerData, "career")}</div>`;
};

console.log("Hilsey Pro: Clean Engine Loaded.");
