-- Group Chat
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

-- Feedback
CREATE TABLE teacher_feedback (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       UUID NOT NULL REFERENCES tenants(id),
  teacher_id      UUID NOT NULL REFERENCES users(id),
  reference_token VARCHAR(50) UNIQUE NOT NULL,
  content         TEXT NOT NULL,
  is_read         BOOLEAN DEFAULT FALSE,
  submitted_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Notifications
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
