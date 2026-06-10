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
