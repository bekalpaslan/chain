// Home Page Script

// Require authentication
if (!requireAuth()) {
    // redirected to login
}

const API_BASE_URL = 'http://localhost:8080/api/v1';

// Get current user
const currentUser = getCurrentUser();

// Mock ticket storage
const TICKETS_STORAGE_KEY = 'thechain_tickets';
const CHAINS_STORAGE_KEY = 'thechain_chains';

// Initialize page
function initializePage() {
    displayUserInfo();
    loadQuickStats();
    loadTicketStatus();
    loadMyChain();
    loadGlobalStats();
}

// Display user information
function displayUserInfo() {
    // Update navigation
    document.getElementById('navUserAvatar').textContent = currentUser.displayName.charAt(0).toUpperCase();
    document.getElementById('navUserName').textContent = currentUser.displayName;

    // Update welcome section
    document.getElementById('userName').textContent = currentUser.displayName;
    document.getElementById('userChainKey').textContent = currentUser.chainKey;
    document.getElementById('userPosition').textContent = `#${currentUser.position}`;
}

// Load quick stats
function loadQuickStats() {
    const tickets = getMyTickets();
    const activeTicket = tickets.find(t => t.status === 'active');
    const chains = getMyChains();

    document.getElementById('myTicketsCount').textContent = tickets.length;
    document.getElementById('myInvitesCount').textContent = chains.length;

    if (activeTicket) {
        const timeLeft = getTimeLeft(activeTicket.expiresAt);
        document.getElementById('activeTicketTime').textContent = timeLeft;
    } else {
        document.getElementById('activeTicketTime').textContent = '--';
    }

    // Load total chain length from API or mock
    loadChainLength();
}

// Load chain length
async function loadChainLength() {
    try {
        const response = await fetch(`${API_BASE_URL}/chain/stats`);
        if (response.ok) {
            const data = await response.json();
            document.getElementById('chainLength').textContent = data.totalUsers || 0;
        }
    } catch (error) {
        // Use mock data
        const users = getAllUsers();
        document.getElementById('chainLength').textContent = users.length;
    }
}

// Get my tickets
function getMyTickets() {
    const tickets = localStorage.getItem(TICKETS_STORAGE_KEY);
    const allTickets = tickets ? JSON.parse(tickets) : [];
    return allTickets.filter(t => t.userId === currentUser.id);
}

// Save ticket
function saveTicket(ticket) {
    const tickets = localStorage.getItem(TICKETS_STORAGE_KEY);
    const allTickets = tickets ? JSON.parse(tickets) : [];
    allTickets.push(ticket);
    localStorage.setItem(TICKETS_STORAGE_KEY, JSON.stringify(allTickets));
}

// Update ticket
function updateTicket(ticketId, updates) {
    const tickets = localStorage.getItem(TICKETS_STORAGE_KEY);
    const allTickets = tickets ? JSON.parse(tickets) : [];
    const index = allTickets.findIndex(t => t.id === ticketId);

    if (index !== -1) {
        allTickets[index] = { ...allTickets[index], ...updates };
        localStorage.setItem(TICKETS_STORAGE_KEY, JSON.stringify(allTickets));
    }
}

// Get my chains (people I invited)
function getMyChains() {
    const chains = localStorage.getItem(CHAINS_STORAGE_KEY);
    const allChains = chains ? JSON.parse(chains) : [];
    return allChains.filter(c => c.parentId === currentUser.id);
}

// Load ticket status
function loadTicketStatus() {
    const tickets = getMyTickets();
    const activeTicket = tickets.find(t => t.status === 'active');

    if (activeTicket) {
        // Check if ticket has expired
        if (new Date(activeTicket.expiresAt) < new Date()) {
            updateTicket(activeTicket.id, { status: 'expired' });
            showNoTicket();
        } else {
            showActiveTicket(activeTicket);
            startTicketTimer(activeTicket);
        }
    } else {
        showNoTicket();
    }
}

// Show no ticket state
function showNoTicket() {
    document.getElementById('noTicket').style.display = 'block';
    document.getElementById('activeTicket').style.display = 'none';
}

// Show active ticket
function showActiveTicket(ticket) {
    document.getElementById('noTicket').style.display = 'none';
    document.getElementById('activeTicket').style.display = 'block';
    document.getElementById('ticketCode').value = ticket.code;

    // Generate QR code placeholder (in real app, use a QR library)
    const qrCode = document.getElementById('qrCode');
    qrCode.innerHTML = `
        <div class="qr-placeholder" style="font-size: 0.8em; padding: 20px; text-align: center;">
            <div style="margin-bottom: 10px;">📱 QR CODE</div>
            <div style="font-size: 0.7em; color: #999;">${ticket.code}</div>
        </div>
    `;
}

