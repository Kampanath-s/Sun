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

EXPOSE 3000

# ใช้ exec form เพื่อให้ Process ได้รับ SIGTERM อย่างถูกต้อง
ENTRYPOINT ["npm", "run", "start"]
