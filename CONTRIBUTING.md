# Contributing to yuki-snowflake-dbt-tags

We love your input! We want to make contributing to this project as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## Development Process

We use GitHub to host code, to track issues and feature requests, as well as accept pull requests.

### Pull Requests

1. Fork the repo and create your branch from `main`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes.
5. Make sure your code lints.
6. Issue that pull request!

### Testing

#### Integration Tests

To run integration tests:

```bash
cd integration_tests
dbt deps
dbt test
dbt run
```

#### Manual Testing

1. Create a new dbt project
2. Add this package as a dependency
3. Configure the dispatch in your `dbt_project.yml`
4. Run models and verify query tags appear in Snowflake query history

### Code Style

- Use 2 spaces for indentation in YAML files
- Use 2 spaces for indentation in SQL files
- Follow dbt's SQL style guide
- Add comments for complex macro logic

### Reporting Bugs

Report bugs using GitHub issues. Include:

- A quick summary and/or background
- Steps to reproduce
- What you expected would happen
- What actually happens
- Notes (possibly including why you think this might be happening, or stuff you tried that didn't work)

### License

By contributing, you agree that your contributions will be licensed under the MIT License.

### References

This document was adapted from the open-source contribution guidelines for Facebook's Draft.
