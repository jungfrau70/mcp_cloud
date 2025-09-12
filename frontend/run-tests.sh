#!/bin/bash

echo "🧪 Running Unit Tests for Implemented Features"
echo "=============================================="

echo ""
echo "1. Testing Path Utility Functions..."
npm run test tests/utils/path.spec.ts --run

echo ""
echo "2. Testing ContentView Back Button..."
npm run test tests/components/ContentView.back-button.spec.ts --run

echo ""
echo "3. Testing Path Duplication Integration..."
npm run test tests/integration/path-duplication.spec.ts --run

echo ""
echo "4. Running Core Feature Tests..."
npm run test tests/utils/ tests/components/ContentView.back-button.spec.ts tests/integration/path-duplication.spec.ts --run

echo ""
echo "✅ Core feature tests completed!"
