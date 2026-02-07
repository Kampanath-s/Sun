FROM node:22

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

RUN npm run build

EXPOSE 3000

# ใช้ node_modules/.bin/evershop start แบบ daemon
CMD ["node_modules/.bin/evershop", "start"]
