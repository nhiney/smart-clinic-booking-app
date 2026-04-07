import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { v4 as uuidv4 } from 'uuid';

admin.initializeApp();
const db = admin.firestore();

/**
 * Callable Function: Safely assigns the initial role during sign up.
 */
export const assignInitialRole = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in.');
  }

  const { uid, role } = data;

  if (!uid || uid !== context.auth.uid) {
    throw new functions.https.HttpsError('permission-denied', 'Cannot modify roles for other users.');
  }

  if (role !== 'patient' && role !== 'doctor') {
    throw new functions.https.HttpsError('invalid-argument', 'Role must be patient or doctor.');
  }

  try {
    if (role === 'patient') {
      await admin.auth().setCustomUserClaims(uid, {
        role: 'patient',
        status: 'active'
      });
    } else if (role === 'doctor') {
      await admin.auth().setCustomUserClaims(uid, {
        role: 'unverified',
        status: 'pending'
      });
    }

    return { success: true };
  } catch (error) {
    console.error(`Failed to assign role for UID: ${uid}`, error);
    throw new functions.https.HttpsError('internal', 'Internal error while setting role.');
  }
});

/**
 * Callable Function: Admin securely approves a doctor's KYC application.
 */
export const approveDoctorApplication = functions.https.onCall(async (data, context) => {
  if (!context.auth || context.auth.token.role !== 'super_admin') {
    throw new functions.https.HttpsError('permission-denied', 'Requires super_admin privileges.');
  }

  const { targetUid, tenantId } = data;
  const adminUid = context.auth.uid;

  if (!targetUid || !tenantId) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required fields targetUid or tenantId.');
  }

  const applicationRef = db.collection('doctor_applications').doc(targetUid);
  const auditLogRef = db.collection('verification_audit_logs').doc();

  try {
    await db.runTransaction(async (transaction) => {
      const appDoc = await transaction.get(applicationRef);
      if (!appDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Application not found.');
      }
      
      const appData = appDoc.data();
      if (appData && appData.status === 'approved') {
        throw new functions.https.HttpsError('failed-precondition', 'Application is already approved.');
      }

      transaction.update(applicationRef, {
        status: 'approved',
        approvedBy: adminUid,
        approvedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      transaction.set(auditLogRef, {
        adminUid: adminUid,
        targetDoctorUid: targetUid,
        action: 'APPROVED_KYC',
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        tenantId: tenantId
      });
    });

    await admin.auth().setCustomUserClaims(targetUid, {
      role: 'doctor',
      status: 'active',
      tenant_id: tenantId
    });

    return { success: true, message: 'Doctor approved and claims updated.' };

  } catch (error) {
    console.error(`Approval failed for UID: ${targetUid}`, error);
    if (error instanceof functions.https.HttpsError) throw error;
    throw new functions.https.HttpsError('internal', 'Transaction failed.');
  }
});

// --- SMART MEDICAL RECORD FUNCTIONS ---

/**
 * Trigger Function: Automatically creates an immutable snapshot of medical records when updated.
 * Follows the "Versioning" requirement.
 */
export const versionMedicalRecord = functions.firestore
  .document('{collection}/{docId}')
  .onUpdate(async (change, context) => {
    const { collection, docId } = context.params;
    
    // Only target FHIR clinical collections
    const targetCollections = ['encounters', 'observations', 'medications', 'diagnostic_reports'];
    if (!targetCollections.includes(collection)) return null;

    const beforeData = change.before.data();
    const versionId = `v-${beforeData.version || 1}-${Date.now()}`;

    // Create a snapshot in the versions subcollection
    const versionRef = db.collection(collection).doc(docId).collection('versions').doc(versionId);
    
    await versionRef.set({
      ...beforeData,
      snapshotAt: admin.firestore.FieldValue.serverTimestamp(),
      snapshotBy: beforeData.updatedBy || 'system'
    });

    console.log(`Created immutable snapshot for ${collection}/${docId} version ${beforeData.version}`);
    return null;
  });

/**
 * Callable Function: Generates a temporary access grant for a medical record.
 * Used for QR code / Link sharing logic.
 */
export const generateShareToken = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated.');
  }

  const { recordId, recordType, durationMinutes = 30 } = data;
  const ownerId = context.auth.uid;

  if (!recordId || !recordType) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing recordId or recordType.');
  }

  // Verification: Ensure the caller actually owns the record (simplified check)
  const recordRef = db.collection(recordType).doc(recordId);
  const recordDoc = await recordRef.get();
  
  if (!recordDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'Record not found.');
  }

  // Validating ownership (FHIR mapping: subject.reference == 'Patient/UID')
  const recordData = recordDoc.data();
  if (recordData?.subject?.reference !== `Patient/${ownerId}`) {
     throw new functions.https.HttpsError('permission-denied', 'You do not own this record.');
  }

  const grantId = uuidv4();
  const expiresAt = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() + durationMinutes * 60000)
  );

  const grantRef = db.collection('access_grants').doc(grantId);
  await grantRef.set({
    grantId,
    ownerId,
    recordId,
    recordType,
    expiresAt,
    permissions: ['read'],
    status: 'active'
  });

  return { 
    success: true, 
    grantId, 
    expiresAt: expiresAt.toDate().toISOString(),
    shareUrl: `https://icare-app.web.app/shared/${grantId}` 
  };
});

/**
 * Trigger Function: Listen for doctor_applications document changes to send an email notification.
 */
export const onDoctorApprovedEmail = functions.firestore
  .document('doctor_applications/{docId}')
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    // Check if status transitioned to 'approved'
    if (beforeData.status !== 'approved' && afterData.status === 'approved') {
        const email = afterData.email;
        
        if (!email) {
          console.warn(`No email found for approved doctor application ${context.params.docId}`);
          return null;
        }

        await db.collection('mail').add({
          to: email,
          message: {
            subject: 'Congratulations! Your ICare Doctor Profile is Approved!',
            html: `
              <h1>Welcome to ICare!</h1>
              <p>Your application and medical credentials have been verified.</p>
              <p>You can now sign in and access your Doctor Dashboard.</p>
            `
          }
        });
        console.log(`Approval email queued for ${email}`);
    }
    return null;
});
