# Contributing to CloudNative PostgreSQL Extension

Thank you for your interest in contributing to this project! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Reporting Issues](#reporting-issues)

## Code of Conduct

We are committed to providing a welcoming and inclusive environment for all contributors. Please:

- Be respectful and considerate
- Welcome newcomers and help them get started
- Focus on what is best for the community
- Show empathy towards other community members

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/cloudnative-pg-extension.git
   cd cloudnative-pg-extension
   ```
3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/dingo4dev/cloudnative-pg-extension.git
   ```

## Development Setup

### Prerequisites

- Docker (20.10 or later)
- Docker Compose
- Git
- Basic knowledge of PostgreSQL and Docker

### Building Locally

Use the provided build script:

```bash
# Build all versions
./build-versions.sh all

# Build specific version
./build-versions.sh 18
```

Or use docker-compose:

```bash
docker-compose build
```

### Testing Locally

```bash
# Start the stack
docker-compose up -d

# Check logs
docker-compose logs -f

# Connect to PostgreSQL
docker-compose exec postgres psql -U postgres -d app

# Test extensions
docker-compose exec postgres psql -U postgres -d app -c "\dx"
```

## Making Changes

### Branch Naming Convention

Create a branch with a descriptive name:

- `feature/add-new-extension` - for new features
- `fix/oracle-fdw-connection` - for bug fixes
- `docs/update-readme` - for documentation
- `chore/update-dependencies` - for maintenance tasks

```bash
git checkout -b feature/your-feature-name
```

### Code Style

- **Dockerfile**: Follow Docker best practices
  - Use multi-stage builds where appropriate
  - Minimize layers
  - Clean up in the same RUN command
  - Pin versions for reproducibility

- **Shell Scripts**: Follow bash best practices
  - Use `set -e` for error handling
  - Quote variables
  - Add comments for complex logic

- **YAML**: Use 2-space indentation

- **Markdown**: Follow standard markdown formatting

### Commit Messages

Write clear, concise commit messages:

```
type: brief description

Longer description if needed, explaining what and why,
not how (the code shows how).

Closes #123
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `chore`: Maintenance tasks
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `ci`: CI/CD changes

Examples:
```
feat: add PostgreSQL 16 support

docs: update README with multi-arch build instructions

fix: correct oracle_fdw version pinning in Dockerfile
```

## Testing

### Required Tests

Before submitting a PR, ensure:

1. **Build succeeds** for all PostgreSQL versions:
   ```bash
   ./build-versions.sh all
   ```

2. **Extensions load correctly**:
   ```bash
   docker run --rm -e POSTGRES_PASSWORD=test postgres-oracle-fdw:18.4 \
     postgres -c "shared_preload_libraries='oracle_fdw,pg_cron'"
   ```

3. **Docker compose works**:
   ```bash
   docker-compose up -d
   docker-compose exec postgres psql -U postgres -c "CREATE EXTENSION oracle_fdw;"
   docker-compose down
   ```

### Automated Tests

GitHub Actions will automatically:
- Build all PostgreSQL versions
- Test extension loading
- Run security scans
- Check for multi-architecture compatibility

## Submitting Changes

1. **Update your branch** with the latest upstream:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

3. **Create a Pull Request** on GitHub:
   - Use the PR template
   - Provide a clear description
   - Link related issues
   - Mark the PR as draft if it's work in progress

4. **Address review feedback**:
   - Make requested changes
   - Push updates to your branch
   - Respond to comments

## Reporting Issues

### Bug Reports

Use the bug report template and include:
- PostgreSQL version
- Oracle version
- Container platform (Docker, Kubernetes, etc.)
- Architecture (amd64, arm64)
- Steps to reproduce
- Expected vs actual behavior
- Error messages/logs
- Configuration files (if relevant)

### Feature Requests

Use the feature request template and include:
- Clear description of the feature
- Use case and benefits
- Proposed implementation (if you have ideas)

## Documentation

When making changes that affect users:

1. **Update README.md** with new features or changes
2. **Add examples** in the `examples/` directory
3. **Update tutorials** if changing core functionality
4. **Add inline comments** for complex code

## Questions?

If you have questions:
- Open an issue with the "question" label
- Check existing issues and discussions
- Review the README and examples

## Recognition

Contributors will be recognized in:
- GitHub contributors page
- Release notes (for significant contributions)

Thank you for contributing! 🎉
