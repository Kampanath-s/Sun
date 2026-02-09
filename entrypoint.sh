#!/bin/sh

echo "=== Starting EverShop Entrypoint Script (v6 - Final Force) ==="

# บังคับค่า JWT_SECRET ในระดับ OS เพื่อให้แอปเห็นแน่นอน
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
until nc -z -v -w30 $DB_HOST $DB_PORT; do sleep 2; done

# ติดตั้งและ Build
echo "Running evershop install & build..."
npx evershop install || echo "Install skipped."
npx evershop build

# บังคับสร้าง Admin User ด้วยวิธีที่มั่นใจที่สุด
echo "Ensuring admin user: admin@admin.com"
# เราจะพยายามสร้างใหม่ทับของเดิมถ้าทำได้ หรือแจ้งเตือนถ้ามีอยู่แล้ว
npx evershop user:create --email "admin@admin.com" --password "password123" --full_name "Admin" || echo "Admin check finished."

echo "Starting EverShop server on port $PORT..."
# ใช้ exec เพื่อให้แอปเป็น Process หลักและรับค่า Environment ได้ครบถ้วน
exec npm run start
