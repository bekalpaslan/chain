# The Chain - Frontend Landing Page

A beautiful, responsive landing page that displays real-time chain statistics without requiring user authentication.

## Features

- **Real-time Statistics**: Displays live data from the backend API
- **No Authentication Required**: Public landing page accessible to all users
- **Auto-refresh**: Statistics update every 30 seconds automatically
- **Responsive Design**: Works on desktop, tablet, and mobile devices
- **Recent Activity**: Shows the latest user attachments to the chain
- **Connection Status**: Visual indicator showing backend connectivity

## Quick Start

### Prerequisites
- Backend API running on `http://localhost:8080/api/v1`
- Python 3.x (for the simple HTTP server)

### Running the Frontend

1. **Start the HTTP server**:
   ```bash
   cd frontend
   python -m http.server 3000
   ```

2. **Open in browser**:
   ```
   http://localhost:3000
   ```

### Alternative: Open Directly
You can also open `index.html` directly in your browser, but CORS may prevent API calls. Using the HTTP server is recommended.

## API Integration

The landing page integrates with the following backend endpoint:

### GET /api/v1/chain/stats

**No authentication required**

Returns:
```json
{
  "totalUsers": 3,
  "activeTickets": 0,
  "chainStartDate": "2025-10-08T15:23:50.293Z",
  "averageGrowthRate": 0.0,
  "totalWastedTickets": 0,
  "wasteRate": 0.0,
  "countries": 0,
  "lastUpdate": "2025-10-08T15:23:50.293Z",
  "recentAttachments": [
    {
      "childPosition": 3,
      "displayName": "Bob",
      "timestamp": "2025-10-08T13:47:52.168Z",
      "country": null
    }
  ]
}
```

## Displayed Statistics

1. **Total Users**: Number of users connected to the chain
2. **Active Tickets**: Current tickets being processed
3. **Growth Rate**: Average daily growth percentage
4. **Countries**: Number of countries with users
5. **Recent Activity**: Latest user attachments with timestamps

## Customization

### Changing the API URL

Edit the `API_BASE_URL` constant in `index.html`:

```javascript
const API_BASE_URL = 'http://localhost:8080/api/v1';
```

### Auto-refresh Interval

Change the refresh interval (default: 30 seconds):

```javascript
// Change 30000 to desired milliseconds
setInterval(fetchChainStats, 30000);
```

### Styling

The page uses inline CSS for simplicity. Key color variables:
- Primary: `#667eea`
- Secondary: `#764ba2`
- Success: `#4caf50`
- Error: `#ff6b6b`

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

## Troubleshooting

### "Unable to connect to the backend"
1. Ensure the backend is running on port 8080
2. Check the API base URL in the code
3. Verify CORS is properly configured in the backend

### Stats not updating
1. Check browser console for errors
2. Verify network connectivity
3. Ensure the backend `/chain/stats` endpoint is accessible

## Production Deployment

For production:
1. Use a proper web server (Nginx, Apache, etc.)
2. Enable HTTPS
3. Configure proper CORS headers
4. Update `API_BASE_URL` to your production backend URL
5. Minify CSS and JavaScript
6. Add error tracking (e.g., Sentry)

## License

MIT License - See LICENSE file for details
