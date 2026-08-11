-- Example initialization script for PostgreSQL with Oracle FDW
-- This script runs automatically when the container starts for the first time

-- Create extensions
CREATE EXTENSION IF NOT EXISTS oracle_fdw;
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS anon;

-- Initialize pg_cron with app database
-- Note: pg_cron is already configured in postgresql.conf to use 'app' database

-- Example: Create Oracle server (update with your Oracle connection details)
-- Uncomment and modify the following lines:

-- CREATE SERVER oracle_server
--   FOREIGN DATA WRAPPER oracle_fdw
--   OPTIONS (dbserver '//oracle-xe:1521/XE');

-- CREATE USER MAPPING FOR postgres
--   SERVER oracle_server
--   OPTIONS (user 'system', password 'OraclePassword123');

-- Example: Create a foreign table
-- CREATE FOREIGN TABLE oracle_example (
--   id integer,
--   name text
-- )
--   SERVER oracle_server
--   OPTIONS (schema 'SYSTEM', table 'EXAMPLE_TABLE');

-- Initialize anonymizer
ALTER DATABASE app SET anon.transparent_dynamic_masking TO true;

-- Example: Create an anonymous role
CREATE ROLE anonymous LOGIN PASSWORD 'anonymous_pass';
SECURITY LABEL FOR anon ON ROLE anonymous IS 'MASKED';
GRANT pg_read_all_data TO anonymous;

-- Log completion
DO $$
BEGIN
    RAISE NOTICE 'Extensions initialized: oracle_fdw, pg_cron, anon';
END $$;
