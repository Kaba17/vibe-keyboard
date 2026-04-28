# Vibe Keyboard — iOS Custom Keyboard Extension

## ما هو هذا المشروع؟

مشروع Xcode كامل يحتوي على:
- **VibeKeyboard** — تطبيق رئيسي يشرح كيفية تفعيل الكيبورد
- **VibeKeyboardExtension** — الكيبورد الفعلي الذي يعمل في كل التطبيقات

## كيف يعمل الكيبورد؟

1. أثناء كتابتك في أي تطبيق (واتساب، إنستا، ديسكورد...)، يحلل الكيبورد الكلمات
2. يظهر **Vibe Bar** (شريط بنفسجي داكن فوق المفاتيح) بـ GIFs مناسبة فوراً
3. اضغط على أي GIF لإرساله مباشرة

## كيفية فتح المشروع على Xcode

1. افتح `VibeKeyboard.xcodeproj` بـ Xcode (15+)
2. في Project Navigator، اختر project `VibeKeyboard`
3. في Signing & Capabilities، أضف Apple Developer Account الخاص بك
4. غيّر Bundle Identifier إلى: `com.yourname.vibekeyboard`
5. غيّر Bundle Identifier الـ Extension إلى: `com.yourname.vibekeyboard.keyboard`

## كيفية التشغيل على الجهاز

1. وصّل iPhone عبر USB
2. في Xcode: اختر `VibeKeyboard` كـ scheme والجهاز كـ destination
3. اضغط ▶ (Run)
4. على الجهاز: Settings → General → Keyboard → Keyboards → Add New Keyboard → Vibe Keyboard
5. فعّل **Allow Full Access** حتى تعمل الـ GIFs

## البنية التقنية

```
VibeKeyboard.xcodeproj
├── VibeKeyboard/                 # Container App (SwiftUI)
│   ├── VibeKeyboardApp.swift     # App entry point
│   ├── ContentView.swift         # Setup instructions UI
│   ├── Assets.xcassets/          # Icons & colors
│   └── Info.plist
└── VibeKeyboardExtension/        # Keyboard Extension
    ├── KeyboardViewController.swift  # Main keyboard logic
    │   ├── GiphyService          # Fetches GIFs from GIPHY API
    │   ├── KeyboardViewModel     # Real-time text analysis
    │   ├── VibeBarView           # SwiftUI GIF strip component
    │   ├── KeyboardView          # Full keyboard UI (SwiftUI)
    │   └── KeyboardViewController # UIInputViewController
    └── Info.plist
```

## ميزات الكود

- **50+ vibe keyword** → GIF mappings (laugh, love, wow, party...)
- **Debounced real-time analysis** — يحلل كل 400ms تجنباً للطلبات الزائدة
- **GIPHY API** integration مع تحميل تلقائي للـ thumbnails
- **SwiftUI** UI داخل `UIInputViewController`
- **Haptic feedback** على كل ضغطة مفتاح وعند اختيار GIF
- **Dark theme** Vibe Bar (#1A1033)
- **Globe key** للتنقل بين الكيبوردات

## ملاحظة مهمة: إرسال GIFs

بسبب قيود iOS على الـ Keyboard Extensions:
- GIFs يتم **نسخها للـ Clipboard** تلقائياً عند الضغط عليها
- النص `🎞️ [GIF copied - paste it]` يُدرج في حقل النص

للإرسال المباشر في تطبيقات مثل iMessage: يمكن الترقية لـ **iMessage Extension** مستقبلاً.

## Requirements

- Xcode 15+
- iOS 16+ deployment target
- Apple Developer Account (مجاني أو مدفوع)
- iPhone حقيقي (Simulator لا يدعم Keyboard Extensions)
