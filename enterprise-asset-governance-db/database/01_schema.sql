-- ==========================================
-- 01_schema.sql: Core Tables & Audit Logging
-- ==========================================

-- 1. Create Schemas
CREATE SCHEMA IF NOT EXISTS core_assets;
CREATE SCHEMA IF NOT EXISTS governance_audit;

-- 2. Create Core Assets Table (3NF Optimized)
CREATE TABLE IF NOT EXISTS core_assets.assets (
    asset_id SERIAL PRIMARY KEY,
    asset_name VARCHAR(255) NOT NULL,
    classification_level VARCHAR(50) NOT NULL DEFAULT 'Internal',
    owner VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Create Immutable Audit Log Table
CREATE TABLE IF NOT EXISTS governance_audit.audit_logs (
    log_id SERIAL PRIMARY KEY,
    table_name TEXT NOT NULL,
    operation TEXT NOT NULL,
    db_user TEXT NOT NULL,
    action_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    old_data JSONB,
    new_data JSONB
);

-- 4. Create Automated Audit Trigger Function
CREATE OR REPLACE FUNCTION governance_audit.log_asset_changes() 
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO governance_audit.audit_logs (table_name, operation, db_user, old_data, new_data)
        VALUES (TG_TABLE_NAME, TG_OP, current_user, to_jsonb(OLD), NULL);
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO governance_audit.audit_logs (table_name, operation, db_user, old_data, new_data)
        VALUES (TG_TABLE_NAME, TG_OP, current_user, to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO governance_audit.audit_logs (table_name, operation, db_user, old_data, new_data)
        VALUES (TG_TABLE_NAME, TG_OP, current_user, NULL, to_jsonb(NEW));
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 5. Attach Trigger to Assets Table
DROP TRIGGER IF EXISTS trg_audit_assets ON core_assets.assets;
CREATE TRIGGER trg_audit_assets
    AFTER INSERT OR UPDATE OR DELETE ON core_assets.assets
    FOR EACH ROW EXECUTE FUNCTION governance_audit.log_asset_changes();
