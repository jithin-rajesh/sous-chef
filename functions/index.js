const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { GoogleGenerativeAI } = require("@google/generative-ai");


admin.initializeApp();

// 1. Get Raw Recipes (Serve from Firebase Storage)
exports.getRawRecipes = functions.https.onCall(async (data, context) => {
    try {
        const bucket = admin.storage().bucket('cooking-app-e5d3c.appspot.com');
        const file = bucket.file('raw_recipes.json');

        // Check if file exists
        const [exists] = await file.exists();
        if (!exists) {
            console.error("raw_recipes.json not found in storage bucket");
            throw new functions.https.HttpsError('not-found', 'Recipes file not found in storage.');
        }

        // Download the file content
        const [buffer] = await file.download();
        const jsonString = buffer.toString('utf8');

        return JSON.parse(jsonString);
    } catch (error) {
        console.error("Storage Error:", error);
        throw new functions.https.HttpsError('internal', 'Failed to retrieve recipes.', error.message);
    }
});

// 2. Parse Recipe with Gemini (Server-side)
exports.parseRecipeWithGemini = functions.https.onCall(async (data, context) => {
    const text = data.text;

    if (!text) {
        throw new functions.https.HttpsError('invalid-argument', 'The function must be called with a "text" argument.');
    }

    // API Key from Environment Variables
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
        throw new functions.https.HttpsError('failed-precondition', 'Gemini API Key not configured.');
    }

    try {
        const genAI = new GoogleGenerativeAI(apiKey);
        const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

        const prompt = `
Convert this recipe text into valid JSON matching this schema: 
{ 
  "title": string, 
  "ingredients": [{"name": string, "amount": string}], 
  "steps": [{"step_index": int, "title": string, "instruction": string, "timer_seconds": int or null}] 
}

IMPORTANT RULES:
1. Break down the recipe into as many SMALL, GRANULAR steps as possible. 
2. Only combine multiple actions into a single step if they are related
3. Example: Instead of "Chop onions and fry them", split it into "Chop the onions" and "Fry the onions".
4. If there is a timer mentioned (e.g. "cook for 5 mins"), ensure 'timer_seconds' is set (e.g. 300).
5. Extract ALL ingredients and steps from the text.

Return ONLY raw JSON, no markdown formatting.

Recipe Text: ${text}
`;

        const result = await model.generateContent(prompt);
        const response = await result.response;
        let jsonString = response.text();

        // Clean up potential markdown
        jsonString = jsonString.replace(/```json\n?/g, '').replace(/```/g, '').trim();

        return JSON.parse(jsonString);

    } catch (error) {
        console.error("Gemini Error:", error);
        throw new functions.https.HttpsError('internal', 'Failed to parse recipe.', error.message);
    }
});
