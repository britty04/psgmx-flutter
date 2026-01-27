# PSGMX Flutter App - Complete Documentation

## 📱 What is PSGMX?

**PSGMX** is a comprehensive **Placement Preparation Mobile Application** built specifically for **PSG Technology MCA students** (Batch 2025-2027). The app helps students prepare for campus placements by tracking their daily progress, managing attendance, solving coding challenges, and staying updated with placement announcements.

Think of it as your **personal placement companion** that ensures you stay on track with your preparation while coordinators and team leaders monitor batch-wide progress.

---

## 🎯 Core Purpose

The app solves three major problems:

1. **Attendance Tracking** - Automated daily attendance with team-based marking
2. **LeetCode Progress Monitoring** - Real-time tracking of coding practice across the batch
3. **Task Management** - Daily challenges (LeetCode + Core CS topics) with deadline enforcement
4. **Announcements & Communication** - Instant updates about placement drives, deadlines, and important events

---

## 👥 Who Uses This App?

The app has **4 different user roles**, each with specific permissions:

### 1. **Student** (Most Common)
- View their own attendance, tasks, and LeetCode stats
- Mark daily task completion
- Receive announcements
- Track personal progress and streaks

### 2. **Team Leader**
- Everything a student can do, PLUS:
- Mark attendance for their assigned team members (7-8 students per team)
- View team-specific reports

### 3. **Placement Representative (Rep)**
- Full administrative access
- Create announcements for all students
- Upload tasks in bulk (via Excel/CSV)
- View batch-wide statistics and leaderboards
- Manage working days (mark holidays/working days)

### 4. **Coordinator**
- Similar to Rep but focused on viewing reports
- Assist Reps in batch management
- Access analytics and batch performance data

---

## 🔐 How Authentication Works

### Registration Flow

```
User opens app → Login Screen
       ↓
Enters PSG email (@psgtech.ac.in)
       ↓
System checks if email is in WHITELIST (database)
       ↓
If APPROVED → Send OTP to email
       ↓
User enters 6-digit OTP
       ↓
If OTP valid → Set password (min 6 characters)
       ↓
Account created → User redirected to Home Screen
```

**Important Security Features:**
- ✅ Only **@psgtech.ac.in** emails allowed
- ✅ Each email must be **pre-approved** by admin (whitelist system)
- ✅ **OTP-based verification** (6-digit code valid for 5 minutes)
- ✅ Passwords are encrypted by Supabase Auth
- ✅ Role assignment happens automatically based on whitelist entry

### Login Flow

```
User enters email + password
       ↓
Supabase validates credentials
       ↓
If valid → Fetch user profile from database
       ↓
Load user role and permissions
       ↓
Redirect to role-specific Home Screen
```

### Forgot Password Flow

```
User clicks "Forgot Password"
       ↓
Enters email → Receives OTP
       ↓
Enters OTP + New Password
       ↓
Password reset successful → Login again
```

---

## 📊 App Features Breakdown

### 1️⃣ **Home Screen** (Dashboard)

**What you see depends on your role:**

#### **Student Dashboard:**
- Welcome message with name
- **Motivational quote** (pre-written professional texts, no repeating quotes, changes daily)
- **Birthday greeting** (if today is your birthday)
- Today's attendance status (Present/Absent/On Leave/Not Marked)
- Attendance percentage (Current Month + Overall)
- LeetCode stats (Problems solved, Current streak)
- Recent announcements
- Quick actions: Mark Task, View Calendar

#### **Rep/Coordinator Dashboard:**
- Batch-wide statistics
- Today's attendance count (Present/Absent/On Leave)
- Total students registered
- Top performers (Weekly LeetCode leaderboard)
- Quick actions: Create Announcement, Upload Tasks, Mark Attendance
- Attendance management button

**Key Features:**
- Pull-to-refresh to update all data
- Auto-popup for attendance marking (only on class days)
- Real-time data from Supabase
- Offline support with cached data

---

### 2️⃣ **Attendance System**

#### **How Attendance Works:**

