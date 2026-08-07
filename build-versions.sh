#!/bin/bash

# Build script for multiple PostgreSQL versions
# Usage: ./build-versions.sh [version]
# Example: ./build-versions.sh 17
#          ./build-versions.sh 18
#          ./build-versions.sh all

set -e

ORACLE_VERSION="19.25.0.0.0"

# Define PostgreSQL versions
declare -A PG_VERSIONS
PG_VERSIONS[17]="17.1.5"
PG_VERSIONS[18]="18.4"

build_version() {
    local major=$1
    local version=${PG_VERSIONS[$major]}
    
    if [ -z "$version" ]; then
        echo "Error: Unknown PostgreSQL version: $major"
        echo "Available versions: ${!PG_VERSIONS[@]}"
        exit 1
    fi
    
    echo "Building PostgreSQL $major ($version) with Oracle $ORACLE_VERSION..."
    docker build \
        --build-arg PG_MAJOR=$major \
        --build-arg PG_VERSION=$version \
        --build-arg ORACLE_VERSION=$ORACLE_VERSION \
        -t postgres-oracle-fdw:$version \
        -t postgres-oracle-fdw:$major \
        .
    
    echo "✓ Successfully built postgres-oracle-fdw:$version"
}

# Main script logic
case "${1:-all}" in
    all)
        echo "Building all PostgreSQL versions..."
        for major in "${!PG_VERSIONS[@]}"; do
            build_version "$major"
        done
        echo "✓ All versions built successfully!"
        docker images postgres-oracle-fdw
        ;;
    17|18)
        build_version "$1"
        ;;
    *)
        echo "Usage: $0 [version]"
        echo "  version: 17, 18, or all (default: all)"
        echo "Available versions:"
        for major in "${!PG_VERSIONS[@]}"; do
            echo "  - PostgreSQL $major: ${PG_VERSIONS[$major]}"
        done
        exit 1
        ;;
esac
