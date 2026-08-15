-- ============================================================
-- Migration 001: PostgreSQL extensions
-- Project: RespiraCare
-- Date: 2026-08-10
-- Idempotent: re-running is safe.
-- ============================================================

-- gen_random_uuid() support (pgcrypto is the canonical source; in PG13+ it
-- is part of core, but we enable pgcrypto for compatibility and for any
-- crypto helpers that may be useful later).
create extension if not exists "pgcrypto";

-- uuid-ossp provides uuid_generate_v4() — kept available even though we
-- rely on gen_random_uuid() (pgcrypto) as the default for all PK columns.
create extension if not exists "uuid-ossp";

-- moddatetime provides the moddatetime trigger function used by
-- Migration 017 to auto-maintain updated_at columns.
create extension if not exists "moddatetime";

-- PostGIS is NOT enabled: the app has no geospatial requirements today.
-- full-text search (pg_trgm, unaccent) is NOT enabled: deferred until needed.

-- Done.
