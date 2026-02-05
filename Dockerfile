FROM node:22

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# ปิด SSL สำหรับการเชื่อมต่อฐานข้อมูลภายใน Cloud Run (ถ้าจำเป็น)
RUN mkdir -p config && echo '{"database": {"ssl": false}}' > config/production.json

RUN npm run build

EXPOSE 3000

# สร้างสคริปต์เริ่มต้นที่จะติดตั้งฐานข้อมูลและสร้างบัญชี Admin
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
echo "Starting EverShop initialization..."\n\
echo "Database Host: $PGHOST"\n\
echo "Database Port: $PGPORT"\n\
echo "Database Name: $PGDATABASE"\n\
echo "Database User: $PGUSER"\n\
\n\
# ตรวจสอบว่าฐานข้อมูลได้ติดตั้งแล้วหรือไม่\n\
if ! npm run seed 2>/dev/null; then\n\
  echo "Setting up database..."\n\
  npm run setup || true\n\
fi\n\
\n\
# สร้างบัญชี Admin ถ้ายังไม่มี\n\
echo "Creating admin user..."\n\
npm run user:create -- -n "Admin User" -e "admin@admin.com" -p "password123" 2>&1 || echo "Admin user already exists or error occurred"\n\
\n\
echo "Starting EverShop server..."\n\
npm run start\n\
' > /app/start.sh && chmod +x /app/start.sh

CMD ["/app/start.sh"]
