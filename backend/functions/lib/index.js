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
exports.cleanupAbandonedBookings = void 0;
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
//# sourceMappingURL=index.js.map