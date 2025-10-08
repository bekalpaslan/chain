#!/bin/bash

echo "🔍 Testing The Chain Backend..."
echo ""

# Health check
echo "✅ 1. Health Check:"
curl -s http://localhost:8080/api/v1/actuator/health | python -m json.tool
echo ""

# Stats
echo "✅ 2. Chain Stats:"
curl -s http://localhost:8080/api/v1/chain/stats | python -m json.tool
echo ""

# Database check
echo "✅ 3. Database Users:"
docker exec chain-postgres psql -U chain_user -d chaindb \
  -c "SELECT chain_key, username, position, location_country FROM users ORDER BY position;"
echo ""

# Tickets check
echo "✅ 4. Tickets:"
docker exec chain-postgres psql -U chain_user -d chaindb \
  -c "SELECT id, owner_id, status, expires_at FROM tickets LIMIT 5;"
echo ""

echo "✅ Backend is ready for testing!"
echo ""
echo "📱 Next steps:"
echo "1. Install Flutter: https://flutter.dev/docs/get-started/install/windows"
echo "2. Run: cd mobile && flutter pub get"
echo "3. Run: flutter run"