**Daily Flow (Automated):**
```
System checks if today is a WORKING DAY (Mon-Fri by default)
       ↓
At app login → Popup asks Team Leader to mark attendance
       ↓
Team Leader marks team members as:
  - Present
  - Absent
  - On Leave (OD)
       ↓
Data saved to Supabase with timestamp + marked_by info
       ↓
Students can view their status in Home Screen
```

**Working Day Configuration:**
- Default Class Days: **Monday, Tuesday, Thursday, and Odd Saturdays**
- Operating hours: 9 AM - 8 PM
- Reps can manually mark specific dates as:
  - **Holiday** (no attendance needed)
  - **Working Day** (even on weekends for special sessions)

**"No Class Today" Banner:**
- Non-class days (Wed, Fri, Even Saturdays, Sundays) show a clear banner
- Banner displays: **"No Class Today"**
- Prevents confusion about missing attendance
- Ensures attendance percentage only counts actual class days

**Attendance Lock:**
- Attendance can be marked **anytime during the working day**
- After 8 PM, marking is disabled by database rules
- Reps can **override** attendance in special cases (audit logged)

#### **Student View:**
Navigate to: **Attendance Tab**

Shows:
- Monthly calendar with color-coded days:
  - 🟢 Green = Present
  - 🔴 Red = Absent
  - 🟡 Yellow = On Leave
  - ⚪ Gray = Not Marked / Holiday / Non-Class Day
- **"No Class Today" Banner** - Displayed prominently on non-class days
- Attendance percentage (Month-wise + Overall)
  - **Automatically excludes non-class days** from calculation
- Stats: Total Present, Absent, On Leave, Holidays
- Clear indication: "Calculated excluding non-working days"

#### **Team Leader View:**
- Can mark attendance for assigned team members
- See team-specific attendance sheet
- Submit once for all team members at once

#### **Rep View:**
- Access **Daily Attendance Sheet** (all students)
- Mark bulk attendance for entire batch
- Export attendance reports (future feature)
- Override individual attendance records

---

### 3️⃣ **Tasks & Challenges**

#### **What are Daily Tasks?**

Every day, students receive:
1. **LeetCode Challenge** - A specific problem to solve
2. **Core CS Topic** - Read/practice a concept (e.g., OS, DBMS, Networks)

**Task Structure:**
- **Task Date** - When the task was assigned
- **LeetCode Problem** - Name + LeetCode link
- **Core Topic** - E.g., "Binary Search Trees" or "Process Scheduling"
- **Deadline** - Usually 11:59 PM on task date
- **Status** - Pending/Completed

#### **Student Flow:**

Navigate to: **Tasks Tab**

**View Tasks:**
- See today's task in a premium card design
- Click on LeetCode problem → Opens in browser
- After solving, student marks it as "Complete"
- System validates completion (future: auto-check via LeetCode API)

**Date Navigation:**
- Navigate to previous/upcoming days to see past/future tasks
- Can only submit tasks by deadline

#### **Rep Flow:**

Navigate to: **Tasks Tab → Upload Tasks**

**Two Upload Methods:**

**Method 1: Single Entry**
- Manually enter one task:
  - Task Date
  - LeetCode Problem Name
  - LeetCode URL
  - Core Topic
- Click "Publish" → Task assigned to all students

**Method 2: Bulk Upload (Excel/CSV)**
- Download template or upload Excel file with columns:
  - `date` | `leetcode_problem` | `leetcode_link` | `core_topic`
- **Advanced Features:**
  - ✅ Supports **multiple sheets** in one Excel file
  - ✅ **Automatic deduplication** - skips duplicate dates
  - ✅ **Safe updates** - updates existing dates without data loss
  - ✅ Validates all rows before importing
  - ✅ Shows preview before final upload
- System parses file and creates tasks for entire batch
- Success confirmation with count of tasks uploaded

**Example Excel Format:**
```
| date       | leetcode_problem      | leetcode_link                        | core_topic          |
|------------|-----------------------|--------------------------------------|---------------------|
| 2026-01-27 | Two Sum               | https://leetcode.com/problems/two-sum| Binary Search       |
| 2026-01-28 | Valid Parentheses     | https://leetcode.com/problems/valid-p| Stacks              |
```

---

### 4️⃣ **LeetCode Integration**

#### **How It Tracks Your Progress:**

**Setup:**
- Each student's LeetCode username is stored in the database
- System fetches stats from LeetCode GraphQL API (public data)

**What Gets Tracked:**
- Total problems solved (Easy, Medium, Hard)
- Current streak (consecutive days of solving)
- Weekly progress
- Overall ranking compared to batchmates

#### **Leaderboard:**

Navigate to: **Leaderboard Tab** (from Home Screen)

**Weekly Leaderboard:**
- Top performers based on problems solved this week
- Shows: Rank, Name, Problems Solved, Current Streak
- Updates every hour

**Overall Leaderboard:**
- All-time top performers
- Sorted by total problems solved

**Auto Refresh:**
- LeetCode stats refresh automatically every 24 hours
- Students can manually refresh from Profile Settings

---

### 5️⃣ **Announcements & Notifications**

#### **How Announcements Work:**

**Rep Creates Announcement:**
```
Rep goes to Home Screen → Click "Create Announcement"
       ↓
Fill in:
  - Title (e.g., "Google Drive on Jan 30")
  - Content (Details about the drive)
  - Priority (Low/Medium/High/Urgent)
       ↓
Click "Publish"
       ↓
Announcement saved to database
       ↓
All students receive notification (if permissions granted)
```

**Announcement Display:**

Home Screen shows:
- Latest 3-5 announcements
- Priority badge (color-coded):
  - 🔴 Urgent (Red)
  - 🟠 High (Orange)
  - 🟡 Medium (Yellow)
  - 🟢 Low (Green)
- Timestamp (e.g., "2 hours ago")

**Notification System:**
- Uses **Flutter Local Notifications**
- Students receive push notifications for:
  - High/Urgent announcements
  - Daily task reminders (8 AM)
  - Attendance reminders (if not marked by 6 PM)

**Mark as Read:**
- Students can dismiss announcements
- System tracks read/unread status per user

---

### 6️⃣ **Profile & Settings**

Navigate to: **Profile Tab** (Bottom Navigation)

**Student Profile Shows:**

**Personal Info:**
- Full Name
- Email (@psgtech.ac.in)
- Team Assignment (e.g., "Team A3")
- Registration Number
- LeetCode Username

**Statistics:**
- Attendance: X% (Current Month)
- LeetCode: X problems solved
- Current Streak: X days
- Tasks Completed: X/Y

**Settings:**
- Change Password
- Notification Preferences:
  - Daily task reminders
  - Attendance reminders
  - LeetCode leaderboard updates
  - **Birthday notifications** (toggle on/off)
- LeetCode Username Update
- Theme Toggle (Light/Dark mode)
- Date of Birth (editable, used for birthday greetings)
- **Help & Support Screen:**
  - What the app does
  - What the app does NOT do
  - Who to contact for issues
  - FAQs and troubleshooting
- Logout

**Dev Tools (Hidden for Students):**
- Reps can access admin controls
- View system logs
- Clear cache

---

## 🏗️ Technical Architecture

### **Technology Stack**

| Component           | Technology                  | Purpose                          |
|---------------------|-----------------------------|----------------------------------|
| **Frontend**        | Flutter 3.27+               | Cross-platform mobile UI         |
| **Backend**         | Supabase                    | Database, Auth, Realtime         |
| **Database**        | PostgreSQL (via Supabase)   | All app data storage             |
| **Authentication**  | Supabase Auth               | Email OTP, Password management   |
| **State Mgmt**      | Provider                    | App-wide state management        |
| **Routing**         | GoRouter                    | Navigation and deep linking      |
| **Local Storage**   | Shared Preferences          | Cache, offline data              |
| **Notifications**   | Flutter Local Notifications | Push notifications               |
| **Charts**          | FL Chart                    | Analytics graphs                 |
| **HTTP Calls**      | HTTP package                | LeetCode API integration         |

