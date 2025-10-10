#!/bin/bash
# Export OpenAPI spec from running backend

set -e

BACKEND_URL="${BACKEND_URL:-http://localhost:8080}"
OUTPUT_FILE="${OUTPUT_FILE:-backend/openapi.json}"

echo "========================================"
echo "OpenAPI Specification Export Tool"
echo "========================================"
echo ""

# Check if backend is running
echo "Checking if backend is running at $BACKEND_URL..."
if ! curl -s -f "$BACKEND_URL/api/v1/actuator/health" > /dev/null 2>&1; then
    echo "ERROR: Backend not running on $BACKEND_URL"
    echo ""
    echo "Please start the backend first:"
    echo "  - Local: mvn spring-boot:run"
    echo "  - Docker: docker-compose up -d backend"
    echo ""
    exit 1
fi

echo "SUCCESS: Backend is running"
echo ""

# Fetch OpenAPI spec
echo "Fetching OpenAPI specification..."
HTTP_CODE=$(curl -s -o temp_openapi.json -w "%{http_code}" "$BACKEND_URL/api/v1/api-docs")

if [ "$HTTP_CODE" -ne 200 ]; then
    echo "ERROR: Failed to fetch OpenAPI spec (HTTP $HTTP_CODE)"
    rm -f temp_openapi.json
    exit 1
fi

# Pretty-print JSON (if jq is available)
if command -v jq &> /dev/null; then
    echo "Formatting JSON with jq..."
    jq '.' temp_openapi.json > "$OUTPUT_FILE"
    rm temp_openapi.json
else
    echo "WARNING: jq not found, saving unformatted JSON"
    mv temp_openapi.json "$OUTPUT_FILE"
fi

echo "SUCCESS: OpenAPI spec saved to: $OUTPUT_FILE"
echo ""

# Display statistics
if command -v jq &> /dev/null; then
    PATHS_COUNT=$(jq '.paths | length' "$OUTPUT_FILE")
    SCHEMAS_COUNT=$(jq '.components.schemas | length' "$OUTPUT_FILE")
    TITLE=$(jq -r '.info.title' "$OUTPUT_FILE")
    VERSION=$(jq -r '.info.version' "$OUTPUT_FILE")

    echo "API Information:"
    echo "  - Title: $TITLE"
    echo "  - Version: $VERSION"
    echo "  - Endpoints: $PATHS_COUNT"
    echo "  - Schemas: $SCHEMAS_COUNT"
else
    echo "Install jq for detailed statistics: https://stedolan.github.io/jq/"
fi

echo ""
echo "Next steps:"
echo "  - View Swagger UI: $BACKEND_URL/api/v1/swagger-ui.html"
echo "  - Generate Flutter client: cd frontend && ./generate-api-client.sh"
echo "  - View raw spec: cat $OUTPUT_FILE"
echo ""
echo "Done!"
