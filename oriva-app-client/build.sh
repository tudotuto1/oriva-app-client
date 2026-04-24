#!/bin/bash
set -e

if [ -d flutter ]; then
  cd flutter && git pull && cd ..
else
  git clone --depth 1 --branch stable https://github.com/flutter/flutter.git
fi

flutter/bin/flutter config --enable-web
flutter/bin/flutter pub get
flutter/bin/flutter build web --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
