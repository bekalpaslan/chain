#!/bin/bash

# The Chain - Secret Generation Script
# This script generates secure random secrets for all required environment variables

set -e

echo "====================================="
echo "The Chain - Secret Generation Script"
echo "====================================="
echo ""

# Check if .env file already exists
if [ -f .env ]; then
    read -p ".env file already exists. Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        exit 0
    fi
    # Backup existing .env
    cp .env .env.backup
    echo "Existing .env backed up to .env.backup"
fi

# Check if .env.example exists
if [ ! -f .env.example ]; then
    echo "ERROR: .env.example file not found!"
    echo "Please create .env.example first."
    exit 1
fi

# Generate secure random secrets
echo "Generating secure random secrets..."
POSTGRES_PASSWORD=$(openssl rand -base64 32)
REDIS_PASSWORD=$(openssl rand -base64 32)
JWT_SECRET=$(openssl rand -base64 32)

echo "Secrets generated successfully!"
echo ""

# Copy .env.example to .env
cp .env.example .env

# Replace placeholders with generated secrets
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/POSTGRES_PASSWORD=CHANGE_ME_GENERATE_SECURE_PASSWORD/POSTGRES_PASSWORD=$POSTGRES_PASSWORD/g" .env
    sed -i '' "s/DB_PASSWORD=CHANGE_ME_GENERATE_SECURE_PASSWORD/DB_PASSWORD=$POSTGRES_PASSWORD/g" .env
    sed -i '' "s/REDIS_PASSWORD=CHANGE_ME_GENERATE_SECURE_PASSWORD/REDIS_PASSWORD=$REDIS_PASSWORD/g" .env
    sed -i '' "s/JWT_SECRET=CHANGE_ME_GENERATE_SECURE_JWT_SECRET/JWT_SECRET=$JWT_SECRET/g" .env
else
    # Linux
    sed -i "s/POSTGRES_PASSWORD=CHANGE_ME_GENERATE_SECURE_PASSWORD/POSTGRES_PASSWORD=$POSTGRES_PASSWORD/g" .env
    sed -i "s/DB_PASSWORD=CHANGE_ME_GENERATE_SECURE_PASSWORD/DB_PASSWORD=$POSTGRES_PASSWORD/g" .env
    sed -i "s/REDIS_PASSWORD=CHANGE_ME_GENERATE_SECURE_PASSWORD/REDIS_PASSWORD=$REDIS_PASSWORD/g" .env
    sed -i "s/JWT_SECRET=CHANGE_ME_GENERATE_SECURE_JWT_SECRET/JWT_SECRET=$JWT_SECRET/g" .env
fi

echo "✓ .env file created with secure secrets"
echo ""
echo "IMPORTANT SECURITY NOTES:"
echo "========================="
echo "1. The .env file contains sensitive secrets - DO NOT commit it to version control"
echo "2. Make sure .env is listed in .gitignore"
echo "3. Store these secrets securely (use a password manager or secrets vault)"
echo "4. For production, consider using a secrets management service like:"
echo "   - AWS Secrets Manager"
echo "   - HashiCorp Vault"
echo "   - Azure Key Vault"
echo "   - Google Cloud Secret Manager"
echo ""
echo "Generated secrets summary:"
echo "=========================="
echo "PostgreSQL Password: ${POSTGRES_PASSWORD:0:10}... (32 bytes)"
echo "Redis Password:      ${REDIS_PASSWORD:0:10}... (32 bytes)"
echo "JWT Secret:          ${JWT_SECRET:0:10}... (32 bytes)"
echo ""
echo "✓ Setup complete!"
