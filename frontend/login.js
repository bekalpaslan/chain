// Login Page Script

// Redirect if already logged in
redirectIfAuthenticated();

// Tab switching
const loginTab = document.getElementById('loginTab');
const signupTab = document.getElementById('signupTab');
const loginForm = document.getElementById('loginForm');
const signupForm = document.getElementById('signupForm');

loginTab.addEventListener('click', () => {
    loginTab.classList.add('active');
    signupTab.classList.remove('active');
    loginForm.style.display = 'flex';
    signupForm.style.display = 'none';
});

signupTab.addEventListener('click', () => {
    signupTab.classList.add('active');
    loginTab.classList.remove('active');
    signupForm.style.display = 'flex';
    loginForm.style.display = 'none';
});

// Login form submission
loginForm.addEventListener('submit', (e) => {
    e.preventDefault();

    const email = document.getElementById('loginEmail').value;
    const password = document.getElementById('loginPassword').value;

    const result = login(email, password);

    if (result.success) {
        window.location.href = 'home.html';
    } else {
        alert(result.error);
    }
});

// Demo login button
document.getElementById('demoLoginBtn').addEventListener('click', () => {
    document.getElementById('loginEmail').value = 'demo@thechain.com';
    document.getElementById('loginPassword').value = 'demo123';

    const result = login('demo@thechain.com', 'demo123');

    if (result.success) {
        window.location.href = 'home.html';
    }
});

// Signup form submission
signupForm.addEventListener('submit', (e) => {
    e.preventDefault();

    const displayName = document.getElementById('signupName').value;
    const email = document.getElementById('signupEmail').value;
    const password = document.getElementById('signupPassword').value;
    const ticket = document.getElementById('signupTicket').value;

    const result = register(displayName, email, password, ticket || null);

    if (result.success) {
        window.location.href = 'home.html';
    } else {
        alert(result.error);
    }
});

// Load preview stats
async function loadPreviewStats() {
    try {
        const response = await fetch('http://localhost:8080/api/v1/chain/stats');
        if (response.ok) {
            const data = await response.json();
            document.getElementById('previewUsers').textContent = data.totalUsers || 0;
            document.getElementById('previewCountries').textContent = data.countries || 0;
        }
    } catch (error) {
        // Use mock data if backend is not available
        const users = getAllUsers();
        document.getElementById('previewUsers').textContent = users.length;
        document.getElementById('previewCountries').textContent = '0';
    }
}

loadPreviewStats();
