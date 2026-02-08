FROM node:22

# ติดตั้ง netcat สำหรับการตรวจสอบสถานะฐานข้อมูล
RUN apt-get update && apt-get install -y netcat-traditional && rm -rf /var/lib/apt/lists/*

WORKDIR /app

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

# รัน Build
RUN npm run build

EXPOSE 3000

# ใช้ entrypoint.sh ในการเริ่มระบบ
ENTRYPOINT ["./entrypoint.sh"]