---

### **Database Schema (Supabase PostgreSQL)**

#### **Main Tables:**

**1. `users`**
```sql
- id (UUID, Primary Key)
- email (Unique, NOT NULL)
- name
- leetcode_username
- team_id (e.g., "A3", "B2")
- registration_number
- roles (JSONB: {isStudent, isTeamLeader, isRep, isCoordinator})
- created_at
- updated_at
```

**2. `whitelist`**
```sql
- email (Primary Key)
- name
- leetcode_username
- team_id
- dob (Date of Birth)
- is_approved (Boolean, default: true)
```

**3. `attendance`**
```sql
- id (UUID, Primary Key)
- student_id (Foreign Key → users.id)
- date (Date)
- status (present/absent/on_leave/not_applicable)
- marked_by (Foreign Key → users.id)
- marked_at (Timestamp)
- overridden_by (Nullable, for corrections)
```

**4. `attendance_days`**
```sql
- date (Primary Key)
- is_working_day (Boolean)
- reason (e.g., "Holiday: Republic Day")
- decided_by (Foreign Key → users.id)
```

**5. `daily_tasks`**
```sql
- id (UUID, Primary Key)
- task_date (Date, NOT NULL)
- leetcode_problem (Text)
- leetcode_link (URL)
- core_topic (Text)
- created_by (Foreign Key → users.id)
- created_at
```

**6. `leetcode_stats`**
```sql
- id (UUID, Primary Key)
- user_id (Foreign Key → users.id)
- total_solved (Integer)
- easy_solved
- medium_solved
- hard_solved
- current_streak
- last_updated (Timestamp)
```

**7. `notifications`**
```sql
- id (UUID, Primary Key)
- title (Text, NOT NULL)
- content (Text)
- priority (low/medium/high/urgent)
- created_by (Foreign Key → users.id)
- created_at
```

**8. `notification_reads`**
```sql
- notification_id (Foreign Key)
- user_id (Foreign Key)
- read_at (Timestamp)
- Primary Key: (notification_id, user_id)
```

**9. `audit_logs`**
```sql
- id (UUID, Primary Key)
- action (e.g., "ATTENDANCE_OVERRIDE", "TASK_UPLOAD")
- performed_by (Foreign Key → users.id)
- target_entity (e.g., "attendance", "task")
- details (JSON)
- timestamp
```

---

### **Security: Row Level Security (RLS)**

Every table has **RLS policies** to ensure:
- Students can only see **their own data**
- Team Leaders can only mark attendance for **their team**
- Reps have **full access** to all data
- No one can directly manipulate data without proper role

**Example RLS Policy (attendance table):**
```sql
-- Students can view only their own attendance
CREATE POLICY "Students view own attendance"
ON attendance FOR SELECT
TO authenticated
USING (student_id = auth.uid());

-- Team Leaders can mark attendance for their team only
CREATE POLICY "Team Leaders mark team attendance"
ON attendance FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users 
    WHERE id = auth.uid() 
    AND (roles->>'isTeamLeader')::boolean = true
  )
);
```

---

### **Code Architecture (Flutter)**

#### **Folder Structure:**

