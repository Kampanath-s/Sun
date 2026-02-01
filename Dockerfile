FROM node:22

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# ปิด SSL สำหรับการเชื่อมต่อฐานข้อมูลภายใน Cloud Run (ถ้าจำเป็น)
RUN mkdir -p config && echo '{"database": {"ssl": false}}' > config/production.json

RUN npm run build

EXPOSE 3000

CMD ["npm", "run", "start"]
