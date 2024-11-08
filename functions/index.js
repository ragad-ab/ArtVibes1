const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { onDocumentUpdated } = require('firebase-functions/v2/firestore');

initializeApp(); // Initialize Firebase Admin SDK
const db = getFirestore();

exports.notifyUserOnPortfolioStatusChange = onDocumentUpdated(
  'portfolios/{portfolioId}',
  async (event) => {
    const newData = event.data.after.data();
    const prevData = event.data.before.data();

    // Only proceed if the status has changed from 'pending' to another state
    if (prevData.status === 'pending' && newData.status !== 'pending') {
      const userId = newData.artistId;
      const status = newData.status;
      const message = `Your portfolio has been ${status}. Please check the platform for more details.`;

      // Create a unique notification document ID based on the portfolio ID
      const notificationDocRef = db.collection('notifications').doc(event.data.after.id);

      // Check if the notification already exists
      const notificationDoc = await notificationDocRef.get();
      if (!notificationDoc.exists) {
        // Add the notification only if it doesn’t already exist
        await notificationDocRef.set({
          userId: userId,
          title: `Portfolio ${status}`,
          body: message,
          timestamp: FieldValue.serverTimestamp(),
          status: 'unread',
        });
      }
    }
  }
);
