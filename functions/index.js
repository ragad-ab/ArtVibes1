const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { onDocumentUpdated } = require('firebase-functions/v2/firestore');

initializeApp(); // Initialize Firebase Admin SDK
const db = getFirestore();

// Notify user when their portfolio status changes
exports.notifyUserOnPortfolioStatusChange = onDocumentUpdated(
  'portfolios/{portfolioId}',
  async (event) => {
    await handleStatusChange(event, 'portfolio');
  }
);

// Notify user when their license status changes
exports.notifyUserOnLicenseStatusChange = onDocumentUpdated(
  'licenses/{licenseId}',
  async (event) => {
    await handleStatusChange(event, 'license');
  }
);

// Common handler for status change notifications
async function handleStatusChange(event, type) {
  const newData = event.data.after.data();
  const prevData = event.data.before.data();

  // Only proceed if the status has changed from 'pending' to another state
  if (prevData.status === 'pending' && newData.status !== 'pending') {
    const userId = newData.artistId;
    const status = newData.status;
    const licenseType = newData.licenseType || ""; // Specify license type (e.g., 'event', 'artwork')
    const message = `Your ${licenseType ? licenseType + " " : ""}${type} has been ${status}. Please check the platform for more details.`;

    // Create a unique notification document ID based on the portfolio or license ID
    const notificationDocRef = db.collection('notifications').doc(event.data.after.id);

    // Check if the notification already exists
    const notificationDoc = await notificationDocRef.get();
    if (!notificationDoc.exists) {
      // Add the notification only if it doesn’t already exist
      await notificationDocRef.set({
        userId: userId,
        title: `${capitalizeFirstLetter(licenseType || type)} ${status}`,
        body: message,
        timestamp: FieldValue.serverTimestamp(),
        status: 'unread',
      });
    }
  }
}

// Helper function to capitalize the first letter of a string
function capitalizeFirstLetter(string) {
  return string.charAt(0).toUpperCase() + string.slice(1);
}
