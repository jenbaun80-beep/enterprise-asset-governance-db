-- Database Schema: Enterprise Asset Tracking
CREATE TABLE locations (
	location_id SERIAL PRIMARY KEY,
	facility_name VARCHAR(100) NOT NULL,
	region_code VARCHAR(20) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE assets (
	asset_id SERIAL PRIMARY KEY,
	serial_number VARCHAR(50) UNIQUE NOT NULL,
	asset_name VARCHAR(100) NOT NULL,
	category VARCHAR(50) NOT NULL,
	status VARCHAR(20) DEFAULT 'OPERATIONAL',
	location_id INT REFERENCES locations(location_id) ON DELETE RESTRICT,
	last_inspected TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audit_logs (
	log_id SERIAL PRIMARY KEY,
	asset_id INT REFERENCES assets(asset_id),
	action_type VARCHAR(50) NOT NULL,
	changed_by VARCHAR(50) NOT NULL,
	timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- B-Tree Performance Indexes
CREATE INDEX idx_asset_serial ON assets(serial_number);
CREATE INDEX idx_asset_status ON assets(status);
CREATE INDEX idx_audit_timestamp ON audit_logs(timestamp);
