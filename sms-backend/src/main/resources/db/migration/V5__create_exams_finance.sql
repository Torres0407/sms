-- Exams
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

-- Grading Scale
CREATE TABLE grading_scales (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES tenants(id),
  grade           VARCHAR(5) NOT NULL,      -- A1, B2, C4, F9, etc.
  min_score       DECIMAL(5,2) NOT NULL,
  max_score       DECIMAL(5,2) NOT NULL,
  remark          VARCHAR(50)               -- Excellent, Good, Pass, Fail
);

-- Finance
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
