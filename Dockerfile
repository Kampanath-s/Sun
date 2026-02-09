FROM node:18-alpine

WORKDIR /app

# ติดตั้งแพ็กเกจระบบที่จำเป็น (ใช้ netcat-openbsd สำหรับ alpine)
RUN apk add --no-cache netcat-openbsd

# คัดลอกเฉพาะไฟล์ที่จำเป็นสำหรับการติดตั้ง dependencies
COPY package*.json ./
RUN npm install

# คัดลอกโค้ดทั้งหมด
COPY . .

# ตั้งค่าสิทธิ์การรันให้กับ entrypoint.sh
RUN chmod +x entrypoint.sh

# ตั้งค่า Environment Variables พื้นฐาน
ENV PORT=3000
ENV NODE_ENV=production
ENV JWT_SECRET=ever-shop-stable-secret-key-2026-manus

# รัน Build ในช่วงสร้าง Image เพื่อให้ไฟล์ Static พร้อมใช้งานทันที
RUN npm run build

EXPOSE 3000

# ใช้ entrypoint.sh ในการเริ่มระบบ
ENTRYPOINT ["./entrypoint.sh"]
