#!/bin/bash

# Start the backend
cd backend
npm run dev &
BACKEND_PID=$!
sleep 3

# Test registration
echo "=== Testing Registration ==="
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "securePass123!",
    "nombre": "Test User",
    "telefono": "555-1234"
  }'

echo -e "\n\n=== Testing Login ==="
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "securePass123!"
  }'

# Cleanup
kill $BACKEND_PID
