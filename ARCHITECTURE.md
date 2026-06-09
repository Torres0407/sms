# School Management System (SMS) — Full Planning & Architecture Document

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Tech Stack](#2-tech-stack)
3. [Portals & User Roles](#3-portals--user-roles)
4. [Multi-Tenant Architecture](#4-multi-tenant-architecture)
5. [Authentication & Authorization](#5-authentication--authorization)
6. [Folder Structure](#6-folder-structure)
7. [Database Schema](#7-database-schema)
8. [API Design & Endpoints](#8-api-design--endpoints)
9. [Exam Engine Workflow](#9-exam-engine-workflow)
10. [File Storage Structure](#10-file-storage-structure)
11. [Notifications & Realtime](#11-notifications--realtime)
12. [Reporting](#12-reporting)
13. [Payments](#13-payments)
14. [Deployment & CI/CD](#14-deployment--cicd)
15. [Feature Tier System](#15-feature-tier-system)
16. [Remaining Decisions Log](#16-remaining-decisions-log)

---

## 1. System Overview

The SMS is a **multi-tenant SaaS school management platform** sold to individual schools. Each school is an isolated tenant sharing the same codebase and infrastructure but with completely separate data, branding, and feature access.

### Deployment Targets

| Surface | Technology | Target Users |
|---|---|---|
| Desktop App | Next.js + Electron | Admin, Super Admin, Accountant, Exam Officer |
| Web App | Next.js (browser) | Students, Parents, Admissions |
| Public Website | Next.js (browser) | General public per school |
| Backend API | Spring Boot | All surfaces |

### High-Level Flow

```
Next.js (Web) + Electron (Desktop)
              ↓
        NGINX Reverse Proxy
              ↓
       Spring Boot REST API
              ↓
   PostgreSQL  |  Redis  |  AWS S3
```

---

## 2. Tech Stack

### Infrastructure

| Layer | Technology | Purpose |
|---|---|---|
| Hosting | VPS (e.g. Hetzner / DigitalOcean) | Single server, no load balancer initially |
| Containerisation | Docker + Docker Compose | Isolated services, easy deployment |
| Reverse Proxy | NGINX | Route traffic, SSL termination, serve static files |

### Frontend

| Technology | Role |
|---|---|
| Next.js 14+ (App Router) | All web and Electron UIs |
| TypeScript | Type safety across all frontends |
| Tailwind CSS | Utility-first styling |
| shadcn/ui | Pre-built accessible component library |
| Electron | Desktop wrapper for admin-side portals |
| Zustand or React Query | State management and server state |

### Backend

| Technology | Role |
|---|---|
| Spring Boot 3.x | REST API, business logic |
| Modular Monolith | Clean module separation without microservices complexity |
| Spring Security + JWT | Auth and role-based access control |
| Spring Data JPA | ORM for PostgreSQL |
| WebSocket (STOMP) | Realtime GC messages and notifications |

### Data Layer

| Technology | Role |
|---|---|
| PostgreSQL | Primary relational database (multi-tenant via schema-per-tenant or row-level tenant ID) |
| Redis | Session cache, JWT token blacklist, notification queue, rate limiting |
| AWS S3 | File storage — profile photos, documents, report cards, exam resources |

### Supporting Services

| Technology | Role |
|---|---|
| JasperReports | PDF report generation (result sheets, fee receipts, broadsheets) |
| Paystack / Flutterwave | Online fee payment gateway |
| JavaMailSender / SMTP | Email notifications |
| Africa's Talking / Termii | SMS notifications (Nigerian market) |

---

## 3. Portals & User Roles

### Electron Desktop Portals

These run as installed desktop apps — suitable for school staff working on-premises.

#### Super Admin Portal
- Manage all school tenants (create, suspend, delete)
- Set branding per school (name, logo, colours, banner)
- Toggle feature locks per school
- Manage subscriptions and billing
- View audit logs across all tenants
- Broadcast global announcements

#### Admin Portal
- Staff management (add/edit/deactivate teachers, secretary, accountant)
- Student management (enrol, transfer, graduate, archive)
- Class management (create classes, assign class teachers)
- Timetable builder (drag-and-drop per class/subject/teacher)
- School-wide announcement board
- Document centre (upload circulars, policies)
- Academic year and term configuration
- Grading scale and subject list settings

#### Accountant Portal
- Fee type management (tuition, levies, PTA, etc.) per class
- Payment records (filter by student, class, fee type, date, payment method)
- Invoice and receipt generator (PDF via JasperReports)
- Outstanding fees list with bulk reminder dispatch
- Event budget planner (create event → itemise → track actuals vs budget)
- Financial reports (term income, expense breakdown — export PDF/Excel)
- Petty cash log with approval workflow
- Payroll module *(Premium tier)*
- Full audit trail on every financial action

#### CBT / Exam Portal (Electron)
- Internal exam management (create, schedule, assign invigilators)
- Mock exam centre — separate for GCE / WAEC / JAMB
- Question bank (by subject and exam type; supports MCQ and theory)
- Bulk or manual score entry
- Broadsheet generator
- Exam timetable publisher (auto-visible to students and parents)
- Result release controls (hold results until Principal approves)

---

### Web Portals (Browser)

#### Student Portal
- Dashboard (timetable, assignments, results summary, fee balance)
- My results (term results, class position, teacher comments)
- Attendance record (personal history)
- Class Group Chat (GC) — text messages, read/post
- Assignments (view, download resources, submit if enabled)
- School announcements (read-only)
- Anonymous teacher feedback submission
- Profile (view info, update photo)

#### Parent Portal
- Dashboard (child summary: results, attendance %, fee balance, upcoming events)
- My child's results (full history, download report card PDF)
- Child's attendance record (with dates and reason if filed)
- Fee payment (view outstanding, pay online, receipt history)
- School announcements and circulars
- Reminders and alerts (fee due dates, parent-teacher meetings, exam schedules)
- My child's profile (class, teacher, photo)
- Message secretary (raise query, reply in-thread)
- Multi-child support *(Standard tier)*

#### Admissions Portal
- New student application form
- Document upload (birth certificate, passport photo, previous results)
- Application status tracker (pending → reviewed → accepted / rejected)
- Offer letter download
- Online application fee payment
- Automated email/SMS acknowledgements

#### Public Website (per school)
- School homepage (editable by Admin)
- About page, Gallery, News & Events
- Fee structure display (optional — toggled by Admin)
- Contact form (routes to Secretary)
- Admissions CTA (links to Admissions Portal)
- Fully branded per school (logo, colours, domain)

---

### Additional Portals

#### Principal Portal (Web + desktop accessible via Admin app)
- Dashboard — school-wide KPIs (attendance rate, fee collection %, exam averages)
- Teacher feedback inbox (anonymous student reports)
- GC trigger-word alert centre
- Staff appraisal notes
- Discipline log (view/approve disciplinary actions from teachers)
- Academic performance reports (class-by-class, subject-by-subject)
- Alert centre (trigger words, missed attendance filings, overdue fees)

#### Secretary Portal (Web)
- Daily task list and pending admissions
- Correspondence log (letters/emails to parents)
- School calendar and events management
- Visitor log (sign in/out, link to student)
- Staff leave request inbox (route to Admin/Principal)
- Automated reminder dispatch (fees, meetings)

#### Teacher Portal (Web)
- My classes and today's timetable
- Attendance marking (per class, per day; locked after window closes)
- Gradebook (CA scores, midterm, end-of-term)
- Class GC (moderator role — can delete messages, mute students)
- Lesson planner (upload notes, set assignments, due dates)
- Student profiles (read-only — basic info and academic history)
- Discipline report (raise issue, routed to Principal)
- Leave request submission

---

## 4. Multi-Tenant Architecture

### Strategy: Row-Level Tenancy

Every table that holds tenant-specific data includes a `tenant_id` (UUID) column. All queries are filtered by `tenant_id` at the service layer. This is simpler than schema-per-tenant and works well for a modular monolith.

### Tenant Resolution

```
Request → NGINX → Spring Boot
  → Extract subdomain or custom domain header
  → TenantContextHolder.setTenant(tenantId)
  → All JPA queries automatically scoped to tenantId
```

Use a `TenantFilter` (Spring `OncePerRequestFilter`) that:
1. Reads the `X-Tenant-ID` header or resolves from the subdomain
2. Sets the tenant in a `ThreadLocal` context
3. All service-layer queries receive the tenant from context — developers never pass tenant ID manually

### Tenant Data Model

```sql
tenants
  id            UUID PK
  slug          VARCHAR UNIQUE   -- e.g. "greenfield" → greenfield.sms.com
  name          VARCHAR
  logo_url      VARCHAR
  primary_color VARCHAR
  accent_color  VARCHAR
  banner_url    VARCHAR
  tier          ENUM(FREE, STANDARD, PREMIUM)
  is_active     BOOLEAN
  created_at    TIMESTAMP

tenant_features
  id            UUID PK
  tenant_id     UUID FK → tenants
  feature_key   VARCHAR          -- e.g. "ONLINE_PAYMENTS", "MOCK_EXAMS"
  is_enabled    BOOLEAN
```

### Tenant Isolation Rules

- Super Admin API calls do NOT require a tenant context — they operate across all tenants
- All other roles must have a valid `tenant_id` in their JWT
- A user from Tenant A can never access Tenant B's data — enforced at service layer, not just UI
- Redis keys are namespaced: `tenant:{tenantId}:session:{userId}`
- S3 paths are namespaced: `tenants/{tenantId}/...`

---

## 5. Authentication & Authorization

### Strategy

- **JWT (short-lived access token)** — 15-minute expiry, sent in `Authorization: Bearer` header
- **Refresh token** — 7-day expiry, stored in `HttpOnly` cookie
- **Redis token blacklist** — for logout and forced session revocation
- **Spring Security** — role-based and permission-based access control

### JWT Payload

```json
{
  "sub": "user-uuid",
  "tenantId": "tenant-uuid",
  "role": "TEACHER",
  "permissions": ["ATTENDANCE_WRITE", "GRADEBOOK_WRITE", "GC_MODERATE"],
  "iat": 1700000000,
  "exp": 1700000900
}
```

### Roles

| Role | Scope |
|---|---|
| `SUPER_ADMIN` | Platform-wide, all tenants |
| `ADMIN` | Single tenant, full school access |
| `PRINCIPAL` | Single tenant, read-heavy + feedback/alerts |
| `TEACHER` | Own classes only |
| `ACCOUNTANT` | Finance module only |
| `SECRETARY` | Admissions, calendar, correspondence |
| `EXAM_OFFICER` | Exam module only |
| `STUDENT` | Own data only |
| `PARENT` | Own children's data only |

### Permission System

Roles map to permission sets. Fine-grained permissions follow the pattern `MODULE_ACTION`:

```
ATTENDANCE_READ, ATTENDANCE_WRITE
GRADEBOOK_READ, GRADEBOOK_WRITE
FINANCE_READ, FINANCE_WRITE
EXAM_READ, EXAM_WRITE, EXAM_PUBLISH
STUDENT_READ, STUDENT_WRITE
STAFF_READ, STAFF_WRITE
GC_READ, GC_WRITE, GC_MODERATE
FEEDBACK_READ (Principal only), FEEDBACK_WRITE (Student only)
REPORT_READ, REPORT_GENERATE
TENANT_MANAGE (Super Admin only)
```

### Auth Endpoints

```
POST /api/auth/login
POST /api/auth/refresh
POST /api/auth/logout
POST /api/auth/forgot-password
POST /api/auth/reset-password
GET  /api/auth/me
```

### Anonymous Feedback — Special Handling

Student feedback submissions strip the student's user ID before persisting. The flow:

1. Student submits feedback → backend receives with authenticated JWT
2. A dedicated `FeedbackService.submit()` method creates the record with `student_id = NULL`
3. The student's session ID is also not stored
4. Only `teacher_id`, `content`, `submitted_at`, and a random `reference_token` are saved
5. Principal reads feedback with no way to identify the student — enforced at model level

---

## 6. Folder Structure

### Backend — Spring Boot Modular Monolith

```
sms-backend/
├── src/main/java/com/sms/
│   ├── SmsApplication.java
│   ├── config/
│   │   ├── SecurityConfig.java
│   │   ├── TenantFilter.java
│   │   ├── TenantContextHolder.java
│   │   ├── JpaConfig.java
│   │   └── RedisConfig.java
│   │
│   ├── shared/
│   │   ├── dto/           -- shared DTOs (PageResponse, ApiResponse, etc.)
│   │   ├── exception/     -- GlobalExceptionHandler, custom exceptions
│   │   ├── util/          -- DateUtils, SlugUtils, etc.
│   │   └── audit/         -- AuditEntity base class (createdAt, updatedAt, tenantId)
│   │
│   ├── modules/
│   │   ├── auth/
│   │   │   ├── AuthController.java
│   │   │   ├── AuthService.java
│   │   │   ├── JwtService.java
│   │   │   ├── RefreshTokenService.java
│   │   │   └── dto/
│   │   │
│   │   ├── users/
│   │   │   ├── UserController.java
│   │   │   ├── UserService.java
│   │   │   ├── UserRepository.java
│   │   │   ├── model/User.java
│   │   │   └── dto/
│   │   │
│   │   ├── students/
│   │   │   ├── StudentController.java
│   │   │   ├── StudentService.java
│   │   │   ├── StudentRepository.java
│   │   │   ├── model/Student.java
│   │   │   └── dto/
│   │   │
│   │   ├── staff/
│   │   │   ├── StaffController.java
│   │   │   ├── StaffService.java
│   │   │   ├── model/Staff.java
│   │   │   └── dto/
│   │   │
│   │   ├── academic/
│   │   │   ├── ClassController.java
│   │   │   ├── SubjectController.java
│   │   │   ├── TimetableController.java
│   │   │   ├── model/
│   │   │   │   ├── SchoolClass.java
│   │   │   │   ├── Subject.java
│   │   │   │   ├── AcademicYear.java
│   │   │   │   └── Term.java
│   │   │   └── dto/
│   │   │
│   │   ├── attendance/
│   │   │   ├── AttendanceController.java
│   │   │   ├── AttendanceService.java
│   │   │   ├── model/AttendanceRecord.java
│   │   │   └── dto/
│   │   │
│   │   ├── exams/
│   │   │   ├── ExamController.java
│   │   │   ├── MockExamController.java
│   │   │   ├── QuestionBankController.java
│   │   │   ├── ResultController.java
│   │   │   ├── model/
│   │   │   │   ├── Exam.java
│   │   │   │   ├── Question.java
│   │   │   │   ├── StudentResult.java
│   │   │   │   └── Broadsheet.java
│   │   │   └── dto/
│   │   │
│   │   ├── finance/
│   │   │   ├── FeeController.java
│   │   │   ├── PaymentController.java
│   │   │   ├── BudgetController.java
│   │   │   ├── model/
│   │   │   │   ├── FeeType.java
│   │   │   │   ├── FeeAssignment.java
│   │   │   │   ├── Payment.java
│   │   │   │   └── EventBudget.java
│   │   │   └── dto/
│   │   │
│   │   ├── notifications/
│   │   │   ├── NotificationService.java
│   │   │   ├── EmailService.java
│   │   │   ├── SmsService.java
│   │   │   ├── WebSocketNotificationService.java
│   │   │   ├── model/Notification.java
│   │   │   └── dto/
│   │   │
│   │   ├── gc/                          -- Group Chat
│   │   │   ├── GcController.java
│   │   │   ├── GcWebSocketController.java
│   │   │   ├── TriggerWordService.java
│   │   │   ├── model/GcMessage.java
│   │   │   └── dto/
│   │   │
│   │   ├── feedback/
│   │   │   ├── FeedbackController.java
│   │   │   ├── FeedbackService.java
│   │   │   ├── model/TeacherFeedback.java
│   │   │   └── dto/
│   │   │
│   │   ├── reports/
│   │   │   ├── ReportController.java
│   │   │   ├── JasperReportService.java
│   │   │   └── templates/              -- .jrxml template files
│   │   │
│   │   └── superadmin/
│   │       ├── TenantController.java
│   │       ├── TenantService.java
│   │       ├── FeatureLockController.java
│   │       ├── model/Tenant.java
│   │       └── dto/
│   │
├── src/main/resources/
│   ├── application.yml
│   ├── application-dev.yml
│   ├── application-prod.yml
│   └── db/migration/              -- Flyway migration scripts
│       ├── V1__create_tenants.sql
│       ├── V2__create_users.sql
│       └── ...
│
├── Dockerfile
└── pom.xml
```

---

### Frontend — Next.js (Web + Electron shared codebase)

```
sms-frontend/
├── apps/
│   ├── web/                        -- Browser app (student, parent, admissions, public)
│   │   ├── app/
│   │   │   ├── (public)/           -- Public website pages
│   │   │   ├── (auth)/             -- Login, forgot password
│   │   │   ├── student/            -- Student portal pages
│   │   │   ├── parent/             -- Parent portal pages
│   │   │   └── admissions/         -- Admissions portal pages
│   │   └── next.config.ts
│   │
│   └── desktop/                    -- Electron wrapper
│       ├── main/
│       │   ├── main.ts             -- Electron main process
│       │   ├── preload.ts
│       │   └── windowManager.ts
│       ├── renderer/               -- Points to Next.js pages below
│       └── electron-builder.config.js
│
├── packages/
│   ├── ui/                         -- Shared shadcn/ui components
│   │   ├── components/
│   │   │   ├── DataTable.tsx
│   │   │   ├── StatCard.tsx
│   │   │   ├── ResultCard.tsx
│   │   │   ├── FeeReceipt.tsx
│   │   │   └── ...
│   │   └── index.ts
│   │
│   ├── api-client/                 -- Typed API client (generated from OpenAPI or hand-written)
│   │   ├── auth.ts
│   │   ├── students.ts
│   │   ├── finance.ts
│   │   └── ...
│   │
│   └── types/                      -- Shared TypeScript types
│       ├── user.ts
│       ├── student.ts
│       ├── finance.ts
│       └── ...
│
├── portals/                        -- Portal-specific Next.js apps (run in Electron)
│   ├── admin/
│   │   └── app/
│   │       ├── dashboard/
│   │       ├── staff/
│   │       ├── students/
│   │       ├── classes/
│   │       ├── timetable/
│   │       └── settings/
│   │
│   ├── super-admin/
│   │   └── app/
│   │       ├── dashboard/
│   │       ├── schools/
│   │       ├── feature-locks/
│   │       └── billing/
│   │
│   ├── accountant/
│   │   └── app/
│   │       ├── dashboard/
│   │       ├── fees/
│   │       ├── payments/
│   │       ├── receipts/
│   │       ├── event-budget/
│   │       └── reports/
│   │
│   └── exam/
│       └── app/
│           ├── dashboard/
│           ├── internal/
│           ├── mock/
│           ├── question-bank/
│           ├── results/
│           └── broadsheet/
│
├── package.json                    -- Turborepo or pnpm workspace root
└── turbo.json
```

---

## 7. Database Schema

### Core Tables

```sql
-- Tenants
CREATE TABLE tenants (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug            VARCHAR(100) UNIQUE NOT NULL,
  name            VARCHAR(255) NOT NULL,
  logo_url        VARCHAR(500),
  primary_color   VARCHAR(7),
  accent_color    VARCHAR(7),
  banner_url      VARCHAR(500),
  tier            VARCHAR(20) NOT NULL DEFAULT 'FREE',
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE tenant_features (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES tenants(id),
  feature_key     VARCHAR(100) NOT NULL,
  is_enabled      BOOLEAN NOT NULL DEFAULT FALSE,
  UNIQUE(tenant_id, feature_key)
);

-- Users (all roles share this table)
CREATE TABLE users (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES tenants(id),
  email           VARCHAR(255) NOT NULL,
  password_hash   VARCHAR(255) NOT NULL,
  role            VARCHAR(50) NOT NULL,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  last_login      TIMESTAMP,
  created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
  UNIQUE(tenant_id, email)
);

-- Academic Years
CREATE TABLE academic_years (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES tenants(id),
  name            VARCHAR(50) NOT NULL,    -- e.g. "2024/2025"
  start_date      DATE NOT NULL,
  end_date        DATE NOT NULL,
  is_current      BOOLEAN NOT NULL DEFAULT FALSE
);

-- Terms
CREATE TABLE terms (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES tenants(id),
  academic_year_id UUID NOT NULL REFERENCES academic_years(id),
  name            VARCHAR(50) NOT NULL,    -- "First Term", "Second Term", "Third Term"
  start_date      DATE NOT NULL,
  end_date        DATE NOT NULL,
  is_current      BOOLEAN NOT NULL DEFAULT FALSE
);

-- Classes
CREATE TABLE school_classes (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES tenants(id),
  name            VARCHAR(100) NOT NULL,   -- e.g. "JSS 1A"
  level           VARCHAR(50),             -- "JSS1", "SS2", etc.
  academic_year_id UUID REFERENCES academic_years(id),
  class_teacher_id UUID REFERENCES users(id)
);

-- Subjects
CREATE TABLE subjects (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES tenants(id),
  name            VARCHAR(100) NOT NULL,
  code            VARCHAR(20)
);

-- Students
CREATE TABLE students (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES tenants(id),
  user_id         UUID REFERENCES users(id),
  admission_number VARCHAR(50) UNIQUE,
  first_name      VARCHAR(100) NOT NULL,
  last_name       VARCHAR(100) NOT NULL,
  date_of_birth   DATE,
  gender          VARCHAR(10),
  photo_url       VARCHAR(500),
  class_id        UUID REFERENCES school_classes(id),
  status          VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',   -- ACTIVE, GRADUATED, TRANSFERRED, ARCHIVED
  enrolled_at     DATE,
  created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Staff
CREATE TABLE staff (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES tenants(id),
  user_id         UUID REFERENCES users(id),
  staff_number    VARCHAR(50),
  first_name      VARCHAR(100) NOT NULL,
  last_name       VARCHAR(100) NOT NULL,
  role            VARCHAR(50) NOT NULL,
  department      VARCHAR(100),
  photo_url       VARCHAR(500),
  phone           VARCHAR(20),
  date_joined     DATE,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE
);

-- Parent-Student Links
CREATE TABLE parent_student (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES tenants(id),
  parent_user_id  UUID NOT NULL REFERENCES users(id),
  student_id      UUID NOT NULL REFERENCES students(id),
  relationship    VARCHAR(50),
  UNIQUE(parent_user_id, student_id)
);
```

### Attendance

```sql
CREATE TABLE attendance_records (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES tenants(id),
  student_id      UUID NOT NULL REFERENCES students(id),
  class_id        UUID NOT NULL REFERENCES school_classes(id),
  term_id         UUID NOT NULL REFERENCES terms(id),
  date            DATE NOT NULL,
  status          VARCHAR(20) NOT NULL,    -- PRESENT, ABSENT, LATE, EXCUSED
  recorded_by     UUID NOT NULL REFERENCES users(id),
  remarks         TEXT,
  UNIQUE(student_id, date)
);
```

### Exams & Results

```sql
CREATE TABLE exams (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES tenants(id),
  term_id         UUID NOT NULL REFERENCES terms(id),
  name            VARCHAR(200) NOT NULL,
  exam_type       VARCHAR(30) NOT NULL,    -- INTERNAL, MOCK_WAEC, MOCK_GCE, MOCK_JAMB
  start_date      DATE,
  end_date        DATE,
  status          VARCHAR(20) NOT NULL DEFAULT 'DRAFT',  -- DRAFT, PUBLISHED, COMPLETED
  created_by      UUID REFERENCES users(id)
);

CREATE TABLE exam_scores (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES tenants(id),
  exam_id         UUID NOT NULL REFERENCES exams(id),
  student_id      UUID NOT NULL REFERENCES students(id),
  subject_id      UUID NOT NULL REFERENCES subjects(id),
  ca_score        DECIMAL(5,2),
  exam_score      DECIMAL(5,2),
  total_score     DECIMAL(5,2) GENERATED ALWAYS AS (ca_score + exam_score) STORED,
  grade           VARCHAR(5),
  remarks         TEXT,
  entered_by      UUID REFERENCES users(id),
  UNIQUE(exam_id, student_id, subject_id)
);

CREATE TABLE question_bank (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES tenants(id),
  subject_id      UUID NOT NULL REFERENCES subjects(id),
  exam_type       VARCHAR(30),
  question_text   TEXT NOT NULL,
  question_type   VARCHAR(20) NOT NULL,   -- MCQ, THEORY
  options         JSONB,                  -- [{label: "A", text: "..."}, ...]
  correct_option  VARCHAR(5),
  marks           DECIMAL(4,2) NOT NULL DEFAULT 1,
  year            INTEGER
);
```

### Finance

```sql
CREATE TABLE fee_types (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES tenants(id),
  name            VARCHAR(200) NOT NULL,   -- "School Fees", "Development Levy", "PTA"
  description     TEXT,
  is_mandatory    BOOLEAN DEFAULT TRUE
);

CREATE TABLE fee_assignments (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES tenants(id),
  fee_type_id     UUID NOT NULL REFERENCES fee_types(id),
  class_id        UUID REFERENCES school_classes(id),
  term_id         UUID NOT NULL REFERENCES terms(id),
  amount          DECIMAL(12,2) NOT NULL,
  due_date        DATE
);

CREATE TABLE payments (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES tenants(id),
  student_id      UUID NOT NULL REFERENCES students(id),
  fee_type_id     UUID NOT NULL REFERENCES fee_types(id),
  term_id         UUID NOT NULL REFERENCES terms(id),
  amount_paid     DECIMAL(12,2) NOT NULL,
  payment_method  VARCHAR(50),             -- CASH, ONLINE_PAYSTACK, ONLINE_FLUTTERWAVE, BANK_TRANSFER
  payment_ref     VARCHAR(200),            -- Gateway reference
  receipt_number  VARCHAR(100) UNIQUE,
  paid_at         TIMESTAMP NOT NULL DEFAULT NOW(),
  recorded_by     UUID REFERENCES users(id),
  status          VARCHAR(20) NOT NULL DEFAULT 'CONFIRMED'  -- PENDING, CONFIRMED, REVERSED
);

CREATE TABLE event_budgets (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES tenants(id),
  name            VARCHAR(200) NOT NULL,
  event_date      DATE,
  total_budget    DECIMAL(12,2) NOT NULL,
  status          VARCHAR(20) DEFAULT 'DRAFT',
  created_by      UUID REFERENCES users(id),
  created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE event_budget_items (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  budget_id       UUID NOT NULL REFERENCES event_budgets(id),
  description     VARCHAR(200) NOT NULL,
  planned_amount  DECIMAL(12,2) NOT NULL,
  actual_amount   DECIMAL(12,2),
  category        VARCHAR(100)
);
```

### Group Chat

```sql
CREATE TABLE gc_rooms (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES tenants(id),
  class_id        UUID NOT NULL REFERENCES school_classes(id),
  name            VARCHAR(200),
  UNIQUE(class_id)
);

CREATE TABLE gc_messages (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES tenants(id),
  room_id         UUID NOT NULL REFERENCES gc_rooms(id),
  sender_id       UUID NOT NULL REFERENCES users(id),
  content         TEXT NOT NULL,
  is_flagged      BOOLEAN DEFAULT FALSE,
  flag_reason     VARCHAR(200),
  is_deleted      BOOLEAN DEFAULT FALSE,
  sent_at         TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE trigger_words (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES tenants(id),
  word            VARCHAR(100) NOT NULL,
  severity        VARCHAR(20) DEFAULT 'MEDIUM',  -- LOW, MEDIUM, HIGH
  UNIQUE(tenant_id, word)
);
```

### Feedback

```sql
-- Deliberately no student_id column — anonymity enforced at schema level
CREATE TABLE teacher_feedback (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES tenants(id),
  teacher_id      UUID NOT NULL REFERENCES users(id),
  reference_token VARCHAR(50) UNIQUE NOT NULL,
  content         TEXT NOT NULL,
  is_read         BOOLEAN DEFAULT FALSE,
  submitted_at    TIMESTAMP NOT NULL DEFAULT NOW()
);
```

### Notifications

```sql
CREATE TABLE notifications (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES tenants(id),
  user_id         UUID NOT NULL REFERENCES users(id),
  title           VARCHAR(200) NOT NULL,
  body            TEXT,
  type            VARCHAR(50),             -- FEE_REMINDER, RESULT_READY, GC_ALERT, ANNOUNCEMENT
  is_read         BOOLEAN DEFAULT FALSE,
  action_url      VARCHAR(500),
  created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);
```

---

## 8. API Design & Endpoints

All endpoints are prefixed with `/api/v1`. All endpoints except public and auth routes require a valid JWT. Tenant is resolved from JWT, not from URL (except Super Admin endpoints which use a `tenantId` path param).

### Auth

```
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh
POST   /api/v1/auth/logout
POST   /api/v1/auth/forgot-password
POST   /api/v1/auth/reset-password
GET    /api/v1/auth/me
```

### Super Admin (no tenant context required)

```
GET    /api/v1/super-admin/tenants
POST   /api/v1/super-admin/tenants
GET    /api/v1/super-admin/tenants/{id}
PATCH  /api/v1/super-admin/tenants/{id}
DELETE /api/v1/super-admin/tenants/{id}
GET    /api/v1/super-admin/tenants/{id}/features
PUT    /api/v1/super-admin/tenants/{id}/features
PATCH  /api/v1/super-admin/tenants/{id}/branding
GET    /api/v1/super-admin/audit-logs
```

### Students

```
GET    /api/v1/students                     -- paginated, filterable
POST   /api/v1/students
GET    /api/v1/students/{id}
PUT    /api/v1/students/{id}
PATCH  /api/v1/students/{id}/status         -- enrol, transfer, graduate, archive
GET    /api/v1/students/{id}/results
GET    /api/v1/students/{id}/attendance
GET    /api/v1/students/{id}/fees
POST   /api/v1/students/{id}/photo          -- upload to S3
```

### Staff

```
GET    /api/v1/staff
POST   /api/v1/staff
GET    /api/v1/staff/{id}
PUT    /api/v1/staff/{id}
PATCH  /api/v1/staff/{id}/activate
PATCH  /api/v1/staff/{id}/deactivate
```

### Academic

```
GET    /api/v1/academic/years
POST   /api/v1/academic/years
PATCH  /api/v1/academic/years/{id}/set-current

GET    /api/v1/academic/terms
POST   /api/v1/academic/terms
PATCH  /api/v1/academic/terms/{id}/set-current

GET    /api/v1/classes
POST   /api/v1/classes
GET    /api/v1/classes/{id}
PUT    /api/v1/classes/{id}
GET    /api/v1/classes/{id}/students
GET    /api/v1/classes/{id}/timetable

GET    /api/v1/subjects
POST   /api/v1/subjects
```

### Attendance

```
POST   /api/v1/attendance                   -- bulk submit for a class
GET    /api/v1/attendance/class/{classId}   -- filter by date/term
GET    /api/v1/attendance/student/{studentId}
GET    /api/v1/attendance/student/{studentId}/summary  -- % present per term
```

### Exams

```
GET    /api/v1/exams
POST   /api/v1/exams
GET    /api/v1/exams/{id}
PATCH  /api/v1/exams/{id}/publish
PATCH  /api/v1/exams/{id}/complete

POST   /api/v1/exams/{id}/scores            -- bulk score upload
GET    /api/v1/exams/{id}/scores
GET    /api/v1/exams/{id}/broadsheet        -- full class grid

GET    /api/v1/mock-exams                   -- WAEC / GCE / JAMB mocks
POST   /api/v1/mock-exams

GET    /api/v1/question-bank
POST   /api/v1/question-bank
DELETE /api/v1/question-bank/{id}

GET    /api/v1/results/check/{token}        -- public result checker (no auth)
```

### Finance

```
GET    /api/v1/finance/fee-types
POST   /api/v1/finance/fee-types
PUT    /api/v1/finance/fee-types/{id}

GET    /api/v1/finance/fee-assignments
POST   /api/v1/finance/fee-assignments

GET    /api/v1/finance/payments             -- paginated, filterable
POST   /api/v1/finance/payments             -- record cash/bank payment
GET    /api/v1/finance/payments/{id}/receipt

GET    /api/v1/finance/outstanding          -- students with unpaid/partial fees
POST   /api/v1/finance/reminders/bulk       -- send bulk fee reminders

GET    /api/v1/finance/event-budgets
POST   /api/v1/finance/event-budgets
GET    /api/v1/finance/event-budgets/{id}
PUT    /api/v1/finance/event-budgets/{id}/items

GET    /api/v1/finance/reports/term-summary
GET    /api/v1/finance/reports/collection-rate

-- Payment gateway webhooks
POST   /api/v1/payments/paystack/webhook
POST   /api/v1/payments/flutterwave/webhook
POST   /api/v1/payments/initiate            -- returns gateway checkout URL
```

### Group Chat

```
GET    /api/v1/gc/rooms                     -- rooms accessible to current user
GET    /api/v1/gc/rooms/{roomId}/messages   -- paginated message history
DELETE /api/v1/gc/messages/{messageId}      -- moderator/admin only
GET    /api/v1/gc/trigger-words
POST   /api/v1/gc/trigger-words
DELETE /api/v1/gc/trigger-words/{id}

-- WebSocket endpoint
WS     /ws/gc                               -- STOMP endpoint
  SUBSCRIBE  /topic/gc.{roomId}
  SEND       /app/gc.send
```

### Feedback

```
POST   /api/v1/feedback                     -- student submits (strips identity server-side)
GET    /api/v1/feedback                     -- principal only
PATCH  /api/v1/feedback/{id}/read
```

### Notifications

```
GET    /api/v1/notifications                -- current user's notifications
PATCH  /api/v1/notifications/{id}/read
PATCH  /api/v1/notifications/read-all

-- WebSocket
WS     /ws/notifications
  SUBSCRIBE  /user/queue/notifications
```

### Reports (JasperReports)

```
GET    /api/v1/reports/result-sheet/{studentId}/{termId}    -- returns PDF
GET    /api/v1/reports/broadsheet/{classId}/{examId}        -- returns PDF
GET    /api/v1/reports/fee-receipt/{paymentId}              -- returns PDF
GET    /api/v1/reports/attendance-summary/{classId}/{termId}
GET    /api/v1/reports/financial-summary/{termId}
```

---

## 9. Exam Engine Workflow

### Internal Exam Flow

```
Exam Officer / Teacher
  → Create exam (name, term, type=INTERNAL, date range)
  → Assign subjects and invigilators
  → Publish timetable (status=PUBLISHED)
        ↓
Students and Parents see timetable in their portals
        ↓
After exam date passes:
  → Teachers / Exam Officer enter scores (CA + exam score per subject per student)
  → OR bulk upload via CSV
        ↓
System calculates:
  → Total score = CA + exam score
  → Grade (based on tenant grading scale)
  → Position in class per subject
  → Overall average and position
        ↓
Principal / Admin reviews broadsheet
  → Approves result release
        ↓
Results become visible to Students and Parents
  → In-app notification sent
  → Downloadable PDF result sheet via JasperReports
```

### Mock Exam Flow (WAEC / GCE / JAMB)

```
Exam Officer
  → Open Mock Exam Centre → Select type (WAEC / GCE / JAMB)
  → Create mock session (select eligible classes, subjects, date)
  → Optionally link question bank questions per subject
  → Publish timetable
        ↓
Score entry (same as internal — bulk CSV or manual)
        ↓
Broadsheet generated (separate from internal term results)
        ↓
Each student receives a unique result token
  → Result Checker page (/results/check/{token}) is public
  → No login required — student/parent enters token to view mock result
        ↓
Results NOT mixed with internal term results — stored and displayed separately
```

### Grading Scale (configurable per tenant)

```sql
CREATE TABLE grading_scales (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES tenants(id),
  grade           VARCHAR(5) NOT NULL,      -- A1, B2, C4, F9, etc.
  min_score       DECIMAL(5,2) NOT NULL,
  max_score       DECIMAL(5,2) NOT NULL,
  remark          VARCHAR(50)               -- Excellent, Good, Pass, Fail
);
```

---

## 10. File Storage Structure

All files are stored on **AWS S3** with the following path conventions. Paths are namespaced by tenant to ensure complete isolation.

```
s3://sms-bucket/
├── tenants/
│   └── {tenantId}/
│       ├── branding/
│       │   ├── logo.png
│       │   └── banner.jpg
│       │
│       ├── students/
│       │   └── {studentId}/
│       │       ├── photo.jpg
│       │       └── documents/
│       │           ├── birth_certificate.pdf
│       │           └── previous_result.pdf
│       │
│       ├── staff/
│       │   └── {staffId}/
│       │       └── photo.jpg
│       │
│       ├── reports/
│       │   ├── results/
│       │   │   └── {termId}/{studentId}_result.pdf
│       │   ├── broadsheets/
│       │   │   └── {examId}_{classId}_broadsheet.pdf
│       │   └── receipts/
│       │       └── {paymentId}_receipt.pdf
│       │
│       ├── documents/
│       │   └── circulars/
│       │       └── {filename}.pdf
│       │
│       └── exam/
│           └── resources/
│               └── {examId}/
│                   └── {filename}
│
└── public/
    └── (any truly public assets — school open day photos, etc.)
```

### Access Control

- Private files (student docs, reports, photos): accessed via **pre-signed S3 URLs** (valid 15 min)
- Spring Boot generates the pre-signed URL on request after verifying the user has permission
- Public files: publicly accessible via CloudFront CDN
- Uploads go through the Spring Boot API (not directly to S3 from the client) for validation and access logging

---

## 11. Notifications & Realtime

### Notification Channels

| Channel | Used For | Provider |
|---|---|---|
| In-app (WebSocket) | GC messages, real-time alerts, result releases | Spring WebSocket + STOMP |
| In-app (persistent) | Reminders, announcements, fee alerts | Stored in `notifications` table |
| Email | Fee receipts, welcome emails, result release, password reset | JavaMailSender / SMTP |
| SMS | Fee reminders, exam timetable, urgent parent alerts | Africa's Talking / Termii |
| Push (future) | Mobile app (future phase) | Firebase Cloud Messaging |

### WebSocket Architecture

```
Client connects to WS /ws/gc or /ws/notifications
  → Authenticated via JWT in connection handshake header
  → Tenant validated
  → Subscribed to room-specific or user-specific topics

Spring Boot STOMP broker:
  /topic/gc.{roomId}         → GC room messages (all members)
  /user/queue/notifications  → Per-user notifications
  /topic/alerts.principal    → Trigger word alerts (principal only)
```

### Trigger Word Alert Flow

```
Student or Teacher sends GC message via WebSocket
  → Message saved to gc_messages table
  → TriggerWordService scans message content
  → If trigger word detected:
      → is_flagged = TRUE, flag_reason = matched word
      → NotificationService creates alert for principal user
      → WebSocket pushes alert to /topic/alerts.{tenantId}.principal
      → Alert appears instantly in Principal's Alert Centre
  → Message is still delivered to the room (not deleted)
```

### Notification Service Flow

```java
// Triggered from any module — finance, exams, admin
notificationService.send(NotificationRequest.builder()
    .tenantId(tenantId)
    .userId(recipientUserId)
    .title("Fee Payment Due")
    .body("School fees for Second Term are due on 15 Jan 2025")
    .type(NotificationType.FEE_REMINDER)
    .channels(List.of(Channel.IN_APP, Channel.SMS, Channel.EMAIL))
    .build());
```

The `NotificationService` fans out to the appropriate channel services based on the request.

---

## 12. Reporting

All reports are generated as PDFs using **JasperReports** with `.jrxml` templates.

### Reports Catalogue

| Report | Template | Triggered By |
|---|---|---|
| Student Result Sheet | `result_sheet.jrxml` | Student, Parent, Admin |
| Class Broadsheet | `broadsheet.jrxml` | Admin, Principal, Exam Officer |
| Fee Receipt | `fee_receipt.jrxml` | Auto on payment confirmation |
| Attendance Summary | `attendance_summary.jrxml` | Admin, Principal |
| Financial Term Summary | `financial_summary.jrxml` | Accountant, Admin |
| Event Budget Report | `event_budget.jrxml` | Accountant |
| Mock Exam Result | `mock_result.jrxml` | Exam Officer, Student (via token) |

### Report Generation Flow

```
API call → ReportController
  → Fetch data from relevant services
  → Pass data as JRDataSource to JasperReportService
  → JasperFillManager fills the .jrxml template
  → JasperExportManager exports to PDF bytes
  → PDF uploaded to S3 at canonical path
  → Pre-signed URL returned to client
```

### Template Branding

Each `.jrxml` template reads school name, logo URL, and primary colour from the tenant config — so the same template produces a branded report for every school automatically.

---

## 13. Payments

### Gateway Strategy

Support both **Paystack** and **Flutterwave**. Admin selects preferred gateway per tenant in settings.

### Payment Flow

```
Parent clicks "Pay Now" in Parent Portal
  → POST /api/v1/payments/initiate
        {studentId, feeTypeId, termId, amount}
  → Backend creates a pending payment record
  → Calls Paystack/Flutterwave API to create transaction
  → Returns checkout URL to frontend
  → Parent redirected to payment gateway page
        ↓
Parent completes payment on gateway
        ↓
Gateway sends webhook to:
  → POST /api/v1/payments/paystack/webhook
  → or POST /api/v1/payments/flutterwave/webhook
        ↓
Backend verifies webhook signature
  → Updates payment status to CONFIRMED
  → Generates receipt (JasperReports → S3)
  → Sends confirmation email + SMS to parent
  → Sends in-app notification to parent and accountant
        ↓
Accountant portal reflects updated payment record instantly
```

### Security

- Webhook endpoints verify HMAC signature from gateway before processing
- Idempotency key on every payment initiation to prevent duplicate charges
- All payment amounts are re-validated server-side — never trust client-sent amounts

---

## 14. Deployment & CI/CD

### Docker Compose Services

```yaml
services:
  nginx:
    image: nginx:alpine
    ports: ["80:80", "443:443"]
    volumes: ["./nginx.conf:/etc/nginx/nginx.conf", "./certs:/etc/ssl/certs"]
    depends_on: [api, web]

  api:
    build: ./sms-backend
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - DB_URL=jdbc:postgresql://postgres:5432/smsdb
      - REDIS_URL=redis://redis:6379
      - AWS_S3_BUCKET=${S3_BUCKET}
    depends_on: [postgres, redis]

  web:
    build: ./sms-frontend/apps/web
    environment:
      - NEXT_PUBLIC_API_URL=https://api.sms.com

  postgres:
    image: postgres:16
    volumes: ["postgres_data:/var/lib/postgresql/data"]
    environment:
      POSTGRES_DB: smsdb
      POSTGRES_USER: smsuser
      POSTGRES_PASSWORD: ${DB_PASSWORD}

  redis:
    image: redis:7-alpine
    volumes: ["redis_data:/data"]

volumes:
  postgres_data:
  redis_data:
```

### NGINX Config (summary)

```nginx
server {
  listen 443 ssl;
  server_name *.sms.com;

  # Route API
  location /api/ {
    proxy_pass http://api:8080;
    proxy_set_header X-Tenant-Slug $subdomain;
  }

  # WebSocket
  location /ws/ {
    proxy_pass http://api:8080;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
  }

  # Frontend
  location / {
    proxy_pass http://web:3000;
  }
}
```

### CI/CD Pipeline (GitHub Actions)

```
Push to main branch
  → Run tests (JUnit + Jest)
  → Build Docker images
  → Push to Docker Hub / GitHub Container Registry
  → SSH into VPS
  → docker compose pull
  → docker compose up -d --no-downtime
  → Run Flyway DB migrations
  → Health check
```

### Database Migrations

- Managed by **Flyway** (Spring Boot auto-runs on startup)
- Migration scripts live in `src/main/resources/db/migration/`
- Naming: `V{version}__{description}.sql` e.g. `V1__create_tenants.sql`
- Never edit a migration that has already run in production — always add a new one

### Backup Strategy

```
Daily:
  → pg_dump → compressed .sql.gz → upload to S3 (sms-backups/{date}/db.sql.gz)
  → Redis AOF persistence enabled

Weekly:
  → Full snapshot of VPS via provider
```

---

## 15. Feature Tier System

Features are stored per tenant in `tenant_features`. The backend checks feature access with a simple service method before executing gated logic.

### Feature Keys

```
FREE tier (always on):
  STUDENT_MANAGEMENT
  STAFF_MANAGEMENT
  ATTENDANCE
  BASIC_RESULTS
  FEE_RECORDING
  ANNOUNCEMENTS
  CLASS_GC_TEXT
  PARENT_PORTAL_BASIC
  EXAM_INTERNAL

STANDARD tier:
  ONLINE_PAYMENTS
  MOCK_EXAMS
  GC_TRIGGER_ALERTS
  SMS_NOTIFICATIONS
  EVENT_BUDGETING
  TIMETABLE_BUILDER
  DOCUMENT_CENTRE
  MULTI_CHILD_PARENT
  ADMISSIONS_PORTAL
  FEE_REMINDERS_BULK

PREMIUM tier:
  PAYROLL
  ANALYTICS_HUB
  CUSTOM_BRANDING
  AI_RESULT_INSIGHTS
  GC_FILE_ATTACHMENTS
  PARENT_TEACHER_CHAT
  API_ACCESS
```

### Feature Check (Backend)

```java
// In any service method that requires a paid feature:
featureService.requireFeature(tenantId, FeatureKey.ONLINE_PAYMENTS);
// Throws FeatureNotAvailableException (403) if not enabled
```

### Feature Check (Frontend)

```typescript
// Tenant config loaded on login and stored in context
const { hasFeature } = useTenant();

if (!hasFeature('MOCK_EXAMS')) {
  return <LockedFeatureBanner featureName="Mock Exam Centre" />;
}
```

---

## 16. Remaining Decisions Log

The following topics have been planned in this document. Implementation decisions to confirm during development:

| Topic | Status | Notes |
|---|---|---|
| API design / endpoints | Planned | See Section 8 |
| Multi-tenant architecture | Planned | Row-level tenancy; see Section 4 |
| Authentication & authorization | Planned | JWT + Spring Security; see Section 5 |
| Folder structure | Planned | See Section 6 |
| Database schema | Planned | Core tables defined; see Section 7 |
| Exam engine workflow | Planned | Internal + Mock flows; see Section 9 |
| File storage structure | Planned | S3 path conventions; see Section 10 |
| Deployment / CI/CD | Planned | Docker Compose + GitHub Actions; see Section 14 |
| Notifications / realtime | Planned | WebSocket STOMP + multi-channel; see Section 11 |
| Mobile app | Not planned | Future phase — React Native or PWA |
| Offline mode (Electron) | To decide | Electron portals may need limited offline capability for exam delivery |
| CBT (online exam taking) | To design | Full CBT flow (student takes exam on screen) is a separate engine to plan |
| Load balancer | Deferred | Not needed initially; revisit when traffic warrants |
| Email provider | To decide | Options: Resend, SendGrid, Mailgun, or self-hosted Postfix |
| SMS provider | To decide | Africa's Talking vs Termii (both Nigeria-friendly) |
| Rate limiting | To implement | NGINX rate limit on auth endpoints; Redis-based per-user limit on API |
| Audit logging | To implement | AuditEntity base class planned; full audit trail for finance and admin actions |

---

*Document version: 1.0 — Generated during initial planning phase.*
*Update this document as architectural decisions are confirmed or change.*
