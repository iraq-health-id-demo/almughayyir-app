#!/usr/bin/env bash
# يجهّز مشروع المُغير بالكامل (macOS / Linux).
# يحتاج Flutter SDK مثبّتًا (flutter doctor يجب أن يكون سليمًا).
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> إنشاء مجلدات أندرويد و iOS"
flutter create . --project-name mughayyir --org com.mughayyir --platforms android,ios

echo "==> تثبيت الحزم"
flutter pub get

echo "==> توليد أيقونة التطبيق"
dart run flutter_launcher_icons

echo "==> ضبط اسم التطبيق (المُغير)"
if [ -f android/app/src/main/AndroidManifest.xml ]; then
  perl -pi -e 's/android:label="[^"]*"/android:label="المُغير"/' \
    android/app/src/main/AndroidManifest.xml
fi
if [ -f ios/Runner/Info.plist ]; then
  perl -0pi -e 's|(<key>CFBundleDisplayName</key>\s*<string>)[^<]*(</string>)|${1}المُغير${2}|' ios/Runner/Info.plist
  perl -0pi -e 's|(<key>CFBundleName</key>\s*<string>)[^<]*(</string>)|${1}المُغير${2}|' ios/Runner/Info.plist
fi

echo "==> فحص الكود والاختبارات"
flutter analyze
flutter test

echo "تم. شغّل التطبيق بالأمر: flutter run"
