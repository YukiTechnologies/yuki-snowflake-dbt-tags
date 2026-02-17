# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A dbt macro-only package (`yuki_snowflake_dbt_tags`) that automatically tags every Snowflake query during a dbt run with JSON-formatted metadata in the `QUERY_TAG` session parameter. Published on dbt Hub.

## Commands

All integration test commands run from `integration_tests/` with `DBT_PROFILES_DIR=.`:

```bash
cd integration_tests
dbt deps          # Install package (symlinked to repo root)
dbt debug         # Verify Snowflake connection
dbt build         # Run models + tests
dbt run           # Run models only
dbt test          # Run tests only
```

Required env vars for Snowflake: `DBT_SNOWFLAKE_ACCOUNT`, `DBT_SNOWFLAKE_USER`, `DBT_SNOWFLAKE_PASSWORD`, `DBT_SNOWFLAKE_ROLE`, `DBT_SNOWFLAKE_DATABASE`, `DBT_SNOWFLAKE_WAREHOUSE`, `DBT_SNOWFLAKE_SCHEMA`. The job name resolves via fallback chain: `DBT_JOB_NAME` -> `DBT_CLOUD_JOB_ID` -> `UNNAMED_JOB`.

Pre-commit hooks: `pip install pre-commit && pre-commit install`

## Architecture

**Core macros** (`macros/set_query_tag.sql`):
- `set_query_tag(extra={})` — Saves existing session query tag, merges model config tags + session tags + `extra` dict + Yuki standard tags (job name, model, target, invocation ID, etc.), then executes `ALTER SESSION SET QUERY_TAG`. Returns the original tag for restoration.
- `unset_query_tag(original_query_tag)` — Restores the pre-run session query tag after materialization.

Both use `adapter.dispatch()` so users can override them per-adapter. Users integrate by adding this package to their `dbt_project.yml` dispatch search order, which intercepts dbt's built-in `set_query_tag`/`unset_query_tag` hooks.

**PseudoWarehouse handling**: The macro strips a `PseudoWarehouse` JSON prefix (from Yuki's warehouse-management product) from the existing session tag via regex, preserving data after a `;;` separator.

**Custom extension pattern**: Users override `set_query_tag` in their project and call `yuki_snowflake_dbt_tags.set_query_tag(extra={...})` to inject custom fields while keeping standard Yuki tags.

## Version Management

Version must stay in sync across three files: `dbt_project.yml`, `README.md` (install snippet), and `CHANGELOG.md`. The `scripts/check-version.sh` pre-commit hook enforces consistency, semver format, and that CHANGELOG has a dated entry.

## Integration Tests

Located in `integration_tests/` as a separate dbt project. `integration_tests/dbt_packages/yuki_snowflake_dbt_tags` is a symlink to the repo root, so macro changes are immediately reflected. Three test models verify basic tagging, incremental/full_refresh tagging, and macro compilation.
