#!/bin/sh

echo "Starting EverShop Entrypoint Script..."

# แสดงค่าตัวแปรสภาพแวดล้อมที่สำคัญ (ซ่อนรหัสผ่าน)
echo "Database Host: $PGHOST"
echo "Database Port: $PGPORT"
echo "Database Name: $PGDATABASE"
echo "Database User: $PGUSER"

# ตรวจสอบว่าฐานข้อมูลพร้อมใช้งานหรือไม่
echo "Waiting for database to be ready..."
until nc -z -v -w30 $PGHOST $PGPORT; do
  echo "Database is unavailable - sleeping"
  sleep 1
done
echo "Database is up - executing command"

# ตรวจสอบว่าต้องติดตั้งระบบหรือไม่
# EverShop จะแจ้งเตือนถ้าติดตั้งไปแล้ว เราจะลองรัน install ก่อนเสมอ
# แต่จะใช้ || true เพื่อให้สคริปต์ทำงานต่อได้แม้คำสั่งล้มเหลว
echo "Running evershop install..."
npx evershop install || echo "EverShop might already be installed, proceeding..."

# สร้าง User ถ้ายังไม่มี (หรือจะรันทุกครั้งก็ได้ EverShop จะจัดการเอง)
echo "Ensuring admin user exists..."
npx evershop user:create -n "Admin User" -e "admin@admin.com" -p "password123" || echo "Admin user might already exist."

# เริ่มแอปพลิเคชัน
echo "Starting EverShop server on port $PORT..."
exec npm run start
