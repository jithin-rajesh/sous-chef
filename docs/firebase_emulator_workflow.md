# Firebase Emulator Workflow Guide

This guide explains how to set up and run the Firebase Local Emulator Suite for the Sous Chef app simulation.

## Prerequisites
1.  **Node.js & npm**: Ensure you have Node.js installed (`node -v`).
2.  **Firebase CLI**: Install globally via npm:
    ```bash
    npm install -g firebase-tools
    ```
3.  **Java**: Required for Firestore/Realtime Database emulators.

## Setup
1.  **Login to Firebase**:
    ```bash
    firebase login
    ```
2.  **Initialize Project** (if not already done):
    ```bash
    firebase init
    ```
    - Select **Emulators**.
    - Choose **Functions** (Press Space to select, Enter to confirm).
    - Optional: **Authentication** or **Firestore** if you plan to use them later.
    - Use default ports (Auth: 9099, Firestore: 8080, Functions: 5001).

## Running Emulators
To start the emulators, run:
```bash
firebase emulators:start
```
This will start the local server. You will see a UI dashboard link (usually `http://localhost:4000`).

## Connecting Flutter App
The app is configured to connect to emulators if a specific flag is set or in debug mode (depending on configuration).

To explicitly connect in code (already handled in some setups, but here is the snippet):
```dart
if (kDebugMode) {
  try {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  } catch (e) {
    print(e);
  }
}
```

## Parsing with Emulators
If you are using Cloud Functions for the Gemini parsing (`parseRecipeWithGemini`), ensuring the functions emulator is running is critical.
However, our current `RecipeParserService` calls the Gemini API directly from the client (Flutter) for simplicity in this demo. If we move to a backend function later, the emulator will be needed.

## Android/iOS Specifics
For Android Emulator, `localhost` needs to be mapped to `10.0.2.2`.
flutterfire configures this automatically often, but if connection fails, change `localhost` to `10.0.2.2` in the `useEmulator` calls.
