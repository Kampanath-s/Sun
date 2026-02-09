#!/bin/sh

echo "=== EverShop Final Check Entrypoint ==="

# บังคับค่า JWT_SECRET ในระดับ OS
export JWT_SECRET="ever-shop-stable-secret-key-2026-manus"
export NODE_TLS_REJECT_UNAUTHORIZED=0

# ตรวจสอบ DATABASE_URL
if [ -z "$DATABASE_URL" ]; then
  export DATABASE_URL="postgres://$PGUSER:$PGPASSWORD@$PGHOST:$PGPORT/$PGDATABASE"
fi

# รอฐานข้อมูล
DB_HOST=$(echo $DATABASE_URL | sed -e 's|.*@||' -e 's|/.*||' -e 's|:.*||')
DB_PORT=$(echo $DATABASE_URL | sed -e 's|.*:||' -e 's|/.*||')
[ -z "$DB_PORT" ] && DB_PORT=5432

echo "Waiting for database at $DB_HOST:$DB_PORT..."
until nc -z -v -w30 $DB_HOST $DB_PORT; do 
  echo "Database not ready, retrying..."
  sleep 2
done
echo "Database is up!"

# รัน Install (รวดเร็ว)
echo "Ensuring EverShop is installed..."
npx evershop install || echo "Install skipped."

# สร้าง/ตรวจสอบ Admin User
echo "Ensuring admin user exists..."
npx evershop user:create --email "admin@admin.com" --password "password123" --full_name "Admin" || echo "Admin check done."

echo "Starting EverShop server on port $PORT..."
exec npm run start
