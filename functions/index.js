const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();
const { FieldValue } = admin.firestore;
const { logger } = require('firebase-functions');

exports.userAvailableTimeChange = functions.firestore.document('users/{userId}')
  .onUpdate(async (change, context) => {
    const userId = context.params.userId;
    const beforeData = change.before.data();
    const afterData = change.after.data();
    const idempotencyRef = db.doc(`apps/group-chat/idempotencyKeys/${context.eventId}`);

    const beforeList = beforeData.hasAvailableTime || [];
    const afterList = afterData.hasAvailableTime || [];

    if (JSON.stringify(beforeList) === JSON.stringify(afterList)) {
      logger.info("No change in hasAvailableTime, skipping update.");
      return null;
    }

    const changes = [];
    var hasChange = false;
    for (let i = 0; i < beforeList.length; i++) {
      if(beforeList[i] === afterList[i]){
        changes.push(0);
      }else{
        changes.push(beforeList[i] ? -1 : 1);
      }
      
      hasChange = hasChange || beforeList[i] !== afterList[i];
    }

    if (!hasChange) {
      logger.info("No significant change in hasAvailableTime, skipping update.");
      return null;
    }

    try {
      await db.runTransaction(async (transaction) => {
        const idempotencyDoc = await transaction.get(idempotencyRef);
        if (idempotencyDoc.exists) {
          logger.info("groupChatAppPushMessage: Event already processed, skipping");
          return;
        }

        const serversSnapshot = await db.collection("servers").get();
        logger.info('length: ',serversSnapshot.docs.length)
        for (const serverDoc of serversSnapshot.docs) {
          const availableDataRef = db.collection("servers").doc(serverDoc.id).collection('availableTime').doc('0');
          logger.info('server ',serverDoc.id)
          const availableDoc = await transaction.get(availableDataRef);
          if (!availableDoc.exists) {
            logger.warn("groupChatAppPushMessage: availableTime not found");
            continue; // Skip to next server document
          }

          var newAvailableData = availableDoc.data().availableData.map(
            (value, index) => value + changes[index]
          );

          transaction.update(availableDataRef, {
            availableData: newAvailableData,
          });
        }

        transaction.set(idempotencyRef, {
          processedAt: FieldValue.serverTimestamp(),
        });
      });
      logger.debug("userAvailableTimeChange: Event processed successfully");
    } catch (error) {
      logger.error("userAvailableTimeChange: Error processing event", error);
    }
  });
