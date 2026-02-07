FROM node:22

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

RUN npm run build

EXPOSE 3000

# ใช้ evershop start --debug เพื่อดูข้อมูล debug
CMD ["npm", "run", "start:debug"]
