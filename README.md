# MindBloom Mobile App Project

MindBloom is a Flutter mental wellness app for mood tracking, journaling, habit building, reminders, privacy lock, and location-based wellness insight.

## What This Demo Build Supports

- Flutter mobile app for Android and iOS
- local phone storage for reliable offline use
- mood tracking with optional notes and location
- journal entries with image attachment
- habit tracking with streak logic
- local notifications for reminders
- mood map using OpenStreetMap tiles
- biometric and passcode lock testing
- sensor-based motion insight with a bloom-energy prompt

## Important Note

This final demo build is intentionally configured for local mobile storage rather than live server sync.

That means:

- user data saves directly on the device
- the app works even without internet
- the app is more dependable for classroom demo and submission

## Project Structure

- `lib/` Flutter application source
- `backend/` optional PHP/MySQL backend experiments kept in the repo, but not required for the final demo build
- `docs/final_report.md` final report draft

## Flutter App Setup

### Install dependencies

```bash
flutter pub get
```

### Run on device

```bash
flutter run
```

## Build APK

```bash
flutter build apk --release
```

Generated file:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Key Features

- mood check-ins with optional notes and location
- journal entries with saved photos
- habit tracking with completion history and streaks
- local reminder scheduling for habits and journaling
- dashboard summaries and mood trend chart
- visible mood map with saved locations
- biometric and passcode protection
- offline-first local saving

## Notes

- the app stores moods, journals, habits, reminders, and settings locally on the phone
- the map uses OpenStreetMap tiles, so it shows without needing a Google Maps API key
- the sensor area uses accelerometer data to estimate motion and generate a simple wellness prompt
