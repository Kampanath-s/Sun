FROM node:22

WORKDIR /app

# คัดลอกเฉพาะไฟล์ที่จำเป็นสำหรับการติดตั้ง dependencies ก่อนเพื่อใช้ประโยชน์จาก Docker cache
COPY package*.json ./
RUN npm install

# คัดลอกโค้ดทั้งหมด
COPY . .

# ตั้งค่า Environment Variables พื้นฐาน
ENV PORT=3000
ENV NODE_ENV=production

# รัน Build
RUN npm run build

# ตรวจสอบว่า Railway มีตัวแปรเหล่านี้ให้
# เราจะใช้ค่า default จาก Railway environment variables โดยตรงในแอป
# EverShop จะอ่านจาก config/default.json ซึ่งเราตั้งค่าให้อ่านจาก ENV แล้ว

EXPOSE 3000

# ใช้ shell form เพื่อให้สามารถอ่าน Environment Variables ได้ถูกต้อง
CMD npm run start
