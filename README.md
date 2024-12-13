# PostgreSQL Docker Image with Oracle FDW Support

This project provides a Docker image for PostgreSQL with Oracle Foreign Data Wrapper (FDW) support, enabling seamless interaction between PostgreSQL and Oracle databases.

The image is built on top of the CloudNative PostgreSQL image and includes the Oracle Instant Client and the oracle_fdw extension. This setup allows PostgreSQL to efficiently query and manipulate data stored in Oracle databases, facilitating data integration and migration scenarios.

Key features of this Docker image include:
- PostgreSQL 17 as the base database system
- Oracle Instant Client (version 19.25.0.0.0) for Oracle database connectivity
- oracle_fdw extension for creating foreign tables linked to Oracle
- Optimized for CloudNative PostgreSQL environments

## Repository Structure

- `Dockerfile`: Contains the instructions for building the Docker image
- `README.md`: This file, providing project documentation

## Usage Instructions

### Prerequisites

- Docker installed on your system
- Access to the ghcr.io container registry

### Building the Docker Image

To build the Docker image locally, run the following command in the repository root:

```bash
docker build -t postgres-oracle-fdw .
```

### Running the Container

To start a container using this image:

```bash
docker run -d --name postgres-oracle -p 5432:5432 -e POSTGRES_PASSWORD=mysecretpassword postgres-oracle-fdw
```

Replace `mysecretpassword` with a secure password of your choice.

### Connecting to the Database

You can connect to the PostgreSQL database using any PostgreSQL client. For example, using `psql`:

```bash
psql -h localhost -U postgres
```

You will be prompted for the password you set when starting the container.

### Using Oracle FDW

To use the Oracle Foreign Data Wrapper, follow these steps:

1. Create the extension in your PostgreSQL database:

```sql
CREATE EXTENSION oracle_fdw;
```

2. Create a server for your Oracle connection:

```sql
CREATE SERVER oracle_server
  FOREIGN DATA WRAPPER oracle_fdw
  OPTIONS (dbserver '//oracle-host:1521/ORCLPDB1');
```

```sql
-- or connect with TNS service
CREATE SERVER oracle_server
  FOREIGN DATA WRAPPER oracle_fdw
  OPTIONS (dbserver
  '(description=(load_balance=on)(failover=on)
  (address_list=(source_route=yes)
    (address=(protocol=tcp)(host=oracle-host)(port=1521))
    (address=(protocol=tcp)(host=oracle-host)(port=1522))
  )
  (connect_data=(service_name=ORCLPDB1)))'))
```

Replace `oracle-host` with your Oracle server's hostname or IP address, and `ORCLPDB1` with your Oracle service name.

3. Create a user mapping:

```sql
CREATE USER MAPPING FOR CURRENT_USER
  SERVER oracle_server
  OPTIONS (user 'oracle_user', password 'oracle_password');
```

Replace `oracle_user` and `oracle_password` with your Oracle database credentials.

4. Create a foreign table:

```sql
CREATE FOREIGN TABLE oracle_employees (
  employee_id integer,
  first_name text,
  last_name text
)
  SERVER oracle_server
  OPTIONS (schema 'HR', table 'EMPLOYEES');
```

This creates a foreign table `oracle_employees` that maps to the `EMPLOYEES` table in the `HR` schema of your Oracle database.

5. Query the foreign table:

```sql
SELECT * FROM oracle_employees LIMIT 5;
```

### Troubleshooting

#### ORA-12154: TNS:could not resolve the connect identifier specified

If you encounter this error, ensure that:
1. The Oracle server hostname is correct in your `CREATE SERVER` statement.
2. The Oracle service name is correct.
3. There are no network connectivity issues between the PostgreSQL container and the Oracle server.

To enable verbose logging for oracle_fdw:

```sql
ALTER SERVER oracle_server OPTIONS (ADD log_level 'debug');
```

Check the PostgreSQL logs for detailed debug information:

```bash
docker logs postgres-oracle
```

#### Performance Considerations

- Monitor the `pg_stat_foreign_tables` view for statistics on foreign table usage.
- Use `EXPLAIN ANALYZE` to understand query execution plans involving foreign tables.
- Consider creating materialized views for frequently accessed Oracle data to improve query performance.

### Update & Delete Foreign Server & Table

USE `ADD`, `SET`, `DROP` for update options

#### Update Server Options

```sql
ALTER server oracle_server
OPTIONS (SET dbserver '//oracle-host:1521/ORCLPDB1');
```

#### Update & Remove Foreign TABLE Options

```sql
alter FOREIGN TABLE oracle_employees
options ( SET table 'oracle_employees_new', DROP schema);
```




## Data Flow

When a query is executed against a foreign table in PostgreSQL:

1. PostgreSQL parses the query and identifies the parts that involve foreign tables.
2. The oracle_fdw extension translates the relevant parts of the query into Oracle SQL.
3. The translated query is sent to the Oracle database via the Oracle Instant Client.
4. Oracle executes the query and returns the results.
5. oracle_fdw receives the results and passes them back to PostgreSQL.
6. PostgreSQL integrates the foreign data with any local data processing and returns the final result to the client.

```
[PostgreSQL Client] <-> [PostgreSQL] <-> [oracle_fdw] <-> [Oracle Instant Client] <-> [Oracle Database]
```

Note: The Oracle Instant Client and oracle_fdw extension act as intermediaries, handling the communication between PostgreSQL and the Oracle database. This allows for seamless integration of Oracle data into PostgreSQL queries.

## Infrastructure

The project defines the following infrastructure in the Dockerfile:

- Base Image: `ghcr.io/cloudnative-pg/postgresql:17-bullseye`
- Oracle Instant Client: Version 19.25.0.0.0
  - Purpose: Provides connectivity to Oracle databases
- oracle_fdw Extension:
  - Purpose: Enables creation and use of foreign tables linked to Oracle databases
- Environment Variables:
  - ORACLE_HOME: Set to the Oracle Instant Client directory
  - LD_LIBRARY_PATH: Set to the Oracle Instant Client directory
- User Configuration:
  - postgres user UID changed to 26 for enhanced container security

These components work together to create a PostgreSQL environment capable of interacting with Oracle databases through foreign data wrappers.