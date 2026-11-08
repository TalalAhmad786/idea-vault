# Ideas

An installable web app (PWA) for storing product ideas so you never forget them.
It installs on iPhone from Safari: no Mac, no App Store, no Developer Mode, no cost.

**Live app:** https://talalahmad786.github.io/idea-vault/

## Features
- **Quick Idea** button: capture a thought in seconds
- Full details: description, problem it solves, next step, category, tags, priority, pin
- Status pipeline: Idea → Exploring → Building → Shipped (or Parked)
- Search everything, filter by status, sort by date, priority or name
- Works offline; data stays on your device
- Export and import JSON backups (Files / iCloud Drive)
- Dark mode, iOS-style design

## Install on iPhone
1. Open the live app link in **Safari**.
2. Tap **Share → Add to Home Screen → Add**.
3. Open **Ideas** from the home screen.

Always use the home-screen icon: it has its own storage, separate from Safari tabs.

## Hosting (GitHub Pages)
Repo **Settings → Pages → Deploy from a branch → `main` / `/docs`**.
Every push to `main` updates the app. Installed copies pick up the new version
the next time they're opened.

## Run locally
```bash
cd docs && python3 -m http.server 8000
# open http://localhost:8000
```

## Files
```
docs/
  index.html            the whole app (HTML, CSS, JS)
  sw.js                 service worker (offline cache)
  manifest.webmanifest  install metadata
  icon-*.png            app icons
```
