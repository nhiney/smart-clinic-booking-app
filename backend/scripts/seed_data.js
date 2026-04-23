/**
 * ICare Database Seeding Script
 * 
 * Usage:
 * 1. Download service-account-file.json from Firebase Console.
 * 2. Place it in the root of the project.
 * 3. Run: npm install firebase-admin
 * 4. Run: node scripts/seed_data.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('../service-account-file.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const auth = admin.auth();
const db = admin.firestore();

async function seedData() {
  try {
    console.log('--- Starting ICare Data Seeding ---');

    // 1. Create Default Admin
    const adminEmail = 'admin@icare.com';
    const adminPassword = 'AdminPassword123!';
    let adminUser;
    
    try {
      adminUser = await auth.getUserByEmail(adminEmail);
      console.log('Admin Auth already exists.');
    } catch (e) {
      adminUser = await auth.createUser({
        email: adminEmail,
        password: adminPassword,
        displayName: 'ICare System Admin'
      });
      console.log('Admin Auth created.');
    }

    await db.collection('users').doc(adminUser.uid).set({
      uid: adminUser.uid,
      email: adminEmail,
      fullName: 'Hệ thống Admin',
      role: 'ADMIN',
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
    console.log('Admin User profile created/updated.');

    // 2. Create Sample Hospital
    const hospitalRef = db.collection('hospitals').doc('hosp_chp_01');
    await hospitalRef.set({
      name: 'Bệnh viện Chợ Rẫy',
      address: '201B Nguyễn Chí Thanh, Phường 12, Quận 5, TP.HCM',
      status: 'active',
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
    console.log('Sample Hospital created.');

    // 3. Create Sample Department
    const deptRef = db.collection('departments').doc('dept_cardio_01');
    await deptRef.set({
      hospitalId: 'hosp_chp_01',
      name: 'Khoa Tim mạch',
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
    console.log('Sample Department created.');

    // 4. Create Sample Doctor
    const doctorEmail = 'dr.nguyenvanan@icare.com';
    const doctorPassword = 'DoctorPassword123!';
    let doctorUser;

    try {
      doctorUser = await auth.getUserByEmail(doctorEmail);
      console.log('Doctor Auth already exists.');
    } catch (e) {
      doctorUser = await auth.createUser({
        email: doctorEmail,
        password: doctorPassword,
        displayName: 'BS. Nguyễn Văn An'
      });
      console.log('Doctor Auth created.');
    }

    await db.collection('users').doc(doctorUser.uid).set({
      uid: doctorUser.uid,
      email: doctorEmail,
      fullName: 'Nguyễn Văn An',
      role: 'DOCTOR',
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    await db.collection('doctors').doc(doctorUser.uid).set({
      doctorId: doctorUser.uid,
      departmentId: 'dept_cardio_01',
      hospitalId: 'hosp_chp_01',
      specialty: 'Tim mạch',
      experienceYears: 15,
      resumePdfUrl: '', // To be uploaded via app
      rating: 4.8,
      status: 'active'
    });
    console.log('Sample Doctor profile created/updated.');

    // 5. Create Sample Rooms
    await db.collection('rooms').doc('room_101').set({
      departmentId: 'dept_cardio_01',
      roomNumber: '101',
      type: 'Phòng khám'
    });
    console.log('Sample Room created.');

    console.log('--- Seeding Completed Successfully ---');
    console.log('Admin: admin@icare.com / AdminPassword123!');
    console.log('Doctor: dr.nguyenvanan@icare.com / DoctorPassword123!');

  } catch (error) {
    console.error('Error seeding data:', error);
  } finally {
    process.exit();
  }
}

seedData();
