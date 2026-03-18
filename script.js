// State Management
const state = {
    user: JSON.parse(localStorage.getItem('hilsey_user')) || null,
    wallet: parseFloat(localStorage.getItem('hilsey_wallet')) || 50000.00,
    cart: JSON.parse(localStorage.getItem('hilsey_cart')) || [],
    notifications: []
};

// Persistence
function saveState() {
    localStorage.setItem('hilsey_user', JSON.stringify(state.user));
    localStorage.setItem('hilsey_wallet', state.wallet.toString());
    localStorage.setItem('hilsey_cart', JSON.stringify(state.cart));
}

// Auth Flow
function login(role, regNumber) {
    state.user = {
        role: role,
        regNumber: regNumber,
        name: regNumber.split('/')[1] || 'Student'
    };
    saveState();
    window.location.href = 'dashboard.html';
}

function logout() {
    state.user = null;
    localStorage.removeItem('hilsey_user');
    window.location.href = 'index.html';
}

// Notification System
function notify(message) {
    const toast = document.createElement('div');
    toast.className = 'notification-toast';
    toast.innerText = message;
    document.body.appendChild(toast);

    setTimeout(() => toast.classList.add('show'), 100);
    setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

// Navigation Helper
function navigateTo(page) {
    window.location.href = page;
}

// Sidebar Component (Injectable)
function injectSidebar() {
    const sidebarHTML = `
        <div class="sidebar">
            <h2>Hilsey Hub</h2>
            <a href="dashboard.html" class="nav-link ${window.location.pathname.includes('dashboard') ? 'active' : ''}">Dashboard</a>
            <a href="marketplace.html" class="nav-link ${window.location.pathname.includes('marketplace') ? 'active' : ''}">Shop</a>
            <a href="study-hub.html" class="nav-link ${window.location.pathname.includes('study-hub') ? 'active' : ''}">Study Hub</a>
            <a href="discussion.html" class="nav-link ${window.location.pathname.includes('discussion') ? 'active' : ''}">Discussion</a>
            <a href="groups.html" class="nav-link ${window.location.pathname.includes('groups') ? 'active' : ''}">Groups</a>
            <a href="services.html" class="nav-link ${window.location.pathname.includes('services') ? 'active' : ''}">Services</a>
            <a href="templates.html" class="nav-link ${window.location.pathname.includes('templates') ? 'active' : ''}">Templates</a>
            <a href="careers.html" class="nav-link ${window.location.pathname.includes('careers') ? 'active' : ''}">Careers</a>
            <div style="margin-top: auto;">
                <button onclick="logout()" style="background: transparent; color: var(--text-muted); border: 1px solid #334155;">Logout</button>
            </div>
        </div>
    `;
    const mainContent = document.querySelector('.main-content');
    if (mainContent) {
        document.body.insertAdjacentHTML('afterbegin', sidebarHTML);
    }
}

// Auto-init on DOM load
document.addEventListener('DOMContentLoaded', () => {
    // Check auth for non-index pages
    if (!window.location.pathname.includes('index.html') && window.location.pathname !== '/' && !state.user) {
        // window.location.href = 'index.html';
    }

    injectSidebar();

    // Update wallet displays if they exist
    const walletDisplays = document.querySelectorAll('.wallet-balance');
    walletDisplays.forEach(el => el.innerText = `Tsh ${state.wallet.toLocaleString()}`);
});
