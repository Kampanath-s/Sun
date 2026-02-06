FROM node:22

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# ตั้งค่า SSL สำหรับการเชื่อมต่อฐานข้อมูล Railway PostgreSQL
RUN mkdir -p config && echo '{"database": {"ssl": "require"}}' > config/production.json

RUN npm run build

EXPOSE 3000

# สร้างสคริปต์เริ่มต้นที่จะติดตั้งฐานข้อมูลและสร้างบัญชี Admin
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
echo "=== Starting EverShop initialization ==="\n\
echo "Database Host: $PGHOST"\n\
echo "Database Port: $PGPORT"\n\
echo "Database Name: $PGDATABASE"\n\
echo "Database User: $PGUSER"\n\
echo "Database SSL: require"\n\
\n\
# ตรวจสอบว่าฐานข้อมูลได้ติดตั้งแล้วหรือไม่\n\
echo "Attempting to seed database..."\n\
if ! npm run seed 2>&1; then\n\
  echo "Seed failed, attempting setup..."\n\
  npm run setup 2>&1 || echo "Setup failed, continuing..."\n\
fi\n\
\n\
# สร้างบัญชี Admin ถ้ายังไม่มี\n\
echo "Creating admin user..."\n\
npm run user:create -- -n "Admin User" -e "admin@admin.com" -p "password123" 2>&1 || echo "Admin user creation failed or already exists"\n\
\n\
echo "=== EverShop initialization complete ==="\n\
echo "Starting EverShop server..."\n\
npm run start\n\
' > /app/start.sh && chmod +x /app/start.sh

CMD ["/app/start.sh"]
