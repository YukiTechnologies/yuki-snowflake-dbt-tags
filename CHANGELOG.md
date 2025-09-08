# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.3] - 2025-09-08

### Added
- Comprehensive GitHub Actions for automated testing
- Pre-commit hooks for code quality
- SQLFluff configuration for SQL linting
- Integration tests with proper structure
- Macro documentation using schema.yml
- Contributing guidelines
- Manual testing documentation and examples
- Version consistency checking script

### Changed
- Updated documentation with testing instructions
- Improved macro error handling
- Enhanced README with compatibility information

### Fixed
- dbt parse errors by removing deprecated `{% docs %}` blocks
- Test file syntax issues
- Package structure for dbt Hub compliance

### Technical
- Added `.github/workflows/` for CI/CD
- Added `.pre-commit-config.yaml` for code quality
- Added `.sqlfluff` for SQL formatting
- Added `macros/schema.yml` for proper documentation
- Added `scripts/check-version.sh` for release validation

## [0.2.2] - Previous Release
### Added
- Basic query tagging functionality
- Environment variable support
- Target name tracking

## [0.2.1] - Previous Release
### Added
- Initial package structure
- Core macros for query tagging

## [0.2.0] - Previous Release
### Added
- First public release
- Basic query tagging for Snowflake
