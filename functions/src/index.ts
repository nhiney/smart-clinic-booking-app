import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

/**
 * Callable Function: Safely assigns the initial role during sign up.
 * This prevents clients from setting arbitrary custom claims themselves.
 */
export const assignInitialRole = functions.https.onCall(async (data, context) => {
  // Ensure the caller is authenticated
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
 * Executes a transaction to write audit logs and update custom claims.
 */
export const approveDoctorApplication = functions.https.onCall(async (data, context) => {
  // 1. Security Check: Ensure caller is authenticated and holds the super_admin claim
  if (!context.auth || context.auth.token.role !== 'super_admin') {
    throw new functions.https.HttpsError('permission-denied', 'Requires super_admin privileges.');
  }

  const { targetUid, tenantId } = data;
  const adminUid = context.auth.uid;

  if (!targetUid || !tenantId) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required fields targetUid or tenantId.');
  }

  const applicationRef = db.collection('doctor_applications').doc(targetUid);
  const auditLogRef = db.collection('verification_audit_logs').doc(); // Auto-generated ID

  try {
    // 2. Transaction Phase
    await db.runTransaction(async (transaction) => {
      const appDoc = await transaction.get(applicationRef);
      if (!appDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Application not found.');
      }
      
      const appData = appDoc.data();
      if (appData && appData.status === 'approved') {
        throw new functions.https.HttpsError('failed-precondition', 'Application is already approved.');
      }

      // Update Application Document safely
      transaction.update(applicationRef, {
        status: 'approved',
        approvedBy: adminUid,
        approvedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      // Write Immutable Audit Log
      transaction.set(auditLogRef, {
        adminUid: adminUid,
        targetDoctorUid: targetUid,
        action: 'APPROVED_KYC',
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        tenantId: tenantId
      });
    });

    // 3. Setup Custom Claims Post-Transaction
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

/**
 * Trigger Function: Listen for doctor_applications document changes to send an email notification.
 * Assumption: firestore-send-email extension is installed and listening to the `mail` collection.
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

        // Add a document to the mail collection which the Trigger Email extension watches
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
