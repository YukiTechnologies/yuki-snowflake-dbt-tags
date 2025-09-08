#!/bin/bash

# Version consistency check script
# This script checks that versions are consistent across all files

set -e

echo "🔍 Checking version consistency across files..."

# Get version from dbt_project.yml
DBT_VERSION=$(python -c "import yaml; print(yaml.safe_load(open('dbt_project.yml'))['version'])")
echo "📋 dbt_project.yml version: $DBT_VERSION"

# Check if version appears in README.md
if grep -q "$DBT_VERSION" README.md; then
    echo "✅ Version $DBT_VERSION found in README.md"
else
    echo "⚠️  Version $DBT_VERSION not found in README.md - consider updating installation instructions"
fi

# Check hub.yml if it has a version field
if [ -f "hub.yml" ]; then
    HUB_VERSION=$(python -c "
import yaml
try:
    config = yaml.safe_load(open('hub.yml'))
    if 'version' in config:
        print(config['version'])
    else:
        print('no-version-field')
except:
    print('error')
")

    if [ "$HUB_VERSION" = "no-version-field" ]; then
        echo "ℹ️  hub.yml does not have a version field (this is optional)"
    elif [ "$HUB_VERSION" = "error" ]; then
        echo "❌ Error reading hub.yml"
        exit 1
    else
        echo "📋 hub.yml version: $HUB_VERSION"
        if [ "$HUB_VERSION" != "$DBT_VERSION" ]; then
            echo "❌ Version mismatch between dbt_project.yml and hub.yml"
            exit 1
        fi
    fi
fi

echo "✅ Version consistency check passed for version $DBT_VERSION"