```
lib/
├── core/
│   ├── supabase_config.dart        # Supabase credentials
│   ├── app_router.dart             # GoRouter routes
│   ├── constants.dart              # App constants
│   └── theme/
│       ├── app_theme.dart          # Light/Dark themes
│       ├── app_colors.dart         # Color palette
│       └── app_dimens.dart         # Spacing, font sizes
│
├── models/
│   ├── app_user.dart               # User model
│   ├── attendance.dart             # Attendance model
│   ├── daily_task.dart             # Task model
│   ├── leetcode_stats.dart         # LeetCode stats model
│   ├── announcement.dart           # Notification model
│   └── ...
│
├── providers/                      # State Management (Provider)
│   ├── user_provider.dart          # Current user state
│   ├── attendance_provider.dart    # Attendance state
│   ├── leetcode_provider.dart      # LeetCode stats state
│   └── announcement_provider.dart  # Announcements state
│
├── services/                       # Business Logic Layer
│   ├── auth_service.dart           # Login, OTP, Password reset
│   ├── attendance_service.dart     # Attendance CRUD operations
│   ├── supabase_db_service.dart    # Database queries
│   ├── notification_service.dart   # Local notifications
│   ├── connectivity_service.dart   # Online/Offline detection
│   └── leetcode_auto_refresh_service.dart  # LeetCode API calls
│
└── ui/                             # UI Layer (Screens & Widgets)
    ├── auth/
    │   ├── login_screen.dart
    │   ├── verify_otp_screen.dart
    │   └── forgot_password_screen.dart
    │
    ├── home/
    │   ├── home_screen.dart        # Main dashboard
    │   └── widgets/
    │       ├── student_dashboard.dart
    │       ├── admin_dashboard.dart
    │       └── announcements_list.dart
    │
    ├── attendance/
    │   ├── attendance_screen.dart  # Calendar view
    │   └── daily_attendance_sheet.dart  # Team leader marking
    │
    ├── tasks/
    │   └── tasks_screen.dart       # Daily tasks + uploads
    │
    ├── profile/
    │   └── profile_screen.dart     # User profile + settings
    │
    └── widgets/                    # Reusable components
        ├── premium_card.dart
        ├── error_boundary.dart
        └── offline_banner.dart
```

---

### **Design Patterns Used:**

1. **Service-Repository Pattern**
   - Services handle business logic
   - Providers manage UI state
   - Clear separation of concerns

2. **Provider State Management**
   - `ChangeNotifier` for reactive UI updates
   - `MultiProvider` at app root
   - `Consumer` widgets for rebuilds

3. **Dependency Injection**
   - Services injected via Provider
   - Easy testing and mocking

4. **Error Handling**
   - Global error boundary
   - Try-catch in all async operations
   - User-friendly error messages

---

## 🔄 Complete User Flows

### **Flow 1: Student Daily Routine**

```
Morning (8 AM):
  → Open App
  → See notification: "Today's task is ready!"
  → Login (if not already)
  → Home Screen shows:
     - Attendance: Not Marked (waiting for Team Leader)
     - Today's Task: Two Sum (LeetCode)

Mid-Day (12 PM):
  → Team Leader marks attendance
  → Notification: "Attendance marked: Present"
  → Refresh Home Screen → Status updated

Evening (5 PM):
  → Solve LeetCode problem (Two Sum)
  → Open Tasks Tab
  → Click "Mark as Complete"
  → Status changes to "Completed"

Night (9 PM):
  → Check Leaderboard
  → See current rank: #15 (this week)
  → Check announcements: "TCS Drive on Feb 1"
  → Close app
```

---

### **Flow 2: Team Leader Marking Attendance**

```
Login → Home Screen shows:
  "You have 7 team members"

Click "Mark Attendance" button
       ↓
Daily Attendance Sheet opens
       ↓
List of 7 team members shown with radio buttons:
  - Ramesh Kumar: ⚪ Present  ⚪ Absent  ⚪ On Leave
  - Priya Singh:  ⚪ Present  ⚪ Absent  ⚪ On Leave
  ... (5 more)
       ↓
Team Leader selects status for each member
       ↓
Click "Submit Attendance"
       ↓
Success message: "Attendance marked for 7 students"
       ↓
Data saved to Supabase
       ↓
All team members receive notification
```

---

### **Flow 3: Rep Uploading Tasks**

