-- ==========================================
-- 02_security_rbac.sql: Roles & Row-Level Security
-- ==========================================

-- 1. Create Roles if they don't already exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'joc_analyst') THEN
        CREATE ROLE joc_analyst;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'field_operator') THEN
        CREATE ROLE field_operator;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'system_admin') THEN
        CREATE ROLE system_admin;
    END IF;
END
$$;

-- 2. Grant basic permissions to schemas
GRANT USAGE ON SCHEMA core_assets TO joc_analyst, field_operator, system_admin;
GRANT USAGE ON SCHEMA governance_audit TO system_admin;

-- 3. Assign table-level permissions based on roles
GRANT SELECT ON ALL TABLES IN SCHEMA core_assets TO joc_analyst;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA core_assets TO field_operator;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA core_assets, governance_audit TO system_admin;

-- 4. Enable Row-Level Security
ALTER TABLE core_assets.assets ENABLE ROW LEVEL SECURITY;

-- 5. Security Policies
-- Analysts can view internal assets
CREATE POLICY analyst_policy ON core_assets.assets
    FOR SELECT
    TO joc_analyst
    USING (classification_level = 'Internal');

-- Field operators can view and edit
CREATE POLICY operator_policy ON core_assets.assets
    FOR ALL
    TO field_operator
    USING (true)
    WITH CHECK (true);

-- System admins get full access
CREATE POLICY admin_policy ON core_assets.assets
    FOR ALL
    TO system_admin
    USING (true)
    WITH CHECK (true);
