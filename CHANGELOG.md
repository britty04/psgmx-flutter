# Changelog

All notable changes to PSG MCA Placement Prep App will be documented in this file.

## [2.2.1] - 2026-02-05

### 🔧 Fixes
- Fixed Android keystore compatibility issues ("Tag number over 30 not supported")
- Updated keystore to PKCS12 format with 2048-bit RSA keys for Android build tools compatibility
- Ensured proper keystore format for GitHub Actions releases

## [2.1.0] - 2026-02-05

### 🎉 Production Release - Open Source Ready

#### ✨ New Features
- **iOS PWA Installation Guide**: Professional step-by-step guide for iOS users to install as Progressive Web App
- **Smart Platform Detection**: Auto-detects iOS Safari and shows installation guide only when needed
- **Firebase Hosting Deployment**: Fully automated deployment pipeline with GitHub Actions
- **Android APK Signing**: Production-ready signed APKs for direct distribution

#### 🏗️ Infrastructure
- Cleaned up duplicate GitHub Actions workflows
- Optimized Firebase deployment with proper Flutter setup
- Added proper keystore management for Android releases
- Automated deployment on every push to main branch
- Live deployment: [https://psgmxians.web.app](https://psgmxians.web.app)

#### 🐛 Bug Fixes
- Removed unused imports and dead code
- Fixed null safety issues in update service
- Cleaned up unused methods and fields
- Optimized codebase for production

#### 📚 Documentation
- Added comprehensive author attribution
- Updated README with proper GitHub links
- Created CODEOWNERS file for maintainability
- Added detailed setup guides for contributors
- Included deployment documentation

#### 🎨 Code Quality
- Passed all Dart analysis checks
- Removed unused declarations
- Optimized imports and dependencies
- Enhanced code documentation
- Clean architecture ready for open source contributions

---

## [1.0.5] - 2026-01-28

### Production Release - All Critical Issues Fixed

#### ✨ Features
- Complete OTP-based authentication system with password setup
- LeetCode stats integration with real-time leaderboard
- Team-based attendance marking system (all 123 students from whitelist)
- Announcement system with auto-expiry functionality
- Birthday notifications
- Role-based access control (Student, Team Leader, Coordinator, Placement Rep)
- Modern Material 3 UI with dark mode support
- Progress indicators for LeetCode API fetching

#### 🔧 Fixed Issues
- OTP flow now requires password before account creation (single-step form)
- Birthday notification permission errors on Android 12+ (inexact alarms)
- LeetCode API progress indicators with real-time status
- Leaderboard UI overflow (48px) resolved
- Attendance system fetches from whitelist (all students available)
- All opacity assertion errors fixed

#### 🏗️ Architecture
- Provider-based state management
- Supabase backend with PostgreSQL
- RESTful API integration for LeetCode stats
- Row-Level Security (RLS) policies
- Whitelist as source of truth for student roster

#### 📱 Platform Support
- ✅ Android (API 21+)
- ✅ iOS (iOS 12.0+)

---
- Server-side attendance lock enforcement
- Audit logging for admin actions

### Known Limitations
- Requires Firebase Free plan or higher
- Offline mode has limited functionality
- Maximum 123 concurrent users (seeded)

---

## Future Releases

### [1.1.0] - Planned
- Admin dashboard improvements
- Enhanced reporting features
- Batch operations for team management
- Push notifications support

### [1.2.0] - Planned
- Dark mode theme optimization
- Localization support
- Web platform support
- Advanced analytics

---

**For more details, see [README.md](README.md)**
