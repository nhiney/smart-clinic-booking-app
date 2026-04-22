import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

/**
 * Cloud Function chạy mỗi 5 phút để dọn dẹp các Slot bị giữ chỗ quá lâu
 * mà không hoàn tất đặt khám (TTL: 5 phút)
 */
export const cleanupAbandonedBookings = functions.pubsub
  .schedule("every 5 minutes")
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const fiveMinutesAgo = new Date(now.toDate().getTime() - 5 * 60 * 1000);

    // 1. Tìm các slots có status là 'reserved' và thời gian giữ chỗ (reservedAt) đã quá 5 phút
    const abandonedSlotsQuery = db.collection("slots")
      .where("status", "==", "reserved")
      .where("reservedAt", "<", admin.firestore.Timestamp.fromDate(fiveMinutesAgo));

    const snapshot = await abandonedSlotsQuery.get();

    if (snapshot.empty) {
      console.log("Không có Slot nào bị bỏ quên.");
      return null;
    }

    const batch = db.batch();

    snapshot.docs.forEach((doc) => {
      console.log(`Đang giải phóng Slot: ${doc.id}`);
      batch.update(doc.ref, {
        status: "available",
        patientId: null,
        reservedAt: null,
      });
    });

    await batch.commit();
    console.log(`Đã giải phóng thành công ${snapshot.size} Slot.`);
    return null;
  });
