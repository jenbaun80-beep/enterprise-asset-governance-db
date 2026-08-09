CREATE OR REPLACE FUNCTION log_asset_status_change()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.status <> OLD.status THEN
		INSERT INTO audit_logs(asset_id, action_type, changed_by)
		VALUES (NEW.asset_id, CONCAT('STATUS_CHANGE: ', OLD.status, ' -> ', NEW.status), CURRENT_USER);
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_asset_status_audit
AFTER UPDATE ON assets
FOR EACH ROW
EXECUTE FUNCTION log_asset_status_change();
