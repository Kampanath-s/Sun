#!/bin/sh

echo "=== Starting EverShop Entrypoint Script ==="

# แสดงค่าตัวแปรสภาพแวดล้อมที่สำคัญ (ซ่อนรหัสผ่าน)
echo "Database Host: $PGHOST"
echo "Database Port: $PGPORT"
echo "Database Name: $PGDATABASE"
echo "Database User: $PGUSER"

# ตรวจสอบว่าฐานข้อมูลพร้อมใช้งานหรือไม่
echo "Waiting for database to be ready at $PGHOST:$PGPORT..."
until nc -z -v -w30 $PGHOST $PGPORT; do
  echo "Database is unavailable - sleeping"
  sleep 2
done
echo "Database is up!"

# ในรอบนี้เราจะบังคับให้รัน install เพื่อให้แน่ใจว่า schema ถูกต้อง
echo "Running evershop install..."
npx evershop install || echo "Install might have skipped some steps, continuing..."

# รัน Build เพื่อความชัวร์
echo "Running evershop build..."
npx evershop build

# พยายามสร้าง Admin User
# เราจะใช้คำสั่ง user:create และไม่สนใจถ้ามันมีอยู่แล้ว
echo "Creating admin user: admin@admin.com / password123"
npx evershop user:create -n "Admin" -e "admin@admin.com" -p "password123" || echo "User creation finished (might already exist)."

# เริ่มแอปพลิเคชัน
echo "Starting EverShop server on port $PORT..."
exec npm run start
