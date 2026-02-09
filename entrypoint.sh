#!/bin/sh

echo "=== EverShop HARD RESET Entrypoint (v7) ==="

export JWT_SECRET="ever-shop-stable-secret-key-2026-manus"
export NODE_TLS_REJECT_UNAUTHORIZED=0

if [ -z "$DATABASE_URL" ]; then
  export DATABASE_URL="postgres://$PGUSER:$PGPASSWORD@$PGHOST:$PGPORT/$PGDATABASE"
fi

# รอฐานข้อมูล
DB_HOST=$(echo $DATABASE_URL | sed -e 's|.*@||' -e 's|/.*||' -e 's|:.*||')
DB_PORT=$(echo $DATABASE_URL | sed -e 's|.*:||' -e 's|/.*||')
[ -z "$DB_PORT" ] && DB_PORT=5432
until nc -z -v -w30 $DB_HOST $DB_PORT; do sleep 2; done

# ขั้นตอนสำคัญ: ล้างฐานข้อมูลทิ้งทั้งหมด
echo "PERFORMING DATABASE HARD RESET..."
node reset_db.js || echo "Reset failed or already clean."

# รัน Install ใหม่บนฐานข้อมูลที่ว่างเปล่า
echo "Running fresh evershop install..."
npx evershop install

# รัน Build
echo "Running evershop build..."
npx evershop build

# สร้าง Admin User ใหม่เอี่ยม
echo "Creating fresh admin user: admin@admin.com"
npx evershop user:create --email "admin@admin.com" --password "password123" --full_name "Admin"

echo "Starting EverShop server..."
exec npm run start
