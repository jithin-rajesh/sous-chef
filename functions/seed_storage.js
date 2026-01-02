const admin = require('firebase-admin');
const path = require('path');

// Initialize Admin SDK - connects to emulators automatically if FIREBASE_STORAGE_EMULATOR_HOST is set
// or if we run it within the firebase shell/environment context.
process.env.FIREBASE_STORAGE_EMULATOR_HOST = '127.0.0.1:9199';
process.env.FIRESTORE_EMULATOR_HOST = '127.0.0.1:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST = '127.0.0.1:9099';

admin.initializeApp({
    projectId: 'cooking-app-e5d3c',
    storageBucket: 'cooking-app-e5d3c.appspot.com' // Default bucket name for emulator
});

async function uploadRecipes() {
    const bucket = admin.storage().bucket();
    const filePath = path.join(__dirname, 'raw_recipes.json');
    const destination = 'raw_recipes.json';

    console.log(`Uploading ${filePath} to gs://${bucket.name}/${destination}...`);

    try {
        await bucket.upload(filePath, {
            destination: destination,
            metadata: {
                contentType: 'application/json'
            }
        });
        console.log('Upload successful!');
    } catch (error) {
        console.error('Upload failed:', error);
    }
}

uploadRecipes();
