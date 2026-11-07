# Ideas (IdeaVault)

A native SwiftUI iPhone app for storing product ideas so you never forget them.
It's built without a Mac: GitHub Actions compiles it on a free cloud Mac, and you
sideload it with your free Apple ID.

## Features
- **Quick Idea** button: capture a thought in seconds
- Full details: description, problem it solves, next step, category, tags, priority, pin
- Status pipeline: Idea → Exploring → Building → Shipped (or Parked)
- Swipe right to move an idea to the next stage, swipe left to pin or delete
- Search across everything, filter by status, sort by date, priority or name
- Stored on-device with SwiftData, works offline
- Export and import JSON backups (Files / iCloud Drive)
- Dark mode, native iOS look

Requires iOS 17 or later.

---

## 1. Build it on GitHub (free)

```bash
cd /run/media/taq/Data/laptopdata/Gray/Ideas
git init -b main
git add .
git commit -m "Initial Ideas app"
gh repo create idea-vault --public --source=. --push
# (or create the repo on github.com and `git remote add origin ... && git push -u origin main`)
```

Open the repo's **Actions** tab and wait about 5–10 minutes for "Build iOS app" to finish.
The app file appears under **Releases → latest → IdeaVault.ipa**.
Every push to `main` rebuilds it automatically.

## 2. Install on your iPhone (free Apple ID)

Recommended: **SideStore**, which refreshes the app on the phone itself.

1. On iPhone: **Settings → Privacy & Security → Developer Mode → On** (the phone restarts).
2. Follow the SideStore install guide at https://docs.sidestore.io. It works from Linux;
   you plug the iPhone in over USB once to pair it.
3. On the iPhone, open the latest release of this repo in Safari, download `IdeaVault.ipa`,
   and tap **Share → SideStore** (or open SideStore → **+** → pick the file).
4. Sign in with your Apple ID when asked. The app appears on your home screen.
5. First launch: **Settings → General → VPN & Device Management** → trust your Apple ID.

Alternative: **AltServer-Linux** (https://github.com/NyaMisty/AltServer-Linux) plus AltStore.

## 3. Keep it alive

- Free Apple IDs sign apps for **7 days**. Open SideStore and tap **Refresh** at least once a week.
- If it expires, the app just won't open until you refresh it. **Your ideas are not lost.**
- Use **Settings → Export Backup** in the app now and then, just in case.

## Updating the app

Edit the code, push to `main`, wait for the build, download the new `.ipa`, and install it
over the old one in SideStore. Your data is kept.

## Project layout

```
IdeaVault/
  IdeaVaultApp.swift      app entry, SwiftData container
  Models/                 Idea model, status/priority enums, backup format
  Views/                  list, quick capture, editor, detail, settings, components
  Assets.xcassets/        app icon
project.yml               XcodeGen spec (generates the .xcodeproj in CI)
.github/workflows/        cloud build → unsigned .ipa
```