```
Login as Rep → Home Dashboard
       ↓
Navigate to "Tasks" Tab
       ↓
Toggle to "Upload Tasks" section
       ↓
Choose Upload Method:
  ⚪ Single Entry
  ⚪ Bulk Upload (Excel)

[Option A: Single Entry]
  → Fill form:
     - Date: 2026-01-28
     - LeetCode Problem: "Valid Parentheses"
     - Link: https://leetcode.com/problems/valid-parentheses
     - Core Topic: "Stacks"
  → Click "Publish Task"
  → Success: Task assigned to all 123 students

[Option B: Bulk Upload]
  → Click "Pick Excel File"
  → Select file: tasks_jan_2026.xlsx
  → System parses 30 rows (30 days of tasks)
  → Preview shown:
     - Jan 1: Arrays + Two Sum
     - Jan 2: Strings + Reverse String
     ... (28 more)
  → Click "Upload All"
  → Success: 30 tasks created for 123 students each
  → Notification sent to all students
```

---

### **Flow 4: Rep Creating Announcement**

```
Login as Rep → Home Screen
       ↓
Click "Create Announcement" button
       ↓
Dialog appears with form:
  - Title: "Google Placement Drive"
  - Content: "Google is visiting on Jan 30. Eligibility: 7+ CGPA. Register by Jan 28."
  - Priority: [Urgent]
       ↓
Click "Publish"
       ↓
Announcement saved to database
       ↓
All 123 students receive:
  - In-app notification
  - Push notification (if enabled)
  - Announcement visible on Home Screen
       ↓
Students can read and dismiss it
```

---

## 📈 Key Features Summary

### ✅ **Attendance Management**
- Automated daily attendance tracking
- **Smart class day detection** (Mon, Tue, Thu, Odd Saturdays)
- **"No Class Today" banner** on non-class days
- Team-based marking system
- Calendar view with color-coded days
- Working day configuration (holidays/weekends)
- **Attendance percentage excludes non-class days** (fair calculation)
- Override capability for corrections (audit logged)

### ✅ **Task Management**
- Daily LeetCode + Core CS challenges
- Single and bulk upload options
- **Excel bulk upload with:**
  - Multi-sheet support
  - Automatic deduplication
  - Safe update of existing dates
  - Pre-upload validation
- Date-wise task navigation
- Deadline enforcement (11:59 PM)
- Task completion tracking
- Direct links to LeetCode problems

### ✅ **LeetCode Integration**
- Auto-fetch stats from LeetCode API
- Track: Total solved, Easy/Medium/Hard breakdown
- Current streak calculation
- Weekly + Overall leaderboards
- Auto-refresh every 24 hours
- Manual refresh option

### ✅ **Announcements System**
- Priority-based notifications (Low/Medium/High/Urgent)
- Real-time delivery to all students
- Push notifications for urgent items
- Read/unread tracking
- Admin-only creation rights

### ✅ **Role-Based Access Control**
- 4 distinct roles: Student, Team Leader, Coordinator, Rep
- Database-level RLS policies
- Role-specific UI components
- Secure whitelist-based registration

### ✅ **Security & Privacy**
- Email domain validation (@psgtech.ac.in only)
- Whitelist-based registration (pre-approved emails)
- OTP-based verification
- Encrypted password storage
- Row-level security on all tables
- Audit logging for admin actions

### ✅ **Offline Support**
- Local caching with Shared Preferences
- Offline banner when no internet
- Automatic sync when back online
- Graceful error handling

### ✅ **User Experience**
- Material 3 design system
- Light/Dark theme support (White + Orange / Black + Orange)
- Elegant custom fonts (not default system fonts)
- Responsive layouts (mobile/tablet)
- Pull-to-refresh on all screens
- Smooth animations and transitions
- Premium card designs
- **Birthday greetings** on user's special day
- **Pre-written motivational quotes** (professional, no repeats)
- Help & Support screen for user guidance

---

## 🚀 Installation & Setup

### **Prerequisites:**
```bash
# Required software
- Flutter SDK 3.27.0 or higher
- Dart 3.0+
- Android Studio / VS Code
- Git
```

### **Step 1: Clone Repository**
```bash
git clone https://github.com/brittytino/psgmx-flutter.git
cd psgmx-flutter
```

### **Step 2: Install Dependencies**
```bash
flutter pub get
```

### **Step 3: Configure Supabase**

