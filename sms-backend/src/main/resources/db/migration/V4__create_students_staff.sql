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

-- Attendance (related to students)
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
