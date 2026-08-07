# PostgreSQL Docker Image with Oracle FDW Support

[![Build and Push Docker Image](https://github.com/dingo4dev/cloudnative-pg-extension/actions/workflows/docker-build.yml/badge.svg)](https://github.com/dingo4dev/cloudnative-pg-extension/actions/workflows/docker-build.yml)
[![Security Scan](https://github.com/dingo4dev/cloudnative-pg-extension/actions/workflows/security-scan.yml/badge.svg)](https://github.com/dingo4dev/cloudnative-pg-extension/actions/workflows/security-scan.yml)

This project provides a Docker image for PostgreSQL with Oracle Foreign Data Wrapper (FDW) support, enabling seamless interaction between PostgreSQL and Oracle databases.

The image is built on top of the CloudNative PostgreSQL image and includes the Oracle Instant Client and the oracle_fdw extension. This setup allows PostgreSQL to efficiently query and manipulate data stored in Oracle databases, facilitating data integration and migration scenarios.

## ✨ Key Features

- 🐘 **Multiple PostgreSQL versions**: 16, 17, and 18 support
- 🔗 **Oracle Integration**: Oracle Instant Client (19.25.0.0.0) with oracle_fdw extension (pinned version)
- ⏰ **Job Scheduling**: pg_cron extension for scheduling PostgreSQL jobs
- 🔒 **Data Anonymization**: PostgreSQL Anonymizer for data masking
- 🏗️ **Multi-Architecture**: AMD64 and ARM64 support
- 🔍 **Health Checks**: Built-in health check for container orchestration
- ☁️ **Cloud Native**: Optimized for CloudNative PostgreSQL operator in Kubernetes
- 🔐 **Security**: Automated security scanning with Trivy

## Supported PostgreSQL Versions

This project supports multiple PostgreSQL versions:
- PostgreSQL 16 (version 16.6)
- PostgreSQL 17 (version 17.1.5)
- PostgreSQL 18 (version 18.4) - **Latest**

Each version is built with the same Oracle integration capabilities.

### Available Docker Images

The images are automatically built and published to both Docker Hub and GitHub Container Registry:

**Version-specific tags:**
- `dingo4dev/postgres-container:16.6` or `ghcr.io/dingo4dev/postgres-container:16.6`
- `dingo4dev/postgres-container:17.1.5` or `ghcr.io/dingo4dev/postgres-container:17.1.5`
- `dingo4dev/postgres-container:18.4` or `ghcr.io/dingo4dev/postgres-container:18.4`

**Major version tags:**
- `dingo4dev/postgres-container:16` - Latest PostgreSQL 16.x
- `dingo4dev/postgres-container:17` - Latest PostgreSQL 17.x
- `dingo4dev/postgres-container:18` - Latest PostgreSQL 18.x

**Latest tag:**
- `dingo4dev/postgres-container:latest` - Always points to the newest PostgreSQL version (18.4)

**Multi-Architecture:**
All images support both `linux/amd64` and `linux/arm64` architectures.

## Repository Structure

- `Dockerfile`: Multi-version PostgreSQL image with Oracle FDW
- `docker-compose.yml`: Docker Compose setup for local development
- `build-versions.sh`: Helper script to build multiple PostgreSQL versions
- `.github/workflows/`: CI/CD workflows (build, test, security scanning)
- `examples/kubernetes/`: Kubernetes deployment examples with CNPG operator
- `init-scripts/`: Example initialization SQL scripts
- `tutorials/`: Usage tutorials and examples
- `CONTRIBUTING.md`: Contribution guidelines

## 🚀 Quick Start

The fastest way to get started is using Docker Compose:

```bash
# Clone the repository
git clone https://github.com/dingo4dev/cloudnative-pg-extension.git
cd cloudnative-pg-extension

# Copy environment file
cp .env.example .env

# Start PostgreSQL with Oracle FDW
docker-compose up -d

# Check logs
docker-compose logs -f

# Connect to PostgreSQL
docker-compose exec postgres psql -U postgres -d app
```

The extensions (oracle_fdw, pg_cron, anon) will be automatically initialized on first startup.

## Usage Instructions

### Prerequisites

- Docker 20.10 or later
- Docker Compose (optional, for local development)
- Access to ghcr.io or Docker Hub

### Using Pre-built Images

Pull and run a pre-built image:

```bash
# Pull latest version
docker pull dingo4dev/postgres-container:latest

# Or pull specific version
docker pull dingo4dev/postgres-container:18.4

# Run container
docker run -d \
  --name postgres-oracle \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -e POSTGRES_DB=app \
  dingo4dev/postgres-container:latest
```

### Using Docker Compose

For local development, use the provided `docker-compose.yml`:

```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f postgres

# Execute SQL
docker-compose exec postgres psql -U postgres -d app -c "\dx"

# Stop services
docker-compose down
```

Customize by editing `.env` file or `docker-compose.yml`.

### Building the Docker Image

To build the Docker image locally, you can specify the PostgreSQL version using build arguments:

#### Using the Build Script (Recommended)

We provide a convenient build script that handles version management:

```bash
# Build all supported versions
./build-versions.sh all

# Build a specific version
./build-versions.sh 16  # Builds PostgreSQL 16.6
./build-versions.sh 17  # Builds PostgreSQL 17.1.5
./build-versions.sh 18  # Builds PostgreSQL 18.4
```

#### Manual Build Commands

Alternatively, you can build manually with Docker:

```bash
# Build PostgreSQL 18 (latest)
docker build \
  --build-arg PG_MAJOR=18 \
  --build-arg PG_VERSION=18.4 \
  --build-arg ORACLE_VERSION=19.25.0.0.0 \
  --build-arg ORACLE_FDW_VERSION=ORACLE_FDW_2_7_0 \
  -t postgres-oracle-fdw:18.4 .

# Build for multiple architectures
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg PG_MAJOR=18 \
  --build-arg PG_VERSION=18.4 \
  -t postgres-oracle-fdw:18.4 .
```

### Deploying to Kubernetes

For CloudNative PostgreSQL operator deployments, see the [Kubernetes examples](./examples/kubernetes/README.md).

```bash
# Apply cluster configuration
kubectl apply -f examples/kubernetes/cluster.yaml

# Check cluster status
kubectl get cluster postgres-oracle-fdw
```

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

2. Init Dynamic masking:

```sql
ALTER DATABASE app SET anon.transparent_dynamic_masking TO true;
-- SELECT anon.init()  --# This is legacy
```

3. Create anonymous role for masking role.

  ```sql
  CREATE ROLE anonymous LOGIN  -- # password 'xxxxx'
  SECURITY LABEL FOR anon ON ROLE anonymous IS 'MASKED'
  GRANT pg_read_all_data to anonymous;
  --# OR 
  --GRANT USAGE ON SCHEMA public TO anonymous;
  --GRANT SELECT ON ALL TABLES IN SCHEMA public TO anonymous;

  --# Remove Privilege
  --revoke select on all tables in schema public from anonymous;
  --revoke USAGE ON SCHEMA public FROM anonymous;
  ```

4.  Define anonymization rules for your tables. For example:

```sql
-- Anonymize the 'email' column in the 'account' table
SECURITY LABEL FOR anon ON COLUMN public.account.email IS 'MASKED WITH FUNCTION anon.partial(email,2,$$****$$,5)';
SECURITY LABEL FOR anon ON COLUMN public.account.id IS 'MASKED WITH VALUE $$******$$';
```

5. Check table whether is masked on user `anonymous`:

```sql
select * from public.account;
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

- Base Image: `ghcr.io/cloudnative-pg/postgresql:{PG_MAJOR}-bullseye`
  - Supports PostgreSQL 17 and 18 (configurable via PG_MAJOR build argument)
- Oracle Instant Client: Version 19.25.0.0.0 (configurable via ORACLE_VERSION build argument)
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

### Latest Enhancements (Current)
- ✅ **Multi-Architecture Support**: Added ARM64 and AMD64 builds for all versions
- ✅ **Health Checks**: Implemented container health checks for orchestration
- ✅ **Latest Tag**: Added `:latest` tag pointing to newest PostgreSQL version
- ✅ **PostgreSQL 16 Support**: Added PostgreSQL 16.6 to supported versions
- ✅ **Version Pinning**: Pinned oracle_fdw to stable version (ORACLE_FDW_2_7_0)
- ✅ **Docker Compose**: Added docker-compose.yml for local development
- ✅ **Automated Testing**: CI/CD now includes extension loading tests
- ✅ **Security Scanning**: Added Trivy security scanning workflow
- ✅ **Kubernetes Examples**: Added CloudNative PostgreSQL operator manifests
- ✅ **GitHub Templates**: Added PR template and issue templates
- ✅ **Contributing Guide**: Added comprehensive CONTRIBUTING.md
- ✅ **Dependabot**: Configured automated dependency updates
- ✅ **Build Improvements**: Enhanced workflow with caching and parallel builds

### Version 18.4 Support Added
- Added support for PostgreSQL 18.4
- Implemented matrix build strategy for building multiple PostgreSQL versions
- Updated CI/CD workflow to build PostgreSQL 16, 17, and 18
- Made Dockerfile version-agnostic with build arguments
- Updated documentation to reflect multi-version support

### Initial Release
- Base image: CloudNative PostgreSQL bullseye
- Included Oracle Instant Client version 19.25.0.0.0
- Added oracle_fdw extension for Oracle database connectivity
- Integrated pg_cron extension for job scheduling
- Added PostgreSQL Anonymizer for data anonymization capabilities
- Set up environment variables for Oracle Instant Client
- Changed postgres user UID to 26 for improved container security
- Optimized for CloudNative PostgreSQL environments

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

- 🐛 Report bugs via [GitHub Issues](https://github.com/dingo4dev/cloudnative-pg-extension/issues)
- 💡 Request features via [GitHub Issues](https://github.com/dingo4dev/cloudnative-pg-extension/issues)
- 🔧 Submit Pull Requests following our PR template
- 📖 Improve documentation
- ⭐ Star the repository if you find it useful!

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE.md](LICENSE.md) file for details.

Note: This changelog represents the current state of the project. Future updates will be added to this section as they occur.