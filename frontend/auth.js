// Mock Authentication System
// This provides client-side authentication for development/testing purposes

const AUTH_STORAGE_KEY = 'thechain_auth';
const USERS_STORAGE_KEY = 'thechain_users';

// Mock user database
const MOCK_USERS = [
    {
        id: '1',
        email: 'demo@thechain.com',
        password: 'demo123',
        displayName: 'Demo User',
        chainKey: 'CHAIN-SEED-0001',
        position: 1,
        joinedAt: new Date('2025-01-01').toISOString(),
        parentId: null
    },
    {
        id: '2',
        email: 'alice@example.com',
        password: 'alice123',
        displayName: 'Alice Johnson',
        chainKey: 'CHAIN-USER-0002',
        position: 2,
        joinedAt: new Date('2025-01-02').toISOString(),
        parentId: '1'
    },
    {
        id: '3',
        email: 'bob@example.com',
        password: 'bob123',
        displayName: 'Bob Smith',
        chainKey: 'CHAIN-USER-0003',
        position: 3,
        joinedAt: new Date('2025-01-03').toISOString(),
        parentId: '1'
    }
];

// Initialize mock users in localStorage
function initMockUsers() {
    if (!localStorage.getItem(USERS_STORAGE_KEY)) {
        localStorage.setItem(USERS_STORAGE_KEY, JSON.stringify(MOCK_USERS));
    }
}

// Get all users
function getAllUsers() {
    const users = localStorage.getItem(USERS_STORAGE_KEY);
    return users ? JSON.parse(users) : MOCK_USERS;
}

// Save users
function saveUsers(users) {
    localStorage.setItem(USERS_STORAGE_KEY, JSON.stringify(users));
}

// Generate a unique chain key
function generateChainKey() {
    const timestamp = Date.now().toString(36).toUpperCase();
    const random = Math.random().toString(36).substring(2, 6).toUpperCase();
    return `CHAIN-${timestamp}-${random}`;
}

// Generate a unique user ID
function generateUserId() {
    return Date.now().toString() + Math.random().toString(36).substring(2, 9);
}

// Login function
function login(emailOrChainKey, password) {
    const users = getAllUsers();
    const user = users.find(u =>
        (u.email === emailOrChainKey || u.chainKey === emailOrChainKey) &&
        u.password === password
    );

    if (user) {
        // Create session (exclude password)
        const session = {
            id: user.id,
            email: user.email,
            displayName: user.displayName,
            chainKey: user.chainKey,
            position: user.position,
            joinedAt: user.joinedAt,
            parentId: user.parentId,
            loginAt: new Date().toISOString()
        };

        localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(session));
        return { success: true, user: session };
    }

    return { success: false, error: 'Invalid credentials' };
}

// Register function
function register(displayName, email, password, invitationTicket = null) {
    const users = getAllUsers();

    // Check if email already exists
    if (users.find(u => u.email === email)) {
        return { success: false, error: 'Email already registered' };
    }

    // Create new user
    const newUser = {
        id: generateUserId(),
        email: email,
        password: password,
        displayName: displayName,
        chainKey: generateChainKey(),
        position: users.length + 1,
        joinedAt: new Date().toISOString(),
        parentId: invitationTicket ? '1' : null // Mock: assign to seed user if has ticket
    };

    users.push(newUser);
    saveUsers(users);

    // Auto-login
    const session = {
        id: newUser.id,
        email: newUser.email,
        displayName: newUser.displayName,
        chainKey: newUser.chainKey,
        position: newUser.position,
        joinedAt: newUser.joinedAt,
        parentId: newUser.parentId,
        loginAt: new Date().toISOString()
    };

    localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(session));
    return { success: true, user: session };
}

// Get current session
function getCurrentUser() {
    const session = localStorage.getItem(AUTH_STORAGE_KEY);
    return session ? JSON.parse(session) : null;
}

// Check if user is authenticated
function isAuthenticated() {
    return getCurrentUser() !== null;
}

// Logout function
function logout() {
    localStorage.removeItem(AUTH_STORAGE_KEY);
    window.location.href = 'login.html';
}

// Require authentication (redirect to login if not authenticated)
function requireAuth() {
    if (!isAuthenticated()) {
        window.location.href = 'login.html';
        return false;
    }
    return true;
}

// Redirect if already authenticated
function redirectIfAuthenticated() {
    if (isAuthenticated()) {
        window.location.href = 'home.html';
        return true;
    }
    return false;
}

// Initialize mock users on load
initMockUsers();

// Export functions for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        login,
        register,
        getCurrentUser,
        isAuthenticated,
        logout,
        requireAuth,
        redirectIfAuthenticated,
        getAllUsers
    };
}
