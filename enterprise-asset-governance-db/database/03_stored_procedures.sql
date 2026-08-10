-- ==========================================
-- 03_stored_procedures.sql: Automated Logic
-- ==========================================

-- 1. Create a Stored Procedure to safely update an asset's status
CREATE OR REPLACE PROCEDURE core_assets.update_asset_status(
    p_asset_id INT,
    p_new_status VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Update the status and timestamp of the specified asset
    UPDATE core_assets.assets
    SET status = p_new_status,
        updated_at = CURRENT_TIMESTAMP
    WHERE asset_id = p_asset_id;

    -- If no rows were updated, raise a notice
    IF NOT FOUND THEN
        RAISE NOTICE 'Asset ID % not found.', p_asset_id;
    END IF;
END;
$$;

-- 2. Create a Stored Procedure to safely register a new asset
CREATE OR REPLACE PROCEDURE core_assets.register_asset(
    p_asset_name VARCHAR(255),
    p_classification VARCHAR(50),
    p_owner VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO core_assets.assets (asset_name, classification_level, owner, status, created_at, updated_at)
    VALUES (p_asset_name, p_classification, p_owner, 'Active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
END;
$$;
