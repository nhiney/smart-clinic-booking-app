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

/**
 * Đồng bộ Firebase Custom Claims từ document `users/{uid}`.
 *
 * Router của app phân quyền dựa trên token claims (role/status), trong khi
 * đăng ký và duyệt KYC chỉ ghi role/status vào Firestore `users`. Hàm này lắng
 * nghe mọi thay đổi của `users/{uid}` và set lại custom claims tương ứng, để
 * sau khi client refresh token thì quyền có hiệu lực.
 */
export const syncUserClaims = functions.firestore
  .document("users/{uid}")
  .onWrite(async (change, context) => {
    const uid = context.params.uid as string;

    // Document bị xóa -> gỡ toàn bộ claims.
    if (!change.after.exists) {
      try {
        await admin.auth().setCustomUserClaims(uid, null);
      } catch (e) {
        console.error(`Không gỡ được claims cho ${uid}:`, e);
      }
      return null;
    }

    const data = change.after.data() || {};
    const role = String(data.role ?? "patient").toLowerCase();
    const status = String(data.status ?? "active").toLowerCase();
    const tenantId = data.tenant_id ?? data.tenantId ?? data.hospitalId ?? null;

    // Bỏ qua nếu claims đã khớp (tránh vòng lặp ghi không cần thiết).
    const before = change.before.exists ? change.before.data() || {} : {};
    if (
      change.before.exists &&
      String(before.role ?? "").toLowerCase() === role &&
      String(before.status ?? "").toLowerCase() === status &&
      (before.tenant_id ?? before.tenantId ?? before.hospitalId ?? null) === tenantId
    ) {
      return null;
    }

    try {
      await admin.auth().setCustomUserClaims(uid, {
        role,
        status,
        tenant_id: tenantId,
      });
      // Đánh dấu thời điểm cập nhật để client biết cần refresh token.
      await db.collection("users").doc(uid).set(
        { claimsUpdatedAt: admin.firestore.FieldValue.serverTimestamp() },
        { merge: true }
      );
      console.log(`Đã set claims cho ${uid}: role=${role}, status=${status}`);
    } catch (e) {
      console.error(`Không set được claims cho ${uid}:`, e);
    }
    return null;
  });

/**
 * Callable để admin set role thủ công (vd duyệt bác sĩ).
 * Chỉ super_admin/admin được phép gọi.
 */
export const setUserRole = functions.https.onCall(async (data, context) => {
  const caller = context.auth?.token;
  const callerRole = String(caller?.role ?? "").toLowerCase();
  if (callerRole !== "super_admin" && callerRole !== "admin" && callerRole !== "hospital_manager") {
    throw new functions.https.HttpsError("permission-denied", "Chỉ quản trị viên được phép đổi vai trò.");
  }

  const uid = String(data.uid ?? "");
  const role = String(data.role ?? "patient").toLowerCase();
  const status = String(data.status ?? "active").toLowerCase();
  if (!uid) {
    throw new functions.https.HttpsError("invalid-argument", "Thiếu uid.");
  }

  await admin.auth().setCustomUserClaims(uid, { role, status, tenant_id: data.tenant_id ?? null });
  await db.collection("users").doc(uid).set(
    { role, status, claimsUpdatedAt: admin.firestore.FieldValue.serverTimestamp() },
    { merge: true }
  );
  return { ok: true, uid, role, status };
});
