"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.setUserRole = exports.syncUserClaims = exports.cleanupAbandonedBookings = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
admin.initializeApp();
const db = admin.firestore();
/**
 * Cloud Function chạy mỗi 5 phút để dọn dẹp các Slot bị giữ chỗ quá lâu
 * mà không hoàn tất đặt khám (TTL: 5 phút)
 */
exports.cleanupAbandonedBookings = functions.pubsub
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
exports.syncUserClaims = functions.firestore
    .document("users/{uid}")
    .onWrite(async (change, context) => {
    var _a, _b, _c, _d, _e, _f, _g, _h, _j, _k;
    const uid = context.params.uid;
    // Document bị xóa -> gỡ toàn bộ claims.
    if (!change.after.exists) {
        try {
            await admin.auth().setCustomUserClaims(uid, null);
        }
        catch (e) {
            console.error(`Không gỡ được claims cho ${uid}:`, e);
        }
        return null;
    }
    const data = change.after.data() || {};
    const role = String((_a = data.role) !== null && _a !== void 0 ? _a : "patient").toLowerCase();
    const status = String((_b = data.status) !== null && _b !== void 0 ? _b : "active").toLowerCase();
    const tenantId = (_e = (_d = (_c = data.tenant_id) !== null && _c !== void 0 ? _c : data.tenantId) !== null && _d !== void 0 ? _d : data.hospitalId) !== null && _e !== void 0 ? _e : null;
    // Bỏ qua nếu claims đã khớp (tránh vòng lặp ghi không cần thiết).
    const before = change.before.exists ? change.before.data() || {} : {};
    if (change.before.exists &&
        String((_f = before.role) !== null && _f !== void 0 ? _f : "").toLowerCase() === role &&
        String((_g = before.status) !== null && _g !== void 0 ? _g : "").toLowerCase() === status &&
        ((_k = (_j = (_h = before.tenant_id) !== null && _h !== void 0 ? _h : before.tenantId) !== null && _j !== void 0 ? _j : before.hospitalId) !== null && _k !== void 0 ? _k : null) === tenantId) {
        return null;
    }
    try {
        await admin.auth().setCustomUserClaims(uid, {
            role,
            status,
            tenant_id: tenantId,
        });
        // Đánh dấu thời điểm cập nhật để client biết cần refresh token.
        await db.collection("users").doc(uid).set({ claimsUpdatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
        console.log(`Đã set claims cho ${uid}: role=${role}, status=${status}`);
    }
    catch (e) {
        console.error(`Không set được claims cho ${uid}:`, e);
    }
    return null;
});
/**
 * Callable để admin set role thủ công (vd duyệt bác sĩ).
 * Chỉ super_admin/admin được phép gọi.
 */
exports.setUserRole = functions.https.onCall(async (data, context) => {
    var _a, _b, _c, _d, _e, _f;
    const caller = (_a = context.auth) === null || _a === void 0 ? void 0 : _a.token;
    const callerRole = String((_b = caller === null || caller === void 0 ? void 0 : caller.role) !== null && _b !== void 0 ? _b : "").toLowerCase();
    if (callerRole !== "super_admin" && callerRole !== "admin" && callerRole !== "hospital_manager") {
        throw new functions.https.HttpsError("permission-denied", "Chỉ quản trị viên được phép đổi vai trò.");
    }
    const uid = String((_c = data.uid) !== null && _c !== void 0 ? _c : "");
    const role = String((_d = data.role) !== null && _d !== void 0 ? _d : "patient").toLowerCase();
    const status = String((_e = data.status) !== null && _e !== void 0 ? _e : "active").toLowerCase();
    if (!uid) {
        throw new functions.https.HttpsError("invalid-argument", "Thiếu uid.");
    }
    await admin.auth().setCustomUserClaims(uid, { role, status, tenant_id: (_f = data.tenant_id) !== null && _f !== void 0 ? _f : null });
    await db.collection("users").doc(uid).set({ role, status, claimsUpdatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    return { ok: true, uid, role, status };
});
//# sourceMappingURL=index.js.map