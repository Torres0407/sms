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
