# ✏️ Text Free

A fast, minimal web tool that removes repeated paragraphs from text. Paste your content, paste the pattern you want gone, and get clean text instantly.

**[Try it live →](https://textfree.aeshp.me/)**

---

## What It Does

Text Free solves a specific problem: removing the same paragraph or sentence that appears repeatedly throughout a document — like disclaimers, watermarks, or injected ad text.

1. **Paste** your full document
2. **Paste** the repeated paragraph you want removed
3. **Click** Clean Text
4. **Copy** the result

That's it. No sign-up, no ads, no tracking.

---

## Features

- **Instant cleaning** — text processing happens client-side with zero delay
- **Built-in metrics** — Firebase-powered usage tracking (hidden in deployed UI, [re-enable easily](#metrics))
- **Mobile responsive** — fully usable on phones and tablets
- **Copy to clipboard** — one-click result copying
- **Single file** — the entire app is one `index.html`

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | HTML, JavaScript, Tailwind CSS |
| Metrics | Firebase Firestore (real-time) |
| Hosting | Vercel |
| Fonts | Inter (Google Fonts) |
| Icons | Font Awesome 6 |

---

## Self-Hosting

### Prerequisites

- A Firebase project with Firestore enabled
- A Vercel account (or any static host)

### 1. Create the Firestore Document

In your Firebase Console → Firestore, create:

```
Collection: stats
Document: global_metrics
```

With these fields:

| Field | Type | Initial Value |
|---|---|---|
| `totalCharacters` | number | `0` |
| `totalRemovals` | number | `0` |
| `lastUpdated` | timestamp | (any) |

### 2. Set Firestore Security Rules

Configure strict rules for `stats/global_metrics`. Your rules should enforce:

- **Read**: Allow public reads
- **Update**: Allow only if:
  - Document has exactly the expected fields (`totalCharacters`, `totalRemovals`, `lastUpdated`)
  - Both counters are numbers and increase monotonically
  - Increments are bounded (set reasonable min/max per write)
  - `lastUpdated` must be a server timestamp (`request.time`)
- **Create / Delete**: Deny completely
- **Catch-all**: Deny all other paths

Refer to the [Firestore Security Rules documentation](https://firebase.google.com/docs/firestore/security/get-started) for implementation details.

### 3. Deploy to Vercel

Fork this repo, then add these environment variables in your Vercel project settings:

| Variable | Description |
|---|---|
| `FIREBASE_API_KEY` | Your Firebase API key |
| `FIREBASE_AUTH_DOMAIN` | `your-project.firebaseapp.com` |
| `FIREBASE_PROJECT_ID` | Your Firebase project ID |
| `FIREBASE_STORAGE_BUCKET` | `your-project.firebasestorage.app` |
| `FIREBASE_MESSAGING_SENDER_ID` | Your messaging sender ID |
| `FIREBASE_APP_ID` | Your Firebase app ID |
| `FIREBASE_MEASUREMENT_ID` | Your Google Analytics measurement ID |

The `build.sh` script automatically injects these into `index.html` during deployment.

### 4. Local Development

For local testing, manually replace the `__PLACEHOLDER__` values in `index.html` with your Firebase config, then:

```bash
python3 -m http.server 8000
```

Open `http://localhost:8000` in your browser.

---

## Project Structure

```
text-free/
├── index.html        # The entire app (single file)
├── build.sh          # Vercel build script (injects env vars)
├── vercel.json       # Vercel configuration
├── README.md
└── Assets/
    ├── textfree.svg          # Brand icon
    ├── favicon.ico           # Multi-size favicon
    ├── favicon-16x16.png
    ├── favicon-32x32.png
    ├── apple-touch-icon.png
    ├── android-chrome-192x192.png
    ├── android-chrome-512x512.png
    └── site.webmanifest
```

---

## Anti-Abuse Protections

Since this is a frontend-only app with no authentication, metrics are protected by multiple layers:

| Layer | What It Does |
|---|---|
| Firestore rules | Monotonic increase only, bounded increments, server timestamp enforced |
| Signature dedup | Same input won't trigger duplicate writes |
| Session persistence | Dedup state survives page refresh |
| Rate limit | Max 3 writes per 10-second window |
| Cooldown | 3-second minimum between writes |
| Write lock | Prevents concurrent Firestore transactions |
| Button lock | Disables button during async processing |
| Input bounds | Min 20 chars, max 50K chars, at least 1 removal |

---

## Metrics

This project includes a Firebase-based usage metrics system.

Metrics are **not displayed** in the deployed version, but the tracking logic remains fully active in the codebase. When Firebase is configured, metrics are tracked silently in the background. When Firebase is not configured (e.g. local development or forked repos), the app runs normally with no errors.

### For Developers Who Want to Enable Metrics Display

1. Open `index.html`
2. Find the `[METRICS DISPLAY - HIDDEN]` and `[MOBILE METRICS DISPLAY - HIDDEN]` comment blocks
3. Replace the placeholder UI with the metric spans provided in the comments:

   ```html
   🔥 <span id="metricRemovals">...</span> removals
   ⚡ <span id="metricCharacters">...</span> processed
   ```

4. Ensure your Firebase config is set up correctly (via Vercel environment variables or by replacing the placeholders directly)
5. Metrics will automatically start displaying in real time — no additional code changes needed

### Extending With Backend Protection

The current implementation includes client-side anti-abuse layers (rate limiting, deduplication, input bounds). For production environments with higher traffic, consider adding a backend or Cloud Function to validate and proxy metric writes — this provides stronger bot protection and prevents direct Firestore access from the client.

---

## License

Open source. Free forever.