CREATE ROLE joc_analyst;
CREATE ROLE field_operator;
CREATE ROLE system_admin;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO joc_analyst;
GRANT SELECT, INSERT, UPDATE ON assets, audit_logs TO field_operator;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO system_admin;