// Start ticket timer
let timerInterval = null;
function startTicketTimer(ticket) {
    if (timerInterval) {
        clearInterval(timerInterval);
    }

    function updateTimer() {
        const now = new Date();
        const expiry = new Date(ticket.expiresAt);
        const diff = expiry - now;

        if (diff <= 0) {
            document.getElementById('ticketTimer').textContent = '00:00:00';
            updateTicket(ticket.id, { status: 'expired' });
            showNoTicket();
            clearInterval(timerInterval);
            loadQuickStats();
            return;
        }

        const hours = Math.floor(diff / (1000 * 60 * 60));
        const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
        const seconds = Math.floor((diff % (1000 * 60)) / 1000);

        const timeString = `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
        document.getElementById('ticketTimer').textContent = timeString;
    }

    updateTimer();
    timerInterval = setInterval(updateTimer, 1000);
}

// Get time left formatted
function getTimeLeft(expiresAt) {
    const now = new Date();
    const expiry = new Date(expiresAt);
    const diff = expiry - now;

    if (diff <= 0) return 'Expired';

    const hours = Math.floor(diff / (1000 * 60 * 60));
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));

    if (hours > 0) {
        return `${hours}h ${minutes}m`;
    }
    return `${minutes}m`;
}

// Generate new ticket
function generateNewTicket() {
    const tickets = getMyTickets();
    const activeTicket = tickets.find(t => t.status === 'active');

    if (activeTicket) {
        alert('You already have an active ticket! Please wait for it to expire or cancel it.');
        return;
    }

    const ticket = {
        id: Date.now().toString(),
        userId: currentUser.id,
        code: generateTicketCode(),
        status: 'active',
        createdAt: new Date().toISOString(),
        expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString() // 24 hours
    };

    saveTicket(ticket);
    showActiveTicket(ticket);
    startTicketTimer(ticket);
    loadQuickStats();
}

// Generate ticket code
function generateTicketCode() {
    const part1 = Math.random().toString(36).substring(2, 6).toUpperCase();
    const part2 = Math.random().toString(36).substring(2, 6).toUpperCase();
    const part3 = Math.random().toString(36).substring(2, 6).toUpperCase();
    return `TICKET-${part1}-${part2}-${part3}`;
}

// Copy ticket code
function copyTicketCode() {
    const ticketCode = document.getElementById('ticketCode');
    ticketCode.select();
    document.execCommand('copy');

    const btn = document.getElementById('copyTicketBtn');
    const originalText = btn.textContent;
    btn.textContent = 'Copied!';
    setTimeout(() => {
        btn.textContent = originalText;
    }, 2000);
}

// Share ticket
function shareTicket() {
    const ticketCode = document.getElementById('ticketCode').value;
    const shareText = `Join me on The Chain! Use my invitation code: ${ticketCode}`;

    if (navigator.share) {
        navigator.share({
            title: 'Join The Chain',
            text: shareText,
            url: window.location.origin + '/login.html'
        }).catch(() => {
            // Fallback to copy
            copyToClipboard(shareText);
        });
    } else {
        // Fallback to copy
        copyToClipboard(shareText);
        alert('Invitation copied to clipboard!');
    }
}

// Copy to clipboard helper
function copyToClipboard(text) {
    const textarea = document.createElement('textarea');
    textarea.value = text;
    document.body.appendChild(textarea);
    textarea.select();
    document.execCommand('copy');
    document.body.removeChild(textarea);
}

// Cancel ticket
function cancelTicket() {
    if (!confirm('Are you sure you want to cancel this ticket? This action cannot be undone.')) {
        return;
    }

    const tickets = getMyTickets();
    const activeTicket = tickets.find(t => t.status === 'active');

    if (activeTicket) {
        updateTicket(activeTicket.id, { status: 'cancelled' });
        showNoTicket();
        clearInterval(timerInterval);
        loadQuickStats();
    }
}

// Load my chain
function loadMyChain() {
    const chains = getMyChains();
    const chainList = document.getElementById('chainList');

    if (chains.length === 0) {
        chainList.innerHTML = `
            <div class="empty-state">
                <p>You haven't invited anyone yet</p>
                <p class="empty-hint">Generate a ticket and share it to grow the chain!</p>
            </div>
        `;
        return;
    }

    chainList.innerHTML = chains.map(chain => `
        <div class="chain-item">
            <div class="chain-user-info">
                <div class="user-avatar">${chain.displayName.charAt(0).toUpperCase()}</div>
                <div class="chain-user-details">
                    <h4>${chain.displayName}</h4>
                    <p>Joined: ${new Date(chain.joinedAt).toLocaleDateString()}</p>
                </div>
            </div>
            <div class="chain-position">
                Position #${chain.position}
            </div>
        </div>
    `).join('');
}

// Load global stats
async function loadGlobalStats() {
    try {
        const response = await fetch(`${API_BASE_URL}/chain/stats`);
        if (response.ok) {
            const data = await response.json();
            displayGlobalStats(data);
        }
    } catch (error) {
        // Use mock data
        const users = getAllUsers();
        const tickets = localStorage.getItem(TICKETS_STORAGE_KEY);
        const allTickets = tickets ? JSON.parse(tickets) : [];
        const activeTickets = allTickets.filter(t => t.status === 'active').length;

        displayGlobalStats({
            totalUsers: users.length,
            activeTickets: activeTickets,
            averageGrowthRate: 0,
            countries: 0
        });
    }
}

// Display global stats
function displayGlobalStats(data) {
    document.getElementById('globalTotalUsers').textContent = data.totalUsers || 0;
    document.getElementById('globalActiveTickets').textContent = data.activeTickets || 0;
    document.getElementById('globalGrowthRate').textContent = (data.averageGrowthRate || 0).toFixed(1) + '%';
    document.getElementById('globalCountries').textContent = data.countries || 0;
}

// Event listeners
document.getElementById('generateTicketBtn').addEventListener('click', generateNewTicket);
document.getElementById('copyTicketBtn').addEventListener('click', copyTicketCode);
document.getElementById('shareTicketBtn').addEventListener('click', shareTicket);
document.getElementById('cancelTicketBtn').addEventListener('click', cancelTicket);
document.getElementById('logoutBtn').addEventListener('click', logout);

// Initialize page on load
initializePage();

// Auto-refresh stats every 30 seconds
setInterval(() => {
    loadQuickStats();
    loadGlobalStats();
}, 30000);
