# The Chain - Authenticated Home Page

A complete authentication system and user dashboard with mock authentication for development.

## Features

### Authentication System
- **Login Page**: Email/password or Chain Key login
- **Registration**: Create new account with optional invitation ticket
- **Demo Account**: Quick login for testing
- **Session Management**: localStorage-based sessions
- **Mock Users**: Pre-configured test accounts

### Home Dashboard
- **User Profile**: Display name, chain key, and position
- **Quick Stats**: Tickets, invites, active ticket timer, chain length
- **Ticket Management**: Generate, share, copy, and cancel tickets
- **My Chain**: View people you've invited
- **Global Statistics**: Real-time chain statistics
- **Auto-refresh**: Stats update every 30 seconds

## Quick Start

1. **Start the HTTP server**:
   ```bash
   cd frontend
   python -m http.server 3000
   ```

2. **Open in browser**:
   ```
   http://localhost:3000/login.html
   ```

3. **Login with demo account**:
   - Click "Try Demo Account" button
   - Or manually enter:
     - Email: `demo@thechain.com`
     - Password: `demo123`

## Files Structure

```
frontend/
├── login.html          # Authentication page
├── home.html           # User dashboard
├── index.html          # Public landing page
├── styles.css          # Shared styles
├── auth.js             # Authentication system
├── login.js            # Login page logic
├── home.js             # Home page logic
└── README.md           # Original documentation
```

## Mock Users

Pre-configured accounts for testing:

| Email | Password | Display Name | Chain Key | Position |
|-------|----------|--------------|-----------|----------|
| demo@thechain.com | demo123 | Demo User | CHAIN-SEED-0001 | 1 |
| alice@example.com | alice123 | Alice Johnson | CHAIN-USER-0002 | 2 |
| bob@example.com | bob123 | Bob Smith | CHAIN-USER-0003 | 3 |

## Features Demo

### Login Page (`login.html`)
- Tab switching between Login and Sign Up
- Form validation
- Demo account quick login
- Registration with invitation ticket
- Preview statistics from API or mock data
- Responsive design with info section

### Home Page (`home.html`)
- **Navigation**: User profile, logout
- **Welcome Section**: User info, chain key, position
- **Quick Stats Cards**: 4 key metrics
- **Ticket Management**:
  - Generate 24-hour tickets
  - Real-time countdown timer
  - QR code display (placeholder)
  - Copy ticket code
  - Share functionality
  - Cancel ticket
- **My Chain**: List of invited users
- **Global Stats**: 4-card grid of chain statistics

## Mock Authentication Flow

### Login
1. Enter email/chain key and password
2. System checks against mock users in localStorage
3. If valid, creates session and redirects to home
4. Session stored in `thechain_auth` key

### Registration
1. Enter display name, email, password
2. Optional invitation ticket
3. System checks for duplicate email
4. Generates unique chain key
5. Creates user and auto-logs in

### Session Management
- Sessions stored in localStorage
- Auto-redirect if authenticated (on login page)
- Auth required for home page
- Logout clears session

## Data Storage

All data is stored in localStorage:

- `thechain_auth`: Current session
- `thechain_users`: User accounts
- `thechain_tickets`: Invitation tickets
- `thechain_chains`: Chain relationships

## Ticket System

### Generate Ticket
- Creates unique ticket code
- 24-hour expiration
- Status: active, expired, cancelled, used
- Auto-expires with timer

### Share Ticket
- Copy to clipboard
- Native share API (if available)
- Includes invitation text

### Timer
- Real-time countdown display
- Auto-updates every second
- Auto-expires ticket when time runs out
- Shows time left in quick stats

## API Integration

The home page integrates with backend API when available:

### GET /api/v1/chain/stats
- Falls back to mock data if API unavailable
- Auto-refresh every 30 seconds

### Future Endpoints (to implement)
- POST /api/v1/auth/login
- POST /api/v1/auth/register
- POST /api/v1/tickets/generate
- GET /api/v1/users/me
- GET /api/v1/users/me/chain

## Customization

### Change API URL
Edit in `home.js`:
```javascript
const API_BASE_URL = 'http://localhost:8080/api/v1';
```

### Ticket Duration
Edit in `home.js` (default: 24 hours):
```javascript
expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
```

### Add More Mock Users
Edit in `auth.js`:
```javascript
const MOCK_USERS = [
    // Add your users here
];
```

## Responsive Design

- Desktop: Full navigation and dual-column layout
- Tablet: Adjusted grid layouts
- Mobile: Single column, simplified navigation

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

## Security Notes

⚠️ **This is a MOCK authentication system for development only!**

- Passwords are stored in plain text
- Sessions are client-side only
- No encryption or security measures
- For development/testing purposes ONLY
- Must be replaced with real authentication for production

## Production Implementation

For production, replace mock authentication with:

1. **Backend Authentication**:
   - JWT tokens
   - Secure password hashing (bcrypt)
   - HTTP-only cookies
   - CSRF protection

2. **Real Ticket System**:
   - Database storage
   - QR code generation library
   - Ticket validation
   - Usage tracking

3. **Security**:
   - HTTPS
   - Rate limiting
   - Session expiration
   - XSS protection

## Troubleshooting

### Can't login
- Check browser console for errors
- Clear localStorage: `localStorage.clear()`
- Use demo account button

### Ticket not generating
- Check if you already have active ticket
- Check browser console for errors
- Clear ticket storage

### Stats not loading
- Backend may be unavailable (normal)
- Falls back to mock data automatically
- Check console for API errors

## Next Steps

1. Integrate with real backend API
2. Implement QR code generation (use library like qrcode.js)
3. Add real-time WebSocket updates
4. Add chain visualization
5. Implement user profile page
6. Add notification system
7. Implement proper authentication

## License

MIT License - See LICENSE file for details
