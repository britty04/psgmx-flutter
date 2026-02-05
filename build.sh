#!/bin/bash
set -e

echo "🚀 Starting Flutter Web build process..."

# Install Flutter if not already installed
if ! command -v flutter &> /dev/null; then
    echo "📦 Flutter not found. Installing Flutter..."
    
    # Clone Flutter stable
    git clone https://github.com/flutter/flutter.git -b stable --depth 1 /tmp/flutter
    export PATH="$PATH:/tmp/flutter/bin"
    
    # Disable analytics
    flutter config --no-analytics
    
    # Pre-download artifacts
    flutter precache --web
    
    echo "✅ Flutter installed successfully"
else
    echo "✅ Flutter already installed"
fi

# Verify Flutter installation
flutter --version

# Get dependencies
echo "📥 Getting Flutter dependencies..."
flutter pub get

# Build for web
echo "🏗️  Building Flutter Web..."
flutter build web \
  --release \
  --web-renderer canvaskit \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

echo "✅ Build completed successfully!"
