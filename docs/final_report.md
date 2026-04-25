# MindBloom Final Report

## Activity 1: Planning, Case Scenario and Contract

### 1.1 Case Scenario

MindBloom is designed for use in a mental wellness support setting where therapists, counsellors, and mental health specialists encourage clients to monitor their emotional wellbeing between sessions. In many therapy and wellness programs, clients are asked to track moods, reflect on daily events, build healthy habits, and notice patterns related to stress, sleep, movement, or environment. However, these tasks are often done inconsistently through paper notes, scattered mobile tools, or memory alone. This creates a gap between what happens in therapy sessions and what clients experience in real life.

MindBloom addresses this problem by providing a single mobile platform where users can log their mood, write reflective journal entries, attach photos, record location, monitor healthy habits, receive reminders, and protect their personal wellness data. The app is technically built to support mental health specialists because it provides a structured method for clients to capture useful wellbeing information that can later inform therapeutic discussion, coaching, and self-management. The app is therefore suitable for a therapist-guided care model, a counselling center, a university wellbeing service, or a private mental wellness practice.

### 1.2 Background Information on the Organization

The assumed organization for this case study is a community mental wellness practice that offers therapy, stress management support, emotional wellbeing coaching, and routine habit-building guidance for clients. Its purpose is to improve emotional resilience and self-awareness by combining in-person or virtual support sessions with practical daily self-management tools. Its principal services include counselling, mood support, behavioural coaching, and progress monitoring. The target market includes students, young professionals, adults managing stress or anxiety, and clients who need support in maintaining consistent wellness habits between appointments.

Within this setting, therapists and specialists need an app that can:

- help clients capture mood and behaviour information in real time
- support daily habit formation and accountability
- allow personal reflection through journaling
- provide reminders for wellness routines
- use device features to create richer context around behaviour and mood
- protect sensitive mental wellness records

### 1.3 Functional Requirements

The functional requirements of MindBloom are as follows:

- The system shall allow a user to complete onboarding before first use.
- The system shall display a branded splash screen when the application starts.
- The system shall allow users to log a daily mood with a mood label, score, date, and optional note.
- The system shall allow users to save optional location data with a mood entry.
- The system shall allow users to create, edit, view, search, and delete journal entries.
- The system shall allow users to attach a photo to a journal entry using the device camera or image picker.
- The system shall allow users to tag journal entries with mood and date information.
- The system shall allow users to create habits such as hydration, meditation, gratitude, exercise, or sleep routines.
- The system shall allow users to mark a habit as completed for a given day.
- The system shall calculate and display streaks and completion history for habits.
- The system shall allow users to schedule reminders for journaling and habits.
- The system shall send local notifications to remind users about their wellness tasks.
- The system shall capture basic location coordinates and present location-based wellness insight.
- The system shall display a map view showing areas related to mood entries.
- The system shall read device sensor signals to infer motion or inactivity context.
- The system shall protect access to private data using passcode and biometric authentication where available.
- The system shall store data locally for resilience when connectivity is unavailable.
- The system shall support remote synchronization to a PHP/MySQL backend when the backend is configured.
- The system shall allow the backend connection to be tested from within the app.

### 1.4 Non-Functional Requirements

The non-functional requirements of MindBloom are as follows:

- The application should be easy to use for non-technical users.
- The user interface should be visually calm, attractive, and wellness-focused.
- The application should maintain readable colour contrast and accessible layout spacing.
- The application should respond smoothly on Android devices with limited resources.
- The system should remain usable offline for key functions even if the backend is unreachable.
- The application should be modular and maintainable for future extension.
- The backend integration should use a secure separation between the mobile app and database credentials.
- Sensitive user data such as passcodes should be stored securely.
- The application should handle denied permissions gracefully.
- The system should be reliable enough for daily use without frequent crashes or data loss.
- The project should be deployable within a practical academic environment using Flutter and PHP hosting.

### 1.5 Local Resources and Device Features Used

MindBloom satisfies the requirement for multiple local resources and device capabilities through the following features:

- Camera: used for photo-based journal entries and gratitude moments
- GPS or geolocation: used to save location with mood or journal entries and support map-based insight
- Sensors or accelerometer: used for movement and inactivity indication
- Push or local notifications: used for habit reminders and daily journal reminders
- Offline use: supported through local device storage
- Splash screen: implemented as part of the app startup flow
- Biometric authentication: used for fingerprint or face unlock where supported

The use of a web API is also included as a plus, because the application can connect to a PHP-based server and synchronize data to a MySQL database.

## Activity 2: Prototyping, Specification, Architecture and Design

### 2.1 High-Level Application Overview

MindBloom is a mobile wellness application built using Flutter. It provides an integrated environment for mood tracking, journaling, habit management, notifications, privacy protection, and wellness analytics. It is intended to support clients in capturing useful daily wellbeing information and to support therapists or mental health specialists who want clients to maintain structured records between sessions.

### 2.2 Users

The primary users are:

- Clients or end users who record moods, journals, habits, and wellbeing data
- Therapists, counsellors, or mental health specialists who may recommend the app to support therapy or self-management routines

### 2.3 Main Modules

The application contains the following major modules:

- Splash and onboarding module
- Authentication and privacy lock module
- Mood tracking module
- Journal module
- Habit tracking module
- Reminder and notifications module
- Location and map insight module
- Sensor-based activity module
- Dashboard and analytics module
- Backend sync and settings module

### 2.4 Architecture and Communication Flow

MindBloom follows a modular Flutter architecture with Riverpod state management and a service/repository pattern.

