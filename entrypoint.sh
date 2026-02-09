#!/bin/sh

echo "=== Starting EverShop Entrypoint Script (v4) ==="

# ตรวจสอบว่า DATABASE_URL มีค่าหรือไม่
if [ -z "$DATABASE_URL" ]; then
  echo "Error: DATABASE_URL is not set. Please check Railway environment variables."
  # สร้าง DATABASE_URL จากตัวแปรแยก (ถ้ามี)
  export DATABASE_URL="postgres://$PGUSER:$PGPASSWORD@$PGHOST:$PGPORT/$PGDATABASE"
  echo "Generated DATABASE_URL from components."
fi

# ตรวจสอบความพร้อมของฐานข้อมูล (สกัด Host และ Port จาก URL)
DB_HOST=$(echo $DATABASE_URL | sed -e 's|.*@||' -e 's|/.*||' -e 's|:.*||')
DB_PORT=$(echo $DATABASE_URL | sed -e 's|.*:||' -e 's|/.*||')
[ -z "$DB_PORT" ] && DB_PORT=5432

echo "Waiting for database at $DB_HOST:$DB_PORT..."
until nc -z -v -w30 $DB_HOST $DB_PORT; do
  echo "Database is unavailable - sleeping"
  sleep 2
done
echo "Database is up!"

# ตั้งค่าให้ Node.js ยอมรับ Unauthorized SSL (สำคัญมากสำหรับ Railway PostgreSQL)
export NODE_TLS_REJECT_UNAUTHORIZED=0

echo "Running evershop install..."
npx evershop install || echo "Install skipped or already done."

echo "Running evershop build..."
npx evershop build

echo "Ensuring admin user: admin@admin.com / password123"
npx evershop user:create -n "Admin" -e "admin@admin.com" -p "password123" || echo "User creation finished."

echo "Starting EverShop server on port $PORT..."
exec npm run start
