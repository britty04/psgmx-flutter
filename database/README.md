# 🗄️ Database Setup Guide

Complete PostgreSQL/Supabase database schema for PSGMX Placement Prep App.
**Last Updated: v2.2.5**

## 📋 Quick Start

Run these SQL files in order in your Supabase SQL Editor:

1. **`01_schema.sql`** - Creates tables, types, and extensions.
2. **`02_policies.sql`** - Sets up Role Level Security (RLS) for all tables.
3. **`03_functions.sql`** - Creates helper functions, RPCs, and Views.
4. **`04_triggers.sql`** - Automates notifications and timestamp updates.
5. **`05_seed_data.sql`** - Seeds the database with student whitelist and default config.

## 📁 File Structure

```
database/
├── README.md               # This file
├── 01_schema.sql           # 🏗️ Core Tables
├── 02_policies.sql         # 🔒 Security Policies (RLS)
├── 03_functions.sql        # ⚡ Database Functions
├── 04_triggers.sql         # 🤖 Automation Triggers
└── 05_seed_data.sql        # 🌱 Student Whitelist & Config
```

## 🔧 Setup Instructions

### 1. Create a Supabase Project
- Go to [supabase.com](https://supabase.com)
- Create a new project
- Note down your project URL and anon key

### 2. Run Database Scripts
In the Supabase SQL Editor (or using `psql`), execute the files in sequential order:

```sql
-- 1. Schema
\i 01_schema.sql

-- 2. Security
\i 02_policies.sql

-- 3. Functions
\i 03_functions.sql

-- 4. Triggers
\i 04_triggers.sql

-- 5. Data
\i 05_seed_data.sql
```

## �️ Schema Reference

### Core Tables
| Table | Description | Key Relationships |
| :--- | :--- | :--- |
| **`users`** | Extended profile for authenticated users (names, roles, avatar). | Links to `auth.users` |
| **`whitelist`** | Master list of 123 allowed students. Pre-populates roles & teams. | Source of truth for registration |
| **`app_config`** | Remote configuration for app versioning and maintenance mode. | Singleton row |

### Academic Module
| Table | Description | Key Relationships |
| :--- | :--- | :--- |
| **`attendance_records`** | Daily check-in logs with "Present/Absent" status. | `user_id`, `team_leader_id` |
| **`scheduled_attendance`** | Dates when attendance marking is enabled. | Defines valid dates |
| **`daily_tasks`** | Technical tasks (LeetCode/Aptitude) assigned to the batch. | Created by Coordinators |
| **`task_completions`** | Records of students completing assigned tasks. | `task_id`, `user_id` |

### Integrations
| Table | Description | Key Relationships |
| :--- | :--- | :--- |
| **`leetcode_stats`** | Daily synced statistics from LeetCode API (Solved count, ranking). | `username` (unique) |
| **`calendar_events`** | Exam schedules and placement drive dates. | - |
| **`notifications`** | System-generated alerts for the "Updates" screen. | Triggered by events |

## �🎯 Important Notes
- **User Roles:** The whitelist (in `05_seed_data.sql`) defines who is a Student, Team Leader, or Coordinator.
- **Admin Access:** Some RLS policies reference `service_role`. Keep your service role key secure.
- **App Config:** The app versioning settings are initialized in `05_seed_data.sql` into the `app_config` table.

## 🔄 Maintenance
To update the database in the future, please add new migration scripts in a `migrations/` folder (if created) or update these base files directly for a fresh install.
