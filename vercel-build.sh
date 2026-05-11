#!/bin/bash
set -e

echo "Starting build process..."

echo "1. Installing backend dependencies..."
cd backend
npm install
cd ..

echo "2. Starting Vercel build for Flutter..."
cd flutter_app

# Download Flutter
echo "Cloning Flutter repository..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# Export flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

echo "Running flutter doctor..."
flutter config --enable-web
flutter doctor -v

echo "Getting packages..."
flutter pub get

echo "Building web application..."
flutter build web --release

echo "Flutter build completed successfully!"
