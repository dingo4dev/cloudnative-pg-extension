# PostgreSQL Docker Image with Oracle FDW Support

This project provides a Docker image for PostgreSQL with Oracle Foreign Data Wrapper (FDW) support, enabling seamless interaction between PostgreSQL and Oracle databases.

The image is built on top of the CloudNative PostgreSQL image and includes the Oracle Instant Client and the oracle_fdw extension. This setup allows PostgreSQL to efficiently query and manipulate data stored in Oracle databases, facilitating data integration and migration scenarios.

Key features of this Docker image include:
- PostgreSQL 17-bullseye as the base database system
- Oracle Instant Client (version 19.25.0.0.0) for Oracle database connectivity
- oracle_fdw extension for creating foreign tables linked to Oracle
- pg_cron extension for scheduling PostgreSQL jobs
- PostgreSQL Anonymizer for data anonymization
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
  (connect_data=(service_name=ORCLPDB1)))');
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

### Using PG CRON

To use the pg_cron extension in cnpg operator in k8s enviroment:

1. Install the postgres database first
2. Add `pg_cron` in `shared_preload_libraries`:
    ``` yaml
      postgresql:
        shared_preload_libraries:
        - pg_cron
    ```
3. Add database `app` (default `postgres`) to dedicated `cron.data_basename`. As cnpg will create `app` database for app use.
4. Login to `postgres` and create extesion
  ``` sql
  CREATE EXTENSION pg_cron;
  -- Grant usage to app user for using cron -- 
  GRANT USAGE ON SCHEMA cron TO app;
  -- Grant permissions on cron schema tables
  GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA cron TO app;
  ```

### PostgreSQL Anonymizer

This Docker image includes PostgreSQL Anonymizer, an extension that provides data anonymization capabilities for your PostgreSQL database.

To use PostgreSQL Anonymizer:

1. Enable the extension in your database:

```sql
CREATE EXTENSION IF NOT EXISTS anon;
```

2. Create an anonymization schema:

```sql
SELECT anon.init();
```

3. Define anonymization rules for your tables. For example:

```sql
-- Anonymize the 'email' column in the 'users' table
UPDATE anon.mask_columns
SET 
    function_parameters = '{"email": "email"}'
WHERE 
    attname = 'email' AND relname = 'users';
```

4. Apply the anonymization:

```sql
SELECT anon.anonymize_database();
```

This will anonymize the data according to the rules you've defined.

For more advanced usage and detailed configuration options, please refer to the [official PostgreSQL Anonymizer documentation](https://postgresql-anonymizer.readthedocs.io/).

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
- pg_cron Extension:
  - Purpose: Allows scheduling of PostgreSQL jobs
- PostgreSQL Anonymizer:
  - Purpose: Provides data anonymization capabilities
- Environment Variables:
  - ORACLE_HOME: Set to the Oracle Instant Client directory
  - LD_LIBRARY_PATH: Set to the Oracle Instant Client directory
- User Configuration:
  - postgres user UID changed to 26 for enhanced container security

These components work together to create a PostgreSQL environment capable of interacting with Oracle databases through foreign data wrappers, scheduling PostgreSQL jobs, and anonymizing sensitive data.

## Contributing

We welcome contributions to improve this PostgreSQL Docker image with Oracle FDW support. Here's how you can contribute:

1. **Reporting Issues**: If you find a bug or have a suggestion for improvement, please open an issue on our GitHub repository. Provide as much detail as possible, including steps to reproduce the issue if applicable.

2. **Submitting Pull Requests**: If you'd like to contribute code:
   - Fork the repository
   - Create a new branch for your feature or bug fix
   - Make your changes, following our code style guidelines
   - Write or update tests as necessary
   - Submit a pull request with a clear description of your changes

3. **Code Style**: Please follow the existing code style in the project. For SQL, use uppercase for keywords and lowercase for identifiers.

4. **Commit Messages**: Write clear, concise commit messages describing the changes you've made.

5. **Documentation**: Update the README.md file if your changes require updates to the usage instructions or add new features.

6. **Testing**: Ensure that your changes don't break existing functionality. Add new tests for new features.

By contributing, you agree that your contributions will be licensed under the same license as the project.

Thank you for helping improve this project!

## Recent Changes

This section documents the recent changes and updates to the project:

- Initial release of the PostgreSQL Docker image with Oracle FDW support
- Base image: CloudNative PostgreSQL 17-bullseye
- Included Oracle Instant Client version 19.25.0.0.0
- Added oracle_fdw extension for Oracle database connectivity
- Integrated pg_cron extension for job scheduling
- Added PostgreSQL Anonymizer for data anonymization capabilities
- Set up environment variables for Oracle Instant Client
- Changed postgres user UID to 26 for improved container security
- Optimized for CloudNative PostgreSQL environments

Note: This changelog represents the current state of the project. Future updates will be added to this section as they occur.