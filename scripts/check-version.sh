#!/bin/bash

# Release Version Pre-commit Check
# This script validates version consistency across project files and changelog

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_error() {
    echo -e "${RED}ERROR: $1${NC}"
}

print_success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

print_info() {
    echo -e "$1"
}

# Extract version from root dbt_project.yml only (exclude integration_tests)
get_project_version() {
    if [[ -f "dbt_project.yml" ]]; then
        # Only look at the root dbt_project.yml, not integration_tests/dbt_project.yml
        grep "^version:" ./dbt_project.yml | sed "s/version: *['\"]\\([^'\"]*\\)['\"].*/\\1/"
    else
        # For dbt packages, we rely on GitHub releases - return empty for now
        echo ""
    fi
}

# Check if version is valid semantic version (supporting ZeroVer - 0-based versioning)
is_valid_semver() {
    local version=$1
    # Support both traditional semver (1.0.0+) and ZeroVer (0.x.y)
    if [[ $version =~ ^0\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)*)?(\+[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)*)?$ ]] || \
       [[ $version =~ ^[1-9][0-9]*\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)*)?(\+[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)*)?$ ]]; then
        return 0
    else
        return 1
    fi
}

# Check if changelog has entry for the version
check_changelog_entry() {
    local version=$1
    if grep -q "^## \\[$version\\]" CHANGELOG.md; then
        return 0
    else
        return 1
    fi
}

# Check if changelog entry has a date
check_changelog_date() {
    local version=$1
    local pattern="^## \\[$version\\] - [0-9]{4}-[0-9]{2}-[0-9]{2}"
    if grep -E "$pattern" CHANGELOG.md > /dev/null; then
        return 0
    else
        return 1
    fi
}

# Extract version from README.md (in the installation section)
get_readme_version() {
    if [[ -f "README.md" ]]; then
        # Look for revision field in packages.yml installation examples
        grep "revision:" README.md | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1
    fi
}

# Check version consistency across all files
check_version_consistency() {
    local dbt_version=$1
    local inconsistencies=0

    print_info "Checking version consistency across files..."

    # Check README.md version
    if [[ -f "README.md" ]]; then
        local readme_version=$(get_readme_version)
        if [[ -n "$readme_version" ]]; then
            if [[ "$readme_version" == "$dbt_version" ]]; then
                print_success "README.md version matches: $readme_version"
            else
                print_error "README.md version mismatch: found '$readme_version', expected '$dbt_version'"
                inconsistencies=$((inconsistencies + 1))
            fi
        else
            print_warning "Could not find version in README.md installation section"
        fi
    fi

    # Search for any other mentions of the version in the codebase (excluding historical changelog entries)
    print_info "Searching for other version references..."
    # Refactored version search for clarity and maintainability
    find_other_version_references() {
        local current_version=$1
        local exclude_dirs=(.git target dbt_packages .history logs integration_tests)
        local exclude_files=("*.backup" "CHANGELOG.md" "*.log")

        # Build find command exclude arguments
        local find_exclude_args=()
        for dir in "${exclude_dirs[@]}"; do
            find_exclude_args+=(-path "./$dir" -prune -o)
        done

        # Find all files except excluded directories and files
        local files_to_search=$(find . "${find_exclude_args[@]}" -type f -name "*.yml" -o -name "*.yaml" -o -name "*.md" -o -name "*.py" -o -name "*.sql" 2>/dev/null | grep -vE "($(IFS='|'; echo "${exclude_files[*]//\*/.*}"))")

        # Search for version patterns in found files
        local version_pattern="[0-9]\+\.[0-9]\+\.[0-9]\+"
        local all_versions=""

        if [[ -n "$files_to_search" ]]; then
            all_versions=$(echo "$files_to_search" | xargs grep -l "$version_pattern" 2>/dev/null | xargs grep -h "$version_pattern" 2>/dev/null || true)
        fi

        # Filter out current version and irrelevant references
        local filtered_versions=$(echo "$all_versions" | grep -v "$current_version" | grep -E "0\.[0-9]+\.[0-9]+" | grep -v "require-dbt-version" | head -3)

        echo "$filtered_versions"
    }

    local other_versions=$(find_other_version_references "$dbt_version")

    if [[ -n "$other_versions" ]]; then
        print_warning "Found other version references that might need updating:"
        echo "$other_versions" | while read -r line; do
            print_warning "  → $line"
        done
        print_info "  Please verify these are intentional or update them to match $dbt_version"
    else
        print_success "No potentially inconsistent version references found"
    fi

    # Check if all files that should contain the version actually do
    local files_to_check=("README.md" "CHANGELOG.md")
    if [[ -f "dbt_project.yml" ]]; then
        files_to_check+=("dbt_project.yml")
    fi

    for file in "${files_to_check[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_warning "$file not found"
        fi
    done

    return $inconsistencies
}

# Main validation function
main() {
    print_info "Starting release version validation..."

    # Check if we're in a dbt package or dbt project directory
    if [[ ! -f "dbt_project.yml" && ! -f "README.md" ]]; then
        print_error "Neither dbt_project.yml nor README.md found. Are you in the project root?"
        exit 1
    fi

    # Determine project type
    if [[ -f "dbt_project.yml" ]]; then
        PROJECT_TYPE="dbt project"
        VERSION_FILE="dbt_project.yml"
    else
        PROJECT_TYPE="dbt package"
        VERSION_FILE="GitHub releases"
    fi

    print_info "Detected: $PROJECT_TYPE (using $VERSION_FILE)"

    # Get version from the appropriate file
    PROJECT_VERSION=$(get_project_version)

    if [[ -z "$PROJECT_VERSION" ]]; then
        print_warning "Could not extract version from $VERSION_FILE"
        print_info "For dbt packages, version is managed via GitHub releases"
        print_info "Please ensure you have tagged releases in your repository"
        # For now, we'll skip version validation for packages
        print_success "Package structure validation passed!"
        print_info "Ready for dbt Hub submission"
        exit 0
    fi

    print_info "📋 Found version in $VERSION_FILE: $PROJECT_VERSION"

    # Validate semantic versioning (including ZeroVer support)
    if ! is_valid_semver "$PROJECT_VERSION"; then
        print_error "Version '$PROJECT_VERSION' is not a valid semantic version (major.minor.patch or ZeroVer 0.x.y)"
        exit 1
    fi
    print_success "Version follows semantic versioning format (ZeroVer/SemVer compatible)"

    # Check version consistency across files
    if ! check_version_consistency "$PROJECT_VERSION"; then
        print_error "Version consistency check failed"
        exit 1
    fi

    # Check if CHANGELOG.md exists
    if [[ ! -f "CHANGELOG.md" ]]; then
        print_warning "CHANGELOG.md not found"
    else
        # Check if changelog has entry for this version
        if check_changelog_entry "$PROJECT_VERSION"; then
            print_success "Found changelog entry for version $PROJECT_VERSION"

            # Check if the changelog entry has a date
            if check_changelog_date "$PROJECT_VERSION"; then
                print_success "Changelog entry has a valid date"
            else
                print_warning "Changelog entry for $PROJECT_VERSION doesn't have a date or has invalid date format (YYYY-MM-DD)"
            fi
        else
            print_error "No changelog entry found for version $PROJECT_VERSION"
            print_info "Please add an entry to CHANGELOG.md with format: ## [$PROJECT_VERSION] - YYYY-MM-DD"
            exit 1
        fi
    fi

    # Check if dbt_project.yml exists and validate require-dbt-version
    if [[ -f "dbt_project.yml" ]]; then
        print_info "Validating dbt_project.yml..."
        if grep -q "require-dbt-version:" dbt_project.yml; then
            print_success "dbt_project.yml contains require-dbt-version field"
        else
            print_warning "dbt_project.yml missing require-dbt-version field"
        fi
    fi

    # Check if version is not a development version (ending with -dev, -alpha, -beta, etc.)
    if [[ "$PROJECT_VERSION" =~ -dev|-alpha|-beta|-rc ]]; then
        print_warning "Version '$PROJECT_VERSION' appears to be a development/pre-release version"
        print_info "Consider using a stable version for releases"
    fi

    # ZeroVer-specific messaging
    if [[ "$PROJECT_VERSION" =~ ^0\. ]]; then
        print_info "📝 Using ZeroVer (0-based versioning) - version $PROJECT_VERSION"
    fi

    # Additional checks for Git environment
    if git rev-parse --git-dir > /dev/null 2>&1; then
        # Check if we're on main/master branch for releases
        CURRENT_BRANCH=$(git branch --show-current)
        if [[ "$CURRENT_BRANCH" != "main" && "$CURRENT_BRANCH" != "master" ]]; then
            print_info "📝 Current branch: $CURRENT_BRANCH (not main/master)"
        fi

        # Check for uncommitted changes
        if [[ -n $(git status --porcelain) ]]; then
            print_warning "There are uncommitted changes in the repository"
        fi
    fi

    print_success "All version checks passed!"
    print_info "Ready for release: v$PROJECT_VERSION"
}

# Run the main function
main "$@"