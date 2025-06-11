const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendCallNotification = onRequest(
  {
    region: "us-central1",
    timeoutSeconds: 10,
    memory: "256MiB",
  },
  async (req, res) => {
    const { targetUid, channelName } = req.body;

    const userDoc = await admin.firestore().collection("users").doc(targetUid).get();
    const fcmToken = userDoc.data()?.fcmToken;

    if (!fcmToken) {
      return res.status(404).send("No FCM token found");
    }

    const message = {
      token: fcmToken,
      data: {
        type: "incoming_call",
        channelName,
      },
    };

    await admin.messaging().send(message);
    res.status(200).send({ success: true });
  }
);
