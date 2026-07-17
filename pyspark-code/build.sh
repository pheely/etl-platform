#!/bin/bash
set -e

# Configuration
GCS_BUCKET="gs://py-service-01-etl-code"

echo "=== Cleaning up local dist/ folder ==="
rm -rf my_env my_env.tar.gz dist/
mkdir -p dist

# Copy entrypoint script regardless
cp src/main.py dist/

# Check if requirements_runtime.txt has active, non-empty dependencies
# (Ignoring empty lines and comment lines starting with #)
DEPENDENCY_COUNT=$(grep -v '^#' requirements_runtime.txt | grep -v '^$' | wc -l || true)

if [ "$DEPENDENCY_COUNT" -gt 0 ]; then
    echo "=== Dependencies detected ($DEPENDENCY_COUNT found). Packaging environment... ==="
    
    # Ensure local machine uses Python 3.11 to match Dataproc 2.2 runtimes 
    python3.11 -m venv my_env
    source my_env/bin/activate

    pip install --upgrade pip
    pip install -r requirements_runtime.txt [cite: 65]

    # Package using venv-pack [cite: 41]
    venv-pack -o dist/my_env.tar.gz --force [cite: 41]
    deactivate
    rm -rf my_env

    echo "=== Uploading code and dependencies to GCS ==="
    gcloud storage cp dist/my_env.tar.gz "${GCS_BUCKET}/dependencies/my_env.tar.gz" 
else
    echo "=== requirements_runtime.txt is empty. Skipping virtual env packaging. ==="
    # Remove any stale remote archives so Airflow doesn't pick up old dependency builds
    gcloud storage rm "${GCS_BUCKET}/dependencies/my_env.tar.gz" --quiet || true
fi

echo "=== Uploading entrypoint script ==="
gcloud storage cp dist/main.py "${GCS_BUCKET}/scripts/main.py" 

echo "=== Build and synchronization stage complete! ==="