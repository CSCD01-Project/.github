#!/usr/bin/env bash
set -euo pipefail

echo "=== Cloudflare D1 + Superset Development Setup ==="

# Ensure required tools exist
for cmd in git poetry; do
  if ! command -v $cmd &>/dev/null; then
    echo "❌ ERROR: $cmd is not installed or not in PATH."
    exit 1
  fi
done

echo "✅ Verified required tools exist"

echo "=== Step 1: Cloning repositories into $(pwd) ==="
for repo in \
  "git@github.com:CSCD01-Project/dbapi-d1.git" \
  "git@github.com:CSCD01-Project/sqlalchemy-d1.git" \
  "git@github.com:CSCD01-Project/superset-engine-d1.git"
do
  name=$(basename "$repo" .git)
  if [ -d "$name" ]; then
    echo "⚠️  $name already exists — skipping clone"
  else
    echo "⏳ Cloning $name..."
    git clone "$repo"
    echo "✅ Cloned $name"
  fi
done

echo "=== Step 2: Installing dependencies with Poetry ==="

cd dbapi-d1
echo "⏳ Installing dependencies for dbapi-d1..."
poetry install
echo "✅ Done"
cd ..

cd sqlalchemy-d1
echo "⏳ Installing dependencies for sqlalchemy-d1..."
poetry install
echo "⏳ Building sqlalchemy-d1..."
poetry build
echo "✅ Done"
cd ..

cd superset-engine-d1
echo "⏳ Installing dependencies for superset-engine-d1..."
poetry install
echo "✅ Done"

echo "=== Step 3: Creating config files in superset-engine-d1 ==="

if [ ! -f ".env" ]; then
  echo "FLASK_APP=superset.app:create_app()" > .env
  echo "✅ Created .env"
else
  echo "⚠️  .env exists — skipping"
fi

if [ ! -f "superset_config.py" ]; then
  cat <<EOF > superset_config.py
SECRET_KEY = "$(openssl rand -hex 16)"
SQLALCHEMY_DATABASE_URI = "sqlite:////tmp/superset.db"
EOF
  echo "✅ Created superset_config.py"
else
  echo "⚠️  superset_config.py exists — skipping"
fi

echo "=== Step 4: Running Superset Setup (in superset-engine-d1) ==="
export SUPERSET_CONFIG_PATH="$(pwd)/superset_config.py"

echo "⏳ Running DB migrations..."
poetry run superset db upgrade

echo "⏳ Creating admin user (if not exists)..."
poetry run superset fab create-admin \
  --username admin \
  --firstname Superset \
  --lastname Admin \
  --email admin@example.com \
  --password admin || echo "⚠️ Admin likely exists — continuing"

echo "⏳ Initializing superset..."
poetry run superset init

echo ""
echo "✅ Setup complete!"
echo ""
echo "To start Superset (run these commands):"
echo "  cd superset-engine-d1"
echo "  export SUPERSET_CONFIG_PATH=\"\$(pwd)/superset_config.py\""
echo "  poetry run superset run -p 8088 --with-threads --reload --debugger"
echo ""
echo "Login credentials:"
echo "  Username: admin"
echo "  Password: admin"
