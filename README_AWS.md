# ขั้นตอนการตั้งค่า EverShop บน AWS

เพื่อให้ระบบ GitHub Actions สามารถ Deploy เว็บไซต์ของคุณไปยัง AWS ได้โดยอัตโนมัติ โปรดดำเนินการตามขั้นตอนดังนี้:

### 1. ตั้งค่า GitHub Secrets
ไปที่ Repository `Kampanath-s/Sun` -> **Settings** -> **Secrets and variables** -> **Actions** และเพิ่ม Secret ดังนี้:
- `AWS_ACCESS_KEY_ID`: Access Key จาก IAM User
- `AWS_SECRET_ACCESS_KEY`: Secret Key จาก IAM User
- `AWS_REGION`: ภูมิภาคที่ต้องการใช้งาน (เช่น `ap-southeast-1` สำหรับสิงคโปร์)

### 2. สร้างฐานข้อมูล Amazon RDS (PostgreSQL)
- ไปที่ AWS Console -> **RDS** -> **Create database**
- เลือก **PostgreSQL** (เวอร์ชัน 14 หรือสูงกว่า)
- เลือก **Free Tier** (หากต้องการประหยัดค่าใช้จ่าย)
- ตั้งค่า **DB instance identifier**: `evershop-db`
- ตั้งค่า **Master username**: `postgres`
- ตั้งค่า **Master password**: (จดจำรหัสผ่านนี้ไว้)
- ในส่วน **Connectivity**: เลือก **Public access: Yes** (เพื่อให้ App Runner เชื่อมต่อได้ง่ายในเบื้องต้น)

### 3. ตั้งค่า Environment Variables ใน App Runner
เมื่อสร้าง Service ใน App Runner ให้เพิ่ม Environment Variables ดังนี้:
- `DB_HOST`: Endpoint ของ RDS ที่สร้างเสร็จแล้ว
- `DB_PORT`: `5432`
- `DB_NAME`: `postgres` (หรือชื่อฐานข้อมูลที่สร้าง)
- `DB_USER`: `postgres`
- `DB_PASSWORD`: (รหัสผ่านที่คุณตั้งไว้)

### 4. การ Deploy
หลังจากตั้งค่า Secrets ใน GitHub แล้ว ทุกครั้งที่คุณ **Push** หรือ **Merge** โค้ดไปยังกิ่ง `main` ระบบจะทำการ Build และ Deploy ไปยัง AWS ให้โดยอัตโนมัติครับ
