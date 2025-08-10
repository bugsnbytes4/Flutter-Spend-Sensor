# SpendSense (Flutter) — Project Skeleton

This archive contains a ready-to-open Flutter project skeleton focused on the **Smart Expense Tracker** (SpendSense).
It includes a complete `lib/` directory with responsive UI, Firebase wiring placeholders, receipt upload handling,
and a rule-based + predictive "AI Insights" service that runs offline (no external AI keys required).

## How to finish setup (in VS Code on your machine)

1. Extract this ZIP to a folder (e.g. `C:\Users\You\Projects\spendsense`).
2. Open a terminal there and run:
   ```bash
   # populate platform folders (android/ios/web) & default files
   flutter create .
   flutter pub get
   ```
3. Configure Firebase (this will generate `lib/firebase_options.dart`):
   - Install FlutterFire CLI if you don't have it:
     ```bash
     dart pub global activate flutterfire_cli
     ```
   - Run:
     ```bash
     flutterfire configure
     ```
   Follow prompts to select your Firebase project and platforms. That creates `lib/firebase_options.dart`.

4. Run app:
   - For web: `flutter run -d chrome`
   - For Android emulator/device: `flutter run`

## Notes
- The project uses in-memory receipt uploads (via file_picker) and Firebase Storage for persistent uploads.
- AI insights are implemented locally in `lib/services/ai_service.dart`. It provides:
  - `suggestCategory(...)` — keyword-based category suggestion
  - `quickInsight(...)` — simple rules-based flags
  - `predictNextMonthTotal(...)` — simple linear-predictor based on monthly totals
- Replace or extend `AiService` to call an external AI API (OpenAI etc.) if you want advanced analysis.
- If you want a GitHub repo, initialize git and push after extracting:
  ```bash
  git init
  git add .
  git commit -m "Init SpendSense skeleton"
  gh repo create spendsense --public --source=. --remote=origin  # if using GitHub CLI
  git push -u origin main
  ```

If you want, I can also generate a sample `firebase_options.dart` stub or a small CI workflow.
