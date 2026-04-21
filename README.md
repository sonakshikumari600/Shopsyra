Shopsyra Flutter App
A complete Flutter app with Landing Page, Login, and Signup screens based on the Shopsyra design.
Project Structure
shopsyra_app/
├── lib/
│   ├── main.dart                    # App entry point
│   └── screens/
│       ├── landing_screen.dart      # Landing page with nav & hero
│       ├── login_screen.dart        # Login page
│       └── signup_screen.dart       # Sign up page
└── pubspec.yaml
Features Implemented
Landing Screen

✅ Shopsyra logo & branding (Shop + syra in orange)
✅ "For Users" — clickable → info dialog
✅ "For Shops" — clickable → info dialog
✅ "About Us" — clickable → info dialog
✅ Hamburger menu (≡) — clickable → bottom sheet with all nav items
✅ Hero text with orange highlights
✅ Phone mockup with clothes grid
✅ Feature chips: Nearby Shops, Live Stock, Smart Search
✅ "Get Started" button → navigates to Login Screen
✅ Fade + slide animations on load

Login Screen

✅ Shopsyra logo header
✅ "Welcome Back!" heading
✅ Email & Password fields (no "Forgot Password" as requested)
✅ Password visibility toggle
✅ "Login" button → shows Welcome popup on success
✅ Facebook login button (shows "coming soon" snackbar)
✅ Google login button (shows "coming soon" snackbar)
✅ "Create an account" link → navigates to Signup Screen
✅ 🎉 Welcome popup dialog after successful login

Signup Screen

✅ Shopsyra logo header
✅ "Join Shopsyra!" heading
✅ Name, Email, Password fields
✅ Animated custom role dropdown (Admin / Shopkeeper / Shopper/User)
✅ Terms & Conditions checkbox (clickable — opens dialog)
✅ "Sign Up" button → shows Welcome popup, then redirects to Login
✅ Facebook & Google signup buttons
✅ "Log in" link → goes back to Login Screen
✅ 🎉 Welcome popup on successful signup

How to Run

Make sure Flutter is installed: https://flutter.dev/docs/get-started/install
Copy the shopsyra_app folder to your machine
Run:

bashcd shopsyra_app
flutter pub get
flutter run
Color Palette
NameHexPrimary Orange#D2691EDark Brown#3B1F0ALight Bg#F0EBE3Card Bg#FAF7F4Dark Section#2C1A0E