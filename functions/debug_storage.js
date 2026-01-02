const admin = require('firebase-admin');

process.env.FIREBASE_STORAGE_EMULATOR_HOST = '127.0.0.1:9199';
process.env.FIRESTORE_EMULATOR_HOST = '127.0.0.1:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST = '127.0.0.1:9099';

if (!admin.apps.length) {
    admin.initializeApp({
        projectId: 'cooking-app-e5d3c',
        storageBucket: 'cooking-app-e5d3c.appspot.com'
    });
}

async function listFiles() {
    const bucket = admin.storage().bucket();
    console.log(`Checking bucket: ${bucket.name}`);

    try {
        const [files] = await bucket.getFiles();
        console.log('Files:');
        files.forEach(file => {
            console.log(file.name);
        });

        if (files.length === 0) {
            console.log("Bucket is empty.");
        }
    } catch (error) {
        console.error('Error listing files:', error);
    }
}

listFiles();
