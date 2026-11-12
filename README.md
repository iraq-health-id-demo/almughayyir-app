# المُغير

تطبيق Flutter (أندرويد + iOS) لتنظيم حجوزات الأطباء في العيادات الخاصة. البيانات تُخزَّن محليًا على الجهاز (SQLite) ولا يحتاج التطبيق إلى إنترنت.

## المزايا

- قائمة الأطباء مع الاختصاص، وبحث، وإضافة / تعديل / حذف طبيب.
- داخل كل طبيب: **كبار** و **صغار**، وكل قسم مقسّم إلى **ذكور** و **إناث**.
- الحجوزات: مراجعات وعمليات، مع نوعها وموعدها والمبلغ المترتب والملاحظات.
- إضافة حجز، تعديله، **تقديم / تأجيل** موعده، **إلغاؤه** (مع إمكانية الاستعادة)، أو حذفه نهائيًا.
- ترتيب بحسب التاريخ (تصاعديًا / تنازليًا)، وتصفية (نشطة / ملغاة / الكل) و(مراجعات / عمليات).
- مجموع المبالغ لعدد الحجوزات الظاهرة.
- تنبيه عند وجود حجز آخر لنفس الطبيب في نفس الوقت.
- واجهة عربية بالكامل (RTL).

## التشغيل

المتطلبات: [Flutter SDK](https://docs.flutter.dev/get-started/install) (يُفضَّل أحدث إصدار مستقر). لبناء نسخة iOS يلزم جهاز Mac مع Xcode.

### الطريقة السريعة (macOS / Linux)

```bash
bash tool/setup.sh
flutter run
```

### الطريقة اليدوية (تعمل على Windows أيضًا)

```bash
flutter create . --project-name mughayyir --org com.mughayyir --platforms android,ios
flutter pub get
dart run flutter_launcher_icons
flutter run
```

ثم غيّر اسم التطبيق الظاهر على الجهاز إلى «المُغير»:

- أندرويد: في `android/app/src/main/AndroidManifest.xml` اجعل `android:label="المُغير"`.
- iOS: في `ios/Runner/Info.plist` اجعل قيمة `CFBundleDisplayName` و`CFBundleName` هي `المُغير`.

> الأمر `flutter create .` لا يستبدل ملفات `lib/` و`pubspec.yaml` الموجودة، ويضيف فقط مجلدي `android/` و`ios/`.

## البناء للنشر

```bash
flutter build appbundle      # أندرويد (Google Play)
flutter build apk            # أندرويد (ملف APK)
flutter build ipa            # iOS (على Mac)
```

للنشر الفعلي غيّر معرّف التطبيق `com.mughayyir.mughayyir` إلى معرّفك الخاص، وجهّز توقيع التطبيق (Keystore لأندرويد، و Signing في Xcode لـ iOS).

## هيكل المشروع

```
lib/
  main.dart, app.dart          نقطة الدخول والتطبيق
  core/                        الألوان، التنسيق، قراءة المبالغ، أدوات الواجهة
  models/                      Doctor, Appointment, enums
  data/                        قاعدة SQLite و Repository
  state/app_state.dart         الحالة (Provider)
  screens/                     الأطباء، الطبيب، الحجوزات، نموذج الحجز
  widgets/                     بطاقة الحجز، نموذج الطبيب، حالة فارغة
assets/icon/                   الأيقونة (الأصلية + نسخة بدون زوايا بيضاء + طبقة أمامية)
test/                        اختبارات النماذج وقراءة المبالغ
```

## ملاحظات

- العملة المعروضة «د.ع» (دينار عراقي)، ويمكن تغييرها من `Fmt.currency` في `lib/core/formatters.dart`.
- حذف طبيب يحذف جميع حجوزاته.
- النسخ الاحتياطي والمزامنة بين أجهزة متعددة غير مضمّنين في هذه النسخة (البيانات محلية).