1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Get your credentials:
   - Supabase URL
   - Anon Key
3. Update `lib/core/supabase_config.dart`:
```dart
class SupabaseConfig {
  static const supabaseUrl = 'YOUR_SUPABASE_URL';
  static const supabaseAnonKey = 'YOUR_ANON_KEY';
}
```

### **Step 4: Setup Database**

1. Go to Supabase Dashboard → SQL Editor
2. Run `database/01_create_schema.sql` (creates tables, RLS policies, functions)
3. Run `database/02_insert_data.sql` (inserts 123 students with LeetCode usernames)

✅ Verification:
```sql
SELECT COUNT(*) FROM users WHERE (roles->>'isStudent')::boolean = TRUE;
-- Should return: 123
```

### **Step 5: Run the App**
```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# Build APK
flutter build apk --release
```

---

## 📱 App Screens Overview

| Screen                    | Access                  | Purpose                               |
|---------------------------|-------------------------|---------------------------------------|
| **Splash Screen**         | App Launch              | Logo, loading animations              |
| **Login Screen**          | Unauthenticated         | Email + Password login                |
| **OTP Verification**      | After login email       | 6-digit OTP input                     |
| **Set Password**          | New user registration   | Create account password               |
| **Home Screen**           | All roles               | Role-specific dashboard               |
| **Attendance Screen**     | All roles               | Calendar view, mark attendance        |
| **Tasks Screen**          | Students                | View/complete daily tasks             |
| **Tasks Upload**          | Reps/Coords             | Single/bulk task upload               |
| **Leaderboard Screen**    | All roles               | LeetCode rankings                     |
| **Profile Screen**        | All roles               | Personal info, settings, logout       |
| **Settings Screen**       | All roles               | Preferences, theme, notifications     |
| **Daily Attendance Sheet**| Team Leaders, Reps      | Mark team/batch attendance            |
| **Reports Screen**        | Reps/Coords             | Batch analytics (future feature)      |

---

## 🔔 Notification Types

| Notification              | Trigger                          | Recipients        | Time          |
|---------------------------|----------------------------------|-------------------|---------------|
| **Daily Task Reminder**   | New task uploaded                | All students      | 8:00 AM       |
| **Attendance Reminder**   | Attendance not marked            | Team Leaders      | 6:00 PM       |
| **Urgent Announcement**   | Rep creates urgent announcement  | All students      | Immediate     |
| **Attendance Marked**     | Team leader submits attendance   | Team members      | Immediate     |
| **Task Deadline**         | 2 hours before deadline          | Students with pending tasks | 9:00 PM |
| **LeetCode Milestone**    | User reaches 50/100/200 problems | Individual student| On achievement|
| **Birthday Greeting**     | User's birthday (DOB field)      | Individual student| 12:00 AM (can disable)|

---

## 📊 Analytics & Reports

### **Student View:**
- Personal attendance percentage (monthly + overall)
- LeetCode problems solved (total + by difficulty)
- Current streak and longest streak
- Tasks completed vs. pending
- Rank on leaderboard

### **Rep/Coordinator View:**
- Batch-wide attendance statistics
- Daily attendance count (Present/Absent/On Leave)
- Top performers (weekly LeetCode leaderboard)
- Task completion rates
- Team-wise breakdown
- Export reports (future feature)

---

## 🛡️ Data Privacy & Compliance

✅ **No Personal Data Sharing**
- All data stays within Supabase database
- LeetCode usernames are public information only
- Email addresses not shared with third parties

✅ **Student Control**
- Students can update their LeetCode username
- Opt-out of non-critical notifications
- Request data deletion (contact admin)

✅ **Audit Logging**
- All admin actions (attendance override, task uploads) are logged
- Timestamp and user ID recorded for accountability

---

## 🐛 Troubleshooting

### **Common Issues:**

#### 1. **"Email not whitelisted"**
**Solution:** Contact placement coordinator to add your email to the whitelist.

