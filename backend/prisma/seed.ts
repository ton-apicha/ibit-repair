/**
 * Seed Script สำหรับสร้างข้อมูลเบื้องต้นในฐานข้อมูล
 * รันด้วยคำสั่ง: npm run seed
 */

import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 เริ่มต้น seed ข้อมูล...');

  // ========================================
  // 1. สร้างผู้ใช้งานเริ่มต้น (Admin)
  // ========================================
  console.log('👤 สร้างผู้ใช้งาน Admin...');
  
  const adminPassword = await bcrypt.hash('admin123', 10); // เข้ารหัสรหัสผ่าน
  
  const admin = await prisma.user.upsert({
    where: { username: 'admin' },
    update: {},
    create: {
      username: 'admin',
      email: 'admin@ibit-repair.com',
      passwordHash: adminPassword,
      fullName: 'ผู้ดูแลระบบ',
      role: "ADMIN",
      isActive: true,
    },
  });
  console.log(`✅ สร้าง Admin: ${admin.username}`);

  // สร้างช่างตัวอย่าง
  const techPassword = await bcrypt.hash('tech123', 10);
  const technician = await prisma.user.upsert({
    where: { username: 'technician1' },
    update: {},
    create: {
      username: 'technician1',
      email: 'tech1@ibit-repair.com',
      passwordHash: techPassword,
      fullName: 'ช่างซ่อม คนที่ 1',
      role: "TECHNICIAN",
      isActive: true,
    },
  });
  console.log(`✅ สร้าง Technician: ${technician.username}`);

  // ========================================
  // 2. สร้างยี่ห้อเครื่องขุด (Brands)
  // ========================================
  console.log('\n🏭 สร้างยี่ห้อเครื่องขุด...');
  
  const brandData = [
    { name: 'Bitmain', logoUrl: null },
    { name: 'MicroBT', logoUrl: null },
    { name: 'Canaan', logoUrl: null },
    { name: 'Innosilicon', logoUrl: null },
    { name: 'Ebang', logoUrl: null },
  ];

  const brands = await Promise.all(
    brandData.map((brand) =>
      prisma.brand.upsert({
        where: { name: brand.name },
        update: {},
        create: brand,
      })
    )
  );
  console.log(`✅ สร้าง ${brands.length} ยี่ห้อ`);

  // ========================================
  // 3. สร้างรุ่นเครื่องขุด (Models)
  // ========================================
  console.log('\n⚙️ สร้างรุ่นเครื่องขุด...');
  
  // หา ID ของแต่ละ brand
  const bitmainId = brands.find((b) => b.name === 'Bitmain')!.id;
  const microbtId = brands.find((b) => b.name === 'MicroBT')!.id;
  const canaanId = brands.find((b) => b.name === 'Canaan')!.id;
  const innosiliconId = brands.find((b) => b.name === 'Innosilicon')!.id;

  const modelData = [
    // Bitmain Models
    { brandId: bitmainId, modelName: 'Antminer S9', hashRate: 13.5, powerWatt: 1323, algorithm: 'SHA-256', releaseYear: 2017 },
    { brandId: bitmainId, modelName: 'Antminer S17', hashRate: 53, powerWatt: 2520, algorithm: 'SHA-256', releaseYear: 2019 },
    { brandId: bitmainId, modelName: 'Antminer S17+', hashRate: 73, powerWatt: 2920, algorithm: 'SHA-256', releaseYear: 2019 },
    { brandId: bitmainId, modelName: 'Antminer S17 Pro', hashRate: 56, powerWatt: 2520, algorithm: 'SHA-256', releaseYear: 2019 },
    { brandId: bitmainId, modelName: 'Antminer S19', hashRate: 95, powerWatt: 3250, algorithm: 'SHA-256', releaseYear: 2020 },
    { brandId: bitmainId, modelName: 'Antminer S19 Pro', hashRate: 110, powerWatt: 3250, algorithm: 'SHA-256', releaseYear: 2020 },
    { brandId: bitmainId, modelName: 'Antminer S19j', hashRate: 90, powerWatt: 3100, algorithm: 'SHA-256', releaseYear: 2020 },
    { brandId: bitmainId, modelName: 'Antminer S19j Pro', hashRate: 104, powerWatt: 3068, algorithm: 'SHA-256', releaseYear: 2021 },
    { brandId: bitmainId, modelName: 'Antminer S19 XP', hashRate: 140, powerWatt: 3010, algorithm: 'SHA-256', releaseYear: 2022 },
    { brandId: bitmainId, modelName: 'Antminer S19 XP Hyd', hashRate: 255, powerWatt: 5304, algorithm: 'SHA-256', releaseYear: 2022 },
    { brandId: bitmainId, modelName: 'Antminer T19', hashRate: 84, powerWatt: 3150, algorithm: 'SHA-256', releaseYear: 2020 },
    { brandId: bitmainId, modelName: 'Antminer L7', hashRate: 9500, powerWatt: 3425, algorithm: 'Scrypt', releaseYear: 2021 },
    { brandId: bitmainId, modelName: 'Antminer D7', hashRate: 1286, powerWatt: 3148, algorithm: 'X11', releaseYear: 2021 },

    // MicroBT Models
    { brandId: microbtId, modelName: 'Whatsminer M20S', hashRate: 68, powerWatt: 3360, algorithm: 'SHA-256', releaseYear: 2019 },
    { brandId: microbtId, modelName: 'Whatsminer M30S', hashRate: 86, powerWatt: 3344, algorithm: 'SHA-256', releaseYear: 2020 },
    { brandId: microbtId, modelName: 'Whatsminer M30S+', hashRate: 100, powerWatt: 3400, algorithm: 'SHA-256', releaseYear: 2020 },
    { brandId: microbtId, modelName: 'Whatsminer M30S++', hashRate: 112, powerWatt: 3472, algorithm: 'SHA-256', releaseYear: 2020 },
    { brandId: microbtId, modelName: 'Whatsminer M50', hashRate: 114, powerWatt: 3306, algorithm: 'SHA-256', releaseYear: 2021 },
    { brandId: microbtId, modelName: 'Whatsminer M50S', hashRate: 126, powerWatt: 3276, algorithm: 'SHA-256', releaseYear: 2021 },
    { brandId: microbtId, modelName: 'Whatsminer M50S+', hashRate: 130, powerWatt: 3306, algorithm: 'SHA-256', releaseYear: 2022 },
    { brandId: microbtId, modelName: 'Whatsminer M60', hashRate: 172, powerWatt: 3344, algorithm: 'SHA-256', releaseYear: 2023 },
    { brandId: microbtId, modelName: 'Whatsminer M60S', hashRate: 176, powerWatt: 3404, algorithm: 'SHA-256', releaseYear: 2023 },

    // Canaan Models
    { brandId: canaanId, modelName: 'AvalonMiner 1066', hashRate: 50, powerWatt: 3250, algorithm: 'SHA-256', releaseYear: 2019 },
    { brandId: canaanId, modelName: 'AvalonMiner 1166', hashRate: 68, powerWatt: 3196, algorithm: 'SHA-256', releaseYear: 2020 },
    { brandId: canaanId, modelName: 'AvalonMiner 1246', hashRate: 90, powerWatt: 3420, algorithm: 'SHA-256', releaseYear: 2021 },
    { brandId: canaanId, modelName: 'AvalonMiner 1266', hashRate: 100, powerWatt: 3500, algorithm: 'SHA-256', releaseYear: 2021 },
    { brandId: canaanId, modelName: 'AvalonMiner 1366', hashRate: 130, powerWatt: 3400, algorithm: 'SHA-256', releaseYear: 2022 },

    // Innosilicon Models
    { brandId: innosiliconId, modelName: 'A10 Pro', hashRate: 500, powerWatt: 1350, algorithm: 'Ethash', releaseYear: 2020 },
    { brandId: innosiliconId, modelName: 'A11 Pro', hashRate: 1500, powerWatt: 2350, algorithm: 'Ethash', releaseYear: 2021 },
  ];

  // สร้าง models ทีละตัว
  const models = [];
  for (const model of modelData) {
    const existingModel = await prisma.model.findFirst({
      where: {
        brandId: model.brandId,
        modelName: model.modelName,
      },
    });

    if (!existingModel) {
      const created = await prisma.model.create({
        data: model,
      });
      models.push(created);
    } else {
      models.push(existingModel);
    }
  }
  console.log(`✅ สร้าง ${models.length} รุ่น`);

  // ========================================
  // 4. สร้างหมวดหมู่อะไหล่ (Part Categories)
  // ========================================
  console.log('\n📦 สร้างหมวดหมู่อะไหล่...');
  
  const categoryData = [
    { name: 'Hash Board', description: 'บอร์ดขุด (แผงวงจรหลัก)' },
    { name: 'Control Board', description: 'บอร์ดควบคุม' },
    { name: 'PSU', description: 'Power Supply Unit (แหล่งจ่ายไฟ)' },
    { name: 'Fan', description: 'พัดลมระบายความร้อน' },
    { name: 'Cable', description: 'สายไฟและสายสัญญาณ' },
    { name: 'Thermal Pad', description: 'แผ่นระบายความร้อน' },
    { name: 'Heatsink', description: 'ฮีทซิงค์' },
    { name: 'Screws & Parts', description: 'น็อตและชิ้นส่วนเล็กๆ' },
    { name: 'Others', description: 'อื่นๆ' },
  ];

  const categories = await Promise.all(
    categoryData.map((category) =>
      prisma.partCategory.upsert({
        where: { name: category.name },
        update: {},
        create: category,
      })
    )
  );
  console.log(`✅ สร้าง ${categories.length} หมวดหมู่`);

  // ========================================
  // 5. สร้างโปรไฟล์การรับประกัน (Warranty Profiles)
  // ========================================
  console.log('\n🛡️ สร้างโปรไฟล์การรับประกัน...');
  
  const warrantyData = [
    { name: 'ไม่รับประกัน', durationDays: 0, coversParts: false, coversLabor: false, terms: 'ไม่มีการรับประกัน' },
    { name: 'รับประกัน 7 วัน', durationDays: 7, coversParts: true, coversLabor: true, terms: 'รับประกันชิ้นส่วนและค่าแรง 7 วัน' },
    { name: 'รับประกัน 30 วัน', durationDays: 30, coversParts: true, coversLabor: true, terms: 'รับประกันชิ้นส่วนและค่าแรง 30 วัน' },
    { name: 'รับประกัน 90 วัน', durationDays: 90, coversParts: true, coversLabor: true, terms: 'รับประกันชิ้นส่วนและค่าแรง 90 วัน' },
    { name: 'รับประกันชิ้นส่วนอย่างเดียว 30 วัน', durationDays: 30, coversParts: true, coversLabor: false, terms: 'รับประกันเฉพาะชิ้นส่วน ไม่รับประกันค่าแรง' },
  ];

  const warranties = await Promise.all(
    warrantyData.map((warranty) =>
      prisma.warrantyProfile.upsert({
        where: { name: warranty.name },
        update: {},
        create: warranty,
      })
    )
  );
  console.log(`✅ สร้าง ${warranties.length} โปรไฟล์`);

  // ========================================
  // 6. สร้างอะไหล่ตัวอย่าง
  // ========================================
  console.log('\n🔧 สร้างอะไหล่ตัวอย่าง...');
  
  const hashBoardCategory = categories.find((c) => c.name === 'Hash Board')!.id;
  const psuCategory = categories.find((c) => c.name === 'PSU')!.id;
  const fanCategory = categories.find((c) => c.name === 'Fan')!.id;

  const partData = [
    { categoryId: hashBoardCategory, partName: 'S19 Pro Hash Board', partCode: 'HB-S19PRO-01', price: 15000, stockQty: 10, minStockLevel: 3, supplier: 'Bitmain Official' },
    { categoryId: hashBoardCategory, partName: 'M30S++ Hash Board', partCode: 'HB-M30SPP-01', price: 14000, stockQty: 8, minStockLevel: 3, supplier: 'MicroBT Official' },
    { categoryId: psuCategory, partName: 'APW12 PSU 3000W', partCode: 'PSU-APW12-3000', price: 8000, stockQty: 15, minStockLevel: 5, supplier: 'Bitmain' },
    { categoryId: fanCategory, partName: 'Fan 12038 12V', partCode: 'FAN-12038-12V', price: 500, stockQty: 50, minStockLevel: 10, supplier: 'Generic' },
  ];

  const parts = await Promise.all(
    partData.map((part) =>
      prisma.part.upsert({
        where: { partCode: part.partCode },
        update: {},
        create: part,
      })
    )
  );
  console.log(`✅ สร้าง ${parts.length} อะไหล่`);

  console.log('\n✨ Seed ข้อมูลเสร็จสมบูรณ์!\n');
  console.log('📝 ข้อมูล Login:');
  console.log('   Admin: username=admin, password=admin123');
  console.log('   Technician: username=technician1, password=tech123\n');
}

// รัน main function
main()
  .catch((e) => {
    console.error('❌ เกิดข้อผิดพลาด:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