High-level communication flow:

1. The user interacts with Flutter screens and widgets.
2. Presentation controllers communicate with shared repositories.
3. Repositories coordinate between local storage and the PHP API service.
4. Local data is stored in SQLite for offline resilience.
5. Remote data is sent to PHP API endpoints.
6. The PHP backend stores structured records in MySQL.

### 2.5 Layers of Implementation

- Presentation layer: screens, widgets, navigation, state updates
- Controller or state layer: Riverpod notifiers and providers
- Service layer: notifications, biometrics, storage, sensors, geolocation, API communication
- Repository layer: decides between local storage and remote sync
- Data layer: SQLite local database and PHP/MySQL backend

### 2.6 Use Case Summary

Main user use cases include:

- register first-time use through onboarding
- log a mood
- attach a note and location to a mood entry
- create a journal entry with text and photo
- review old journal entries
- create and complete habits
- receive scheduled reminders
- view mood trends and dashboard summaries
- view mood-related map markers
- protect access using passcode or biometrics
- configure backend URL and synchronize data to the server

### 2.7 Prototype and Interface Design Notes

The user interface was designed with a soft pink wellness theme to create a calm and supportive feeling. Rounded cards, gentle gradients, and high-contrast typography were used to make the app feel approachable while remaining readable. The splash screen reinforces branding and communicates that the app is a safe personal wellness space. Navigation is bottom-tab based to support quick access to the Home, Mood, Journal, Habits, and Settings sections.

### 2.8 Entity Relationship Overview

The application uses the following core data entities:

- User
- MoodEntry
- JournalEntry
- Habit
- HabitCompletion
- Reminder
- AppSetting

Textual ERD:

- One User can have many MoodEntry records.
- One User can have many JournalEntry records.
- One User can have many Habit records.
- One Habit can have many HabitCompletion records.
- One User can have many Reminder records.
- One User can have many AppSetting records.

### 2.9 Database Schema Description

The remote MySQL database stores:

- `users`
- `mood_entries`
- `journal_entries`
- `habits`
- `habit_completions`
- `reminders`
- `app_settings`

These tables support secure and structured persistence of user wellness data through the PHP backend.

## Activity 3: Implementation

### 3.1 Tools, Libraries, Frameworks and Languages

The following tools and technologies were used:

- Flutter for cross-platform mobile application development
- Dart as the primary programming language
- Riverpod for state management
- GoRouter for navigation
- SQFlite for local database storage
- Flutter Secure Storage for passcode protection
- Flutter Local Notifications for reminder scheduling
- Local Auth for biometric authentication
- Image Picker for camera and photo access
- Geolocator for location capture
- Sensors Plus for motion and inactivity signal
- Flutter Map with OpenStreetMap tiles for map-based visualization
- PHP for backend API development
- MySQL for remote data persistence
- phpMyAdmin for schema import and database administration
- Git and GitHub for version control

### 3.2 Implementation Summary

The application was implemented as a real mobile system rather than a static prototype. The Flutter app manages mood tracking, journaling, habits, dashboard analytics, reminders, map-based insight, and privacy controls. A splash screen was added to improve startup branding and provide a more polished first impression.

The local database provides resilience so users do not lose progress if connectivity is weak. A PHP backend was added to support real server-based synchronization to MySQL, which makes the application more suitable for practical deployment and demonstrates full-stack capability. Journal images can be uploaded through the backend, while habit completions, moods, and journals are stored as structured records.

### 3.3 APIs and Components

The project uses both device-side and server-side APIs:

- Device APIs for notifications, biometrics, location, and sensors
- OpenStreetMap tile service for map display
- PHP REST-style endpoints for backend synchronization

Main backend endpoints:

- `health.php`
- `bootstrap.php`
- `moods.php`
- `journals.php`
- `habits.php`

### 3.4 Current Quality and Remaining Considerations

The current implementation is functional and demonstrates real mobile application development with local resources, backend support, and modern UI design. However, final backend success still depends on correct hosting deployment, database configuration, and API URL setup. Future enhancements could include therapist-facing dashboards, client sharing permissions, cloud backup accounts, richer analytics, and appointment-linked progress summaries.

## Functional Requirements Summary Table

| ID | Requirement |
| --- | --- |
| FR1 | The app shall show a splash screen at startup. |
| FR2 | The app shall support onboarding for first-time users. |
| FR3 | The app shall allow mood tracking with notes. |
| FR4 | The app shall allow journal creation with optional images. |
| FR5 | The app shall allow habit creation and completion tracking. |
| FR6 | The app shall schedule and send reminders. |
| FR7 | The app shall capture location data when permitted. |
| FR8 | The app shall show map-based wellness insight. |
| FR9 | The app shall read sensor activity context. |
| FR10 | The app shall support passcode and biometric privacy lock. |
| FR11 | The app shall save data locally for offline use. |
| FR12 | The app shall support remote sync to PHP/MySQL. |

## Non-Functional Requirements Summary Table

| ID | Requirement |
| --- | --- |
| NFR1 | The app should be usable and intuitive. |
| NFR2 | The app should have a calm and aesthetically pleasing design. |
| NFR3 | The app should perform smoothly on mobile devices. |
| NFR4 | The app should remain useful when offline. |
| NFR5 | The app should protect sensitive user information. |
| NFR6 | The app should be modular and maintainable. |
| NFR7 | The app should handle errors and permission denials gracefully. |
| NFR8 | The backend integration should avoid exposing database credentials in the public repository. |
