---
description: How to deploy Cloud Functions to Production
---

1.  **Deploy Functions**
    Run the deploy command from the project root:
    ```bash
    firebase deploy --only functions
    ```

2.  **Set Environment Variable (Secrets)**
    Since `.env` file secrets are **NOT** automatically deployed for security (unless you are using Gen 2), you need to set the configuration in the live environment.
    
    For your current setup (Gen 1 / Standard), use:
    ```bash
    firebase functions:secrets:set GEMINI_API_KEY
    # Paste your API Key when prompted
    ```
    
    *Note: If you get an error about secrets not being enabled, you might need to enable the Secret Manager API in your Google Cloud Console for this project.*

    **Alternative (Simpler for Gen 1):**
    Use environment configuration:
    ```bash
    firebase functions:config:set gemini.key="YOUR_API_KEY"
    ```
    *If you do this, you must update `index.js` to use `functions.config().gemini.key` instead of `process.env.GEMINI_API_KEY`.*

3.  **Redeploy**
    After setting secrets/config, redeploy to ensure the latest environment variables are picked up.
    ```bash
    firebase deploy --only functions
    ```
