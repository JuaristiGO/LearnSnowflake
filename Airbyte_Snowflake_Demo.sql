-- SET ENVIROMENT TO CREATE IT
SET airbyte_role = 'AIRBYTE_ROLE';
SET airbyte_username = 'AIRBYTE_USER';
SET airbyte_warehouse = 'AIRBYTE_WAREHOUSE';
SET airbyte_database = 'AIRBYTE_DATABASE';
SET airbyte_schema = 'AIRBYTE_SCHEMA';


-- SET USER PASSWORD
SET airbyte_password = 'snowflake123';

BEGIN;

-- CREATE AIRBYTE ROLE
USE ROLE securityadmin;
CREATE ROLE IF NOT EXISTS identifier($airbyte_role);
GRANT ROLE identifier($airbyte_role) TO ROLE SYSADMIN;

-- CREATE AIRBYTE USER
CREATE USER IF NOT EXISTS identifier($airbyte_username)
password = $airbyte_password
default_role = $airbyte_role
default_warehouse = $airbyte_warehouse;

GRANT ROLE identifier($airbyte_role) TO USER identifier($airbyte_username);

-- CHANGE ROLE TO SYSADMIN FOR WAREHOUSE/DATABASE STEPS
USE ROLE SYSADMIN;

-- CREATE AIRBYTE WAREHOUSE
CREATE WAREHOUSE IF NOT EXISTS identifier($airbyte_warehouse)
warehouse_size = xsmall
warehouse_type = standard
auto_suspend = 60
auto_resume = true
initially_suspended = true;

-- CREATE AIRBYTE DATABASE
CREATE DATABASE IF NOT EXISTS identifier($airbyte_database);

-- CREATE AIRBYTE WAREHOUSE ACCESS
GRANT USAGE
ON WAREHOUSE identifier($airbyte_warehouse)
TO ROLE identifier($airbyte_role);

-- CREATE AIRBYTE DATABASE ACCESS
GRANT OWNERSHIP
ON DATABASE identifier($airbyte_database)
TO ROLE identifier($airbyte_role);

COMMIT;

BEGIN;

USE DATABASE identifier($airbyte_database);

-- CREATE SCHEMA FOR AIRBYTE DATA
CREATE SCHEMA IF NOT EXISTS identifier($airbyte_schema);

COMMIT;

BEGIN;

-- GRANT AIRBYTE SCHEMA ACCESS
GRANT OWNERSHIP
ON SCHEMA identifier($airbyte_schema)
TO ROLE identifier($airbyte_role);

COMMIT;