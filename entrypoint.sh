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

# ตรวจสอบว่าต้องติดตั้งระบบหรือไม่
echo "Running evershop install..."
npx evershop install || echo "EverShop might already be installed, proceeding..."

# รัน Build อีกครั้งใน Runtime เพื่อให้แน่ใจว่า path ถูกต้อง
echo "Running evershop build..."
npx evershop build

# สร้าง User ถ้ายังไม่มี
echo "Ensuring admin user exists..."
npx evershop user:create -n "Admin User" -e "admin@admin.com" -p "password123" || echo "Admin user might already exist."

# เริ่มแอปพลิเคชัน
echo "Starting EverShop server on port $PORT..."
exec npm run start
