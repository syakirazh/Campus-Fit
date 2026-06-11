# Campus Fit — initial requirements

I want to build Campus Fit, a mobile wellness app for university students that helps them stay active around campus. It tracks daily steps, offers quick dorm-room workouts, and helps students discover and join local intramural sports events. The app should be usable straight away without an account (guest mode), with the option to create an account to save progress.

The app should be built with Flutter (Dart), target Android, and have the following features:

## Onboarding & entry

- A splash screen showing the app logo and tagline on launch.
- A 3-page intro carousel (swipeable, with page dots) introducing the three core features: steps, workouts, and events.
- A welcome screen offering three entry options: create account, log in, or continue as guest.
- Guest is the default, low-friction way in — the app must be fully usable without an account.

## Accounts & guest mode

- Users can sign up (full name, email, password) or log in.
- Users can continue as a guest and set a display name (this step is skippable).
- A guest can create an account later without losing their progress.
- The signed-in vs guest state should be tracked in a single auth/session state object.
- While in guest mode, the profile shows a "create an account to save your progress" prompt.

## Home dashboard

The home tab is a dashboard that surfaces all the key functionality in one view:

- Today's steps shown in a circular progress ring against a daily goal.
- Quick stats: distance (km), calories (kcal), and active minutes.
- A "this week" mini bar chart of daily activity (7 days).
- A "today's workout" card with a one-tap start.
- A "next event" card linking through to the upcoming intramural event.
- A streak indicator and a notifications entry point.

## Step tracking

- Track daily steps from the device step sensor (e.g. the `pedometer` package, backed by Android's hardware step-counter sensor / Health Connect).
- Show progress toward a configurable daily step goal.
- A step history screen with a week/month toggle, a bar chart, and summary stats (daily average, total distance).
- A "campus zones" screen showing a simple campus map with explored vs locked zones, to gamify walking.

## Dorm-room workouts

- A workouts list with a featured "today's pick" plus a list of short routines, each showing duration, difficulty, and equipment.
- A workout detail screen listing the exercises and their durations, with a "start workout" button.
- An in-progress workout player: a full-screen timer that counts down each exercise, shows the current and next move, and has pause/skip controls. Use a `Timer` (or `Stopwatch`) to drive the countdown.
- A workout-complete summary screen showing calories burned, time, exercises done, and the updated streak.

## Intramural events

- An events list of upcoming intramural games and runs (e.g. futsal, badminton, fun runs), each with sport, time, venue, and a join action.
- An event detail screen with date/time, venue, players joined, organizer, participant avatars, and a "join" button.
- A "my events" screen split into registered and past events.

## Profile & achievements

- A profile home with the user's avatar, name, and lifetime stats (steps, workouts, events), plus a settings/menu list.
- An "About Campus Fit" screen that introduces the app and its three core features and shows the version number.
- An edit-profile screen (display name, email, faculty, daily step goal, profile photo).
- An achievements screen with a streak summary and a grid of earned and locked badges.

## Other requirements

### Navigation

- A persistent bottom navigation bar with four tabs: Home, Workouts, Events, Profile.
- Tab state should be preserved when switching tabs (e.g. an `IndexedStack`).
- Detail screens (workout detail, event detail, settings, etc.) are pushed routes with a back button, not tabs.

### Theming

- Theming should be done by setting the `theme` and `darkTheme` on the `MaterialApp` using `ThemeData` and a `ColorScheme.fromSeed`, rather than hardcoding colors and sizes in the widgets themselves.
- Use a single seed/brand colour, teal (`#0F6E56`), so the palette is generated consistently.
- Support both light and dark mode, following the system setting.
- Use Material 3 (`useMaterial3: true`).
- Coral (`#D85A30`) is the secondary accent (used for events and recovery items); keep colour usage meaningful rather than decorative.

### Permissions & settings

- A settings screen with: notifications toggle, daily step goal, units, theme, and privacy.
- Request the Android activity-recognition (step) and notification permissions when first needed. If a permission is denied, disable the dependent feature gracefully rather than crashing.

### Data & state

- Guest data (display name, steps, workout history, event RSVPs) is persisted locally with `shared_preferences`.
- Accounts and cross-device sync can be added later with `firebase_auth` and `cloud_firestore` without changing the screens.

### Code style

- Ensure proper separation of concerns by creating a suitable folder structure (e.g. `models/`, `screens/`, `widgets/`, `services/`, `theme/`).
- Prefer small, composable widgets over large ones.
- Prefer using flex values over hardcoded sizes when creating widgets inside rows/columns, so the UI adapts to various screen sizes.
- Use `log` from `dart:developer` rather than `print` or `debugPrint` for logging.

## Screen list (23 total)

**Onboarding & entry**
1. Splash
2. Intro: steps
3. Intro: workouts
4. Intro: events
5. Welcome

**Account**
6. Sign up
7. Log in
8. Guest start

**Home**
9. Dashboard
10. Step history
11. Campus zones

**Workouts**
12. Workouts list
13. Workout detail
14. Workout player
15. Workout complete

**Events**
16. Events list
17. Event detail
18. My events

**Profile**
19. Profile home
20. About Campus Fit
21. Edit profile
22. Achievements
23. Settings
