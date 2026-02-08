# 🎓 PSGMX - Placement Excellence Program

<div align="center">

  ![PSGMX Logo](assets/images/psgmx_logo.png)

  > A professional placement preparation and batch management platform for PSG Technology - MCA Batch (2025-2027)

  [![Version](https://img.shields.io/badge/version-2.2.5-blue.svg)](pubspec.yaml)
  [![Downloads](https://img.shields.io/github/downloads/brittytino/psgmx-flutter/total.svg)](https://github.com/brittytino/psgmx-flutter/releases)
  [![Flutter](https://img.shields.io/badge/Flutter-3.27+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
  [![Supabase](https://img.shields.io/badge/Supabase-Production-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
  [![Firebase](https://img.shields.io/badge/Hosting-Firebase-FFCA28?logo=firebase&logoColor=white)](https://firebase.google.com)
  [![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

</div>

---

## 📖 About

**PSGMX** is a closed-community platform designed to streamline the placement preparation process for MCA students at PSG College of Technology. It bridges the gap between students, team leaders, and placement coordinators by providing tools for attendance tracking, task monitoring, and real-time communication.

---

## ✨ Key Features

### 👨‍🎓 For Students
- **📊 LeetCode Integration** - Track daily problem-solving progress
- **✅ Attendance Tracking** - QR-based or manual attendance marking
- **📢 Real-time Announcements** - Instant placement updates and deadlines
- **📈 Performance Analytics** - Personal dashboard with streaks and statistics
- **🎂 Birthday Celebrations** - Automated birthday greetings

### 👥 For Team Leaders
- **📋 Team Management** - Mark attendance for assigned team members
- **✓ Task Verification** - Track team's LeetCode completion
- **📊 Team Analytics** - View team performance metrics

### 🎯 For Coordinators & Admins
- **📣 Broadcast System** - Send broadcast announcements to the entire batch.
- **🛡️ Audit Logging** - Track important actions and changes within the system for security.
- **🔄 Version Control** - Force update mechanism to ensure everyone uses the latest critical version.
- **📂 Data Management** - Support for bulk data handling (CSV/Excel) for managing student records.
- **📈 Batch Statistics** - Comprehensive overview of the entire batch's progress.

---

## 🚀 Getting Started

### Prerequisites
*   [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.27+)
*   [Dart SDK](https://dart.dev/get-dart) (3.0+)
*   Supabase Account
*   Git

### Installation

1.  **Clone the repository**
```bash
git clone https://github.com/brittytino/psgmx-flutter.git
cd psgmx-flutter
```

2.  **Install Dependencies**
```bash
flutter pub get
```

3.  **Setup Supabase Database**
1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Run database scripts in order (see [database/README.md](database/README.md)):
   - `01_schema.sql`
   - `02_data.sql`
   - `03_functions.sql`
   - `04_rls_policies.sql`
   - `05_sample_data.sql`
   - `09_app_config.sql`

4.  **Configure Environment**
Create `.env` file in project root:
```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

5.  **Run the App**
```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

---

## 📦 Build for Production

### Web (For Firebase Hosting)
```bash
flutter build web --release --web-renderer canvaskit
```

### Android APK
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

---

## 🌐 Deploy to Firebase Hosting

### Quick Deploy
```bash
# Build
flutter build web --release --web-renderer canvaskit

# Deploy
firebase deploy --only hosting
```

### Automatic Deployment
Every push to `main` branch automatically deploys via GitHub Actions!

**See complete setup guide**: [FIREBASE_DEPLOYMENT.md](FIREBASE_DEPLOYMENT.md)

**Your live URL**: `https://psgmxians.web.app`

---

## 📁 Project Structure

```
lib/
├── core/              # App configuration, theme, constants
├── models/            # Data models (User, Announcement, etc.)
├── providers/         # State management (Provider pattern)
├── services/          # API services (Supabase, LeetCode, etc.)
└── ui/                # Screens and widgets
    ├── admin/         # Admin controls & Batch management
    ├── auth/          # Authentication screens
    ├── home/          # Dashboard and home screen
    ├── tasks/         # LeetCode & Daily tasks
    ├── attendance/    # Attendance tracking
    ├── leaderboard/   # LeetCode leaderboard
    └── widgets/       # Reusable widgets

database/
├── 01_schema.sql      # Database tables and structure
├── 02_data.sql        # Student data (123 students)
├── 03_functions.sql   # Database functions
├── 04_rls_policies.sql # Security policies
├── 05_sample_data.sql # Sample/test data
├── 09_app_config.sql  # App configuration
└── migrations/        # Database migration scripts
```

---

## 🛠️ Tech Stack & Architecture

- **Build for Web**: `flutter build web --release --web-renderer canvaskit`
- **Frontend**: Flutter 3.27+ (Web, Android)
- **Backend**: Supabase (PostgreSQL, Auth, Realtime)
- **Deployment**: Firebase Hosting (Web), GitHub Releases (Android APK)
- **State Management**: Provider with Service-Oriented Logic
- **Architecture**: Modular feature-first structure

---

## 🤝 Contributing

We welcome contributions from the PSG MCA community! To maintain the high standard of this platform, please follow these guidelines:

### Development Workflow
1. **Repository Alignment**: Ensure you are familiar with the `Provider` pattern and the service-oriented architecture used throughout the app.
2. **Quality Control**: Before submitting any PR, ensure that `flutter analyze` returns **no issues**. Code consistency and linting are strictly enforced.
3. **Drafting Changes**: Create a descriptive feature branch (`git checkout -b feature/your-feature-name`).
4. **Testing**: Verify your changes across both Web and Android if they affect cross-platform components.
5. **Documentation**: Update the relevant documentation if your changes introduce new architecture or database schemas.

See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for community guidelines and [CONTRIBUTING.md](CONTRIBUTING.md) for deep-dive technical requirements.

---

## 📊 Database Schema

Complete database documentation available in [database/README.md](database/README.md)

**Key Tables**:
- `users` - Student and admin profiles
- `whitelist` - Approved email list (123 students)
- `attendance_records` - Attendance tracking
- `leetcode_stats` - LeetCode progress
- `announcements` - Placement updates
- `notifications` - User notifications

---

## 🔒 Security

- Row Level Security (RLS) enabled on all tables
- Email-based OTP authentication
- Role-based access control (Student, Team Leader, Coordinator, Placement Rep)
- Secure API key management

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## �‍💻 Author

**Tino Britty J**
- GitHub: [@brittytino](https://github.com/brittytino)
- Portfolio: [tinobritty.me](https://tinobritty.me)
- Project: [PSGMX Flutter](https://github.com/brittytino/psgmx-flutter)

---

## 🙏 Acknowledgments

- PSG College of Technology - MCA Department
- All 123 students of MCA Batch 2025-2027
- Open source Flutter and Supabase communities

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/brittytino/psgmx-flutter/issues)
- **Live Demo**: [https://psgmxians.web.app](https://psgmxians.web.app)
- **Documentation**: [Project Wiki](https://github.com/brittytino/psgmx-flutter/wiki)

---

## 🎯 Roadmap

- [x] Basic authentication and user management
- [x] LeetCode integration and leaderboard
- [x] Attendance tracking system
- [x] Real-time announcements
- [x] Web deployment on Firebase Hosting
- [ ] Push notifications for mobile
- [ ] Advanced analytics dashboard
- [ ] Interview preparation resources
- [ ] Company-specific preparation modules

---

**Built by PSG MCA Placement Coordinators with entire team support. Thanks to all students.**
