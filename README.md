# MindBloom Mobile App Project

MindBloom is a Flutter mental wellness app for mood tracking, journaling, habit building, reminders, privacy lock, and location-based wellness insight.

## What This Version Supports

- Flutter mobile app for Android and iOS
- local persistence for offline resilience
- PHP/MySQL backend support for real remote sync
- journal photo uploads to the backend
- Google Maps-based mood map support
- habit and journal reminder scheduling
- biometric and passcode lock testing

## Project Structure

- `lib/` Flutter application source
- `backend/api/` PHP API endpoints
- `backend/sql/schema.sql` MySQL schema
- `backend/api/config.sample.php` backend config template

## Important Security Note

This repository is public, so database credentials are intentionally not stored in Git.

Do not commit your real `backend/api/config.php` file or raw database password.

## Backend Setup

### 1. Prepare the server

Upload the contents of `backend/` to your PHP hosting so that the API files are publicly reachable.

Example deployed structure:

```text
public_html/
  mindbloom_api/
    api/
      health.php
      moods.php
      journals.php
      habits.php
      bootstrap.php
      helpers.php
      db.php
      config.php
    sql/
      schema.sql
    uploads/
```

### 2. Create backend config

On the server, copy:

```text
backend/api/config.sample.php
```

to:

```text
backend/api/config.php
```

Then replace the placeholders with your real database values.

Example server-side `config.php` structure:

```php
<?php

return [
    'db_host' => 'YOUR_DB_HOST',
    'db_port' => 3306,
    'db_name' => 'YOUR_DB_NAME',
    'db_user' => 'YOUR_DB_USER',
    'db_pass' => 'YOUR_DB_PASSWORD',
    'upload_dir' => __DIR__ . '/../uploads',
];
```

### 3. Import the schema

Import:

```text
backend/sql/schema.sql
```

into your MySQL database using phpMyAdmin.

### 4. Test the API

After uploading the PHP files, open:

```text
https://your-domain-or-server-path/mindbloom_api/api/health.php
```

You should get a JSON response showing success.

Important:

- your `phpMyAdmin` URL is not the same thing as the API URL
- the Flutter app should point to the public `.../api` folder, not to the phpMyAdmin page
- a working API base URL usually looks like `https://your-domain.com/mindbloom_api/api`

Example `config.php` values for your hosting setup:

```php
<?php

return [
    'db_host' => 'localhost',
    'db_port' => 3306,
    'db_name' => 'mobileapps_2026B_maameyaa_basoah',
    'db_user' => 'maameyaa.basoah',
    'db_pass' => 'maameyaa',
    'upload_dir' => __DIR__ . '/../uploads',
];
```

If `localhost` fails, ask your hosting provider for the MySQL host name used by PHP applications.

## Google Maps Setup

Google Maps requires a real API key. According to the official `google_maps_flutter` package and Google Maps for Flutter setup guide, Android needs the key in `AndroidManifest.xml`, and iOS needs it provided through `AppDelegate.swift` after enabling the Maps SDK for each platform. Sources: [google_maps_flutter on pub.dev](https://pub.dev/packages/google_maps_flutter) and [Google Maps for Flutter setup](https://developers.google.com/maps/flutter-package/config).

### Android

Open:

```text
android/app/src/main/AndroidManifest.xml
```

Replace:

```xml
android:value="YOUR_GOOGLE_MAPS_API_KEY"
```

with your actual key.

### iOS

Open:

```text
ios/Runner/Info.plist
```

Replace:

```xml
<string>YOUR_GOOGLE_MAPS_API_KEY</string>
```

with your actual key.

Also make sure you enable:

- Maps SDK for Android
- Maps SDK for iOS

in your Google Cloud project.

## Flutter App Setup

### Install dependencies

```bash
flutter pub get
```

### Run on device

```bash
flutter run
```

### Configure remote sync in the app

Open:

```text
Settings -> Backend URL
```

Then enter your deployed API base URL, for example:

```text
https://your-domain-or-server-path/mindbloom_api/api
```

The sync card should switch from not connected to connected once the API is reachable.

If it still says not connected:

- confirm the URL ends with `/api`
- open `health.php` manually in a browser
- make sure `api/config.php` exists on the server
- make sure `uploads/` is writable by PHP
- confirm the MySQL schema was imported successfully

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
- journal entries with image upload support
- habit tracking with streak logic
- local reminder scheduling for habits and journaling
- dashboard summaries and mood trend chart
- map-based location insight with Google Maps support
- biometric and passcode protection
- offline-first local saving with later sync to PHP/MySQL

## Notes

- if the backend URL is not configured or unreachable, the app still falls back to local data so testing can continue
- startup now attempts a background sync when a backend URL is configured
- new journal images are saved more reliably and can also upload to the PHP backend
- the app supports offline usage for core data entry through local SQLite storage
