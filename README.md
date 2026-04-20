# MindBloom Mobile App Project

MindBloom is a Flutter mental wellness app for mood tracking, journaling, habit building, reminders, privacy lock, and location-based wellness insight.

## What This Version Supports

- Flutter mobile app for Android and iOS
- local persistence for offline resilience
- PHP/MySQL backend support for real remote sync
- journal photo uploads to the backend
- mood map using OpenStreetMap tiles
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
- map-based location insight
- biometric and passcode protection

## Notes

- if the backend URL is not configured or unreachable, the app still falls back to local data so testing can continue
- new journal images are saved more reliably and can also upload to the PHP backend
- OpenStreetMap is used for the map tile layer
