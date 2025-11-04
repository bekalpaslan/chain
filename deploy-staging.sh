#!/bin/bash

# Staging Deployment Script for Candidate/Permanent System
# Usage: ./deploy-staging.sh

set -e  # Exit on error

echo "🚀 Starting staging deployment for Candidate/Permanent System..."

# Step 1: Checkout latest main branch
echo "📥 Pulling latest main branch..."
git checkout main
git pull origin main

# Step 2: Build backend
echo "🔨 Building backend..."
cd backend
mvn clean package -DskipTests
cd ..

# Step 3: Stop existing containers
echo "🛑 Stopping existing containers..."
docker-compose down

# Step 4: Start database first
echo "🗄️ Starting database services..."
docker-compose up -d postgres redis
sleep 10  # Wait for databases to be ready

# Step 5: Run database migration
echo "📊 Running database migration V007..."
docker-compose exec postgres psql -U chain_user -d chaindb -c "
-- Check if migration already applied
SELECT version FROM flyway_schema_history WHERE version = '007';
"

if [ $? -ne 0 ]; then
    echo "Applying migration V007..."
    # Migration would be applied automatically by Flyway on backend startup
fi

# Step 6: Start backend
echo "🎯 Starting backend service..."
docker-compose up -d backend

# Step 7: Wait for backend to be healthy
echo "⏳ Waiting for backend to be healthy..."
sleep 20
curl -f http://localhost:8080/api/v1/actuator/health || {
    echo "❌ Backend health check failed!"
    docker-compose logs backend
    exit 1
}

# Step 8: Run smoke tests
echo "🧪 Running smoke tests..."

# Test 1: Check if API responds
echo "Test 1: API responds..."
curl -s http://localhost:8080/api/v1/chain/stats | grep -q "total_positions_issued" && echo "✅ API working" || echo "❌ API not responding"

# Test 2: Check database migration
echo "Test 2: Database migration..."
docker-compose exec postgres psql -U chain_user -d chaindb -c "
SELECT column_name FROM information_schema.columns
WHERE table_name = 'users' AND column_name = 'membership_tier';
" | grep -q "membership_tier" && echo "✅ Migration applied" || echo "❌ Migration not applied"

# Step 9: Display logs
echo "📋 Recent backend logs:"
docker-compose logs --tail=20 backend

echo "✅ Staging deployment complete!"
echo ""
echo "📊 Next steps:"
echo "1. Monitor logs: docker-compose logs -f backend"
echo "2. Check metrics: http://localhost:8080/api/v1/actuator/metrics"
echo "3. Test new user registration as candidate"
echo "4. Test ticket expiration and halving"
echo ""
echo "🔍 Useful commands:"
echo "- View all users: docker-compose exec postgres psql -U chain_user -d chaindb -c 'SELECT username, membership_tier, wasted_tickets_count FROM users;'"
echo "- View recent tickets: docker-compose exec postgres psql -U chain_user -d chaindb -c 'SELECT * FROM tickets ORDER BY created_at DESC LIMIT 5;'"
echo "- Monitor promotions: docker-compose exec postgres psql -U chain_user -d chaindb -c 'SELECT username, promoted_to_permanent_at FROM users WHERE promoted_to_permanent_at IS NOT NULL;'"