#!/usr/bin/env python3
import requests
import json

# Login
login_url = "http://localhost:8080/api/v1/auth/login"
login_data = {"username": "testuser_01", "password": "admin123"}

print("Logging in...")
login_response = requests.post(login_url, json=login_data)
if login_response.status_code != 200:
    print(f"[ERROR] Login failed: {login_response.text}")
    exit(1)

login_json = login_response.json()
token = login_json["tokens"]["accessToken"]
print(f"[OK] Login successful, token: {token[:20]}...")

# Get dashboard - try different endpoints
dashboard_url = "http://localhost:8080/api/v1/users/me/dashboard"
headers = {"Authorization": f"Bearer {token}"}

print("\nFetching dashboard...")
dashboard_response = requests.get(dashboard_url, headers=headers)
if dashboard_response.status_code != 200:
    print(f"[ERROR] Dashboard request failed: {dashboard_response.text}")
    exit(1)

dashboard_json = dashboard_response.json()

# Check for country codes
if "chainMembers" in dashboard_json:
    members = dashboard_json["chainMembers"]
    print(f"[OK] Dashboard returned {len(members)} chain members")
    print("\n[INFO] Country codes for first 10 members:")
    for i, member in enumerate(members[:10]):
        country = member.get("countryCode", "MISSING")
        status = member.get("status", "unknown")
        print(f"   #{member['position']:2} {member['displayName']:15} - Country: {country:8} - Status: {status}")

    # Check if seed user has Japan
    seed_member = next((m for m in members if m['position'] == 1), None)
    if seed_member and seed_member.get('countryCode') == 'JP':
        print("\n[OK] Seed user correctly has Japan (JP) as country")
    else:
        print(f"\n[ERROR] Seed user country issue: {seed_member.get('countryCode') if seed_member else 'NOT FOUND'}")
else:
    print("[ERROR] No chainMembers in dashboard response")
    print(f"Response keys: {list(dashboard_json.keys())}")