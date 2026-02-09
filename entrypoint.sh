#!/bin/sh

echo "=== Starting EverShop Entrypoint Script (v5) ==="

# ตรวจสอบ DATABASE_URL
if [ -z "$DATABASE_URL" ]; then
  echo "Error: DATABASE_URL is not set."
  export DATABASE_URL="postgres://$PGUSER:$PGPASSWORD@$PGHOST:$PGPORT/$PGDATABASE"
fi

# ตั้งค่าให้ Node.js ยอมรับ Unauthorized SSL
export NODE_TLS_REJECT_UNAUTHORIZED=0

# ตรวจสอบความพร้อมของฐานข้อมูล
DB_HOST=$(echo $DATABASE_URL | sed -e 's|.*@||' -e 's|/.*||' -e 's|:.*||')
DB_PORT=$(echo $DATABASE_URL | sed -e 's|.*:||' -e 's|/.*||')
[ -z "$DB_PORT" ] && DB_PORT=5432

echo "Waiting for database at $DB_HOST:$DB_PORT..."
until nc -z -v -w30 $DB_HOST $DB_PORT; do
  sleep 2
done
echo "Database is up!"

# รัน Install และ Build
echo "Running evershop install & build..."
npx evershop install || echo "Install skipped."
npx evershop build

# สร้างหรืออัปเดต Admin User
# หมายเหตุ: EverShop CLI อาจไม่มีคำสั่งอัปเดตโดยตรง แต่เราจะรันสร้างซ้ำเพื่อให้แน่ใจ
echo "Ensuring admin user exists: admin@admin.com"
npx evershop user:create --email "admin@admin.com" --password "password123" --full_name "Admin" || echo "Admin user creation step finished."

echo "Starting EverShop server on port $PORT..."
exec npm run start
