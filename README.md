# CampusCare

Campus incident reporting app for ALU. Students report broken facilities, water and power outages, damaged furniture, sanitation and safety problems. Staff review reports and move them through Submitted, In Progress and Resolved.

## Stack

- Flutter 3.27 or newer (project generated with Flutter 3.47 stable)
- Provider for state management
- Firebase Authentication (email and password, verified ALU addresses only)
- Cloud Firestore for users and incidents
- Photos stored as compressed JPEGs in Firestore (works on the free Spark plan, no Firebase Storage needed)

## Project layout

```
lib/
  core/         theme, validators, date formatting, campus locations
  models/       AppUser, Incident, StatusChange, IncidentFilter
  services/     Firebase access (auth, users, incidents, photos)
  providers/    SessionProvider, IncidentProvider, ReportFormProvider
  screens/      auth flow, home, reports, report form, details, profile
  widgets/      shared UI pieces
test/           unit and widget tests
firestore.rules
```

## Setup

1. Run `flutter pub get`.
2. In the Firebase console, create a project and enable Email/Password sign-in and Cloud Firestore.
3. Connect the app:
   ```
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart`.
4. Deploy the Firestore rules and indexes with `firebase deploy --only firestore` (or paste `firestore.rules` into Firestore > Rules and publish).
5. `flutter run`

If `flutter pub get` reports version conflicts, run `flutter pub upgrade --major-versions`.

## Creating a staff account

Accounts always register as students. To promote one, register and verify it in the app, then open Firestore > `users` > that user's document and change `role` from `student` to `staff`. The app picks up the change immediately.

## Data model

```
users/{uid}
  fullName, email, role (student | staff), program, createdAt

incidents/{incidentId}
  title, description, category, location, locationDetail
  photoCount: 0–3
  status: submitted | inProgress | resolved
  reporterId
  createdAt, updatedAt
  history: [{ status, changedAt, changedBy, note? }]
  affectedBy: [uid]

incidents/{incidentId}/photos/{0|1|2}
  bytes: JPEG data (under 900 KB, written in the same batch as the incident)
```

## Tests

```
flutter test
```