#### 2. **"LeetCode stats not updating"**
**Solution:** 
- Check if LeetCode username is correct in Profile
- Make sure LeetCode profile is set to **Public**
- Wait 24 hours for auto-refresh or manually refresh

#### 3. **"Cannot mark attendance"**
**Solution:**
- Check if today is a working day (Mon-Fri by default)
- Attendance locks at 8 PM
- Contact Rep if you need an override

#### 4. **"Task not showing"**
**Solution:**
- Check date (tasks are date-specific)
- Pull to refresh on Tasks screen
- Check internet connection

#### 5. **"Login failed with OTP"**
**Solution:**
- OTP expires in 5 minutes
- Check spam folder for OTP email
- Request new OTP

---

## 🔮 Future Enhancements (Planned)

### **Version 1.1.0:**
- ✨ Push notifications for real-time updates
- ✨ Export attendance reports (PDF/Excel)
- ✨ Batch operations (mark entire team as present)
- ✨ Admin dashboard improvements

### **Version 1.2.0:**
- ✨ Dark mode optimizations
- ✨ Web platform support (Flutter Web)
- ✨ Advanced analytics with charts
- ✨ Multi-language support (Tamil, Hindi)

### **Version 2.0.0:**
- ✨ AI-powered task recommendations
- ✨ Auto-verify LeetCode submissions
- ✨ Mock interview scheduling
- ✨ Resume builder integration
- ✨ Placement drive application tracking

---

## 📞 Support & Contact

- **GitHub Issues:** [github.com/brittytino/psgmx-flutter/issues](https://github.com/brittytino/psgmx-flutter/issues)
- **Email:** Contact your batch placement representative
- **Contributing:** See [CONTRIBUTING.md](../CONTRIBUTING.md)
- **Code of Conduct:** See [CODE_OF_CONDUCT.md](../CODE_OF_CONDUCT.md)
- **Security Issues:** See [SECURITY.md](../SECURITY.md)

---

## 🎓 For Developers

### **Development Workflow:**

1. **Clone & Setup:**
```bash
git clone https://github.com/brittytino/psgmx-flutter.git
cd psgmx-flutter
flutter pub get
```

2. **Run in Development:**
```bash
flutter run --debug
```

3. **Code Style:**
- Follow Dart conventions
- Use `flutter analyze` before committing
- Format code: `dart format lib/`

4. **Testing:**
```bash
flutter test
```

5. **Build for Production:**
```bash
# Android APK
flutter build apk --release

# iOS (requires Mac + Xcode)
flutter build ios --release --no-codesign
```

### **Contributing:**
- Fork the repository
- Create a feature branch: `git checkout -b feature/new-feature`
- Commit changes: `git commit -m "Add new feature"`
- Push: `git push origin feature/new-feature`
- Create Pull Request

---

## 📄 License

This project is licensed under the **MIT License** - see [LICENSE](../LICENSE) file for details.

---

## 🙏 Acknowledgments

- **PSG Technology MCA Batch 2025-2027** - For inspiration and feedback
- **Flutter Team** - For the amazing framework
- **Supabase** - For free tier backend services
- **LeetCode** - For providing public APIs

---

## 📝 Changelog

See [CHANGELOG.md](../CHANGELOG.md) for detailed version history.

---

**Built with ❤️ for PSG MCA Placement Preparation**  
**© 2026 PSG Placement Team**

---

## 🎯 Quick Start Summary

**For Students:**
1. Download APK from GitHub Releases
2. Install on Android device
3. Login with @psgtech.ac.in email
4. Complete daily tasks and check attendance

**For Team Leaders:**
1. Same as students, PLUS:
2. Mark attendance for your team daily (before 8 PM)

**For Placement Reps:**
1. Login with admin credentials
2. Upload daily tasks (single or bulk)
3. Create announcements
4. Monitor batch-wide statistics

**For Developers:**
1. Clone repository
2. Setup Supabase (follow database README)
3. Update `supabase_config.dart`
4. Run `flutter pub get`
5. Run `flutter run`

---

**Need help? Check the sections above or create an issue on GitHub!** 🚀
