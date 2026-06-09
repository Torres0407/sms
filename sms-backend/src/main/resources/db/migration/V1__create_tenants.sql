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
