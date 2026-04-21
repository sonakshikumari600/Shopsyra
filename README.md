# 🛍️ Shopsyra - Smart Shopping Discovery App

## 📖 Overview

**Shopsyra** is a modern Flutter-based mobile application designed to revolutionize the shopping experience by connecting users with nearby shops in real-time. The app provides live stock updates, smart search capabilities, and seamless navigation to help shoppers discover products and stores effortlessly.

This is a **This project currently focuses on frontend development, showcasing a complete UI/UX flow. Backend integration is planned for future versions.** project showcasing a complete UI/UX implementation with authentication flows, interactive landing pages, and role-based user management.

---

## ✨ Features

- 🎯 **Interactive Landing Page** - Eye-catching hero section with animated elements and feature highlights
- 🔐 **User Authentication** - Complete login and signup flows with validation
- 👥 **Role-Based Access** - Support for Admin, Shopkeeper, and Shopper/User roles
- 📍 **Nearby Shops Discovery** - Feature to find local stores (UI ready)
- 📦 **Live Stock Updates** - Real-time inventory tracking interface
- 🔍 **Smart Search** - Intelligent product and shop search functionality
- 🎨 **Modern UI/UX** - Clean, responsive design with custom color palette
- 🌐 **Social Login Ready** - Facebook and Google login integration placeholders
- ✅ **Terms & Conditions** - Built-in legal agreement dialog
- 🎭 **Smooth Animations** - Fade and slide transitions for enhanced user experience

---

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform mobile framework |
| **Dart** | Programming language |
| **Material Design** | UI component library |
| **Custom Animations** | Enhanced user interactions |

---

## 📱 App Screens & Modules

### 1. **Landing Screen** (`landing_screen.dart`)
- Shopsyra branding with logo (Shop + **syra** in orange)
- Navigation menu with "For Users", "For Shops", and "About Us" sections
- Hamburger menu with bottom sheet navigation
- Hero section with highlighted text
- Phone mockup showcasing product grid
- Feature chips: Nearby Shops, Live Stock, Smart Search
- "Get Started" CTA button

### 2. **Login Screen** (`login_screen.dart`)
- Welcome back message
- Email and password input fields
- Password visibility toggle
- Login button with success popup
- Social login options (Facebook & Google)
- Link to signup screen
- 🎉 Welcome popup dialog on successful login

### 3. **Signup Screen** (`signup_screen.dart`)
- "Join Shopsyra!" heading
- Name, email, and password fields
- Animated role selection dropdown (Admin/Shopkeeper/Shopper)
- Terms & Conditions checkbox with dialog
- Sign up button with confirmation popup
- Social signup options
- Link to login screen
- 🎉 Welcome popup with auto-redirect to login

---

## 🚀 Installation Steps

### Prerequisites
- Flutter SDK (3.0 or higher) - [Install Flutter](https://flutter.dev/docs/get-started/install)
- Dart SDK (included with Flutter)
- Android Studio / VS Code with Flutter extensions
- Android Emulator or iOS Simulator / Physical device

### Step-by-Step Setup

1. **Clone or download the project**
   ```bash
   git clone <repository-url>
   cd user_shopsyra
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Check Flutter setup**
   ```bash
   flutter doctor
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

5. **Build for specific platform**
   ```bash
   # For Android
   flutter build apk
   
   # For iOS
   flutter build ios
   ```

---

## 💡 Usage Instructions

1. **Launch the app** - The landing screen appears with animations
2. **Explore navigation** - Click "For Users", "For Shops", or "About Us" to view info dialogs
3. **Get Started** - Tap the "Get Started" button to navigate to login
4. **Login** - Enter credentials or click "Create an account" to sign up
5. **Sign Up** - Fill in details, select role, accept terms, and create account
6. **Welcome Popup** - After signup, you'll see a welcome message and redirect to login

---

## 📂 Folder Structure

```
user_shopsyra/
├── lib/
│   ├── main.dart                    # App entry point & theme configuration
│   └── screens/
│       ├── landing_screen.dart      # Landing page with navigation & hero
│       ├── login_screen.dart        # Login authentication screen
│       └── signup_screen.dart       # User registration screen
├── pubspec.yaml                     # Dependencies & assets
├── .gitignore                       # Git ignore rules
└── README.md                        # Project documentation
```

---

## 🎨 Color Palette

| Color Name | Hex Code | Usage |
|------------|----------|-------|
| Primary Orange | `#D2691E` | Branding, CTAs, highlights |
| Dark Brown | `#3B1F0A` | Text, headers |
| Light Background | `#F0EBE3` | Page backgrounds |
| Card Background | `#FAF7F4` | Cards, containers |
| Dark Section | `#2C1A0E` | Footer, dark sections |

---

## 🔮 Future Enhancements

- 🔥 **Firebase Integration** - Backend authentication and database
- 🗺️ **Google Maps API** - Real-time shop location mapping
- 💳 **Payment Gateway** - In-app purchase functionality
- 📸 **Product Image Upload** - Allow shops to add inventory photos
- 💬 **Chat System** - Direct messaging between users and shops
- 🔔 **Push Notifications** - Stock alerts and promotional updates
- 📊 **Analytics Dashboard** - For shopkeepers to track performance
- 🌍 **Multi-language Support** - Localization for global reach
- ⭐ **Ratings & Reviews** - User feedback system
- 🛒 **Shopping Cart** - Add-to-cart and checkout flow

---

## 🤝 Contribution Guidelines

We welcome contributions! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Commit your changes**
   ```bash
   git commit -m "Add: your feature description"
   ```
4. **Push to your branch**
   ```bash
   git push origin feature/your-feature-name
   ```
5. **Open a Pull Request**

### Code Standards
- Follow Flutter/Dart style guidelines
- Write clean, commented code
- Test on both Android and iOS
- Update documentation for new features

---

## 📄 License

This project is licensed under the **MIT License**.

```
MIT License

Copyright (c) 2024 Shopsyra

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 👨‍💻 Developer

Sonakshi Kumari
Mani Chauhan
Poorva Chauhan

---

## 📞 Contact & Support

For questions, suggestions, or issues:
- 📧 Email: support@shopsyra.com
- 🐛 Issues: [GitHub Issues](https://github.com/your-repo/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/your-repo/discussions)

---

**⭐ If you like this project, please give it a star!**
