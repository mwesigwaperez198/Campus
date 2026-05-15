# CampusConnect

institutional social app built for a single university at a time.

## Implemented in this version

- Student/Admin sign-in and sign-up flow
- Session restore on app launch
- Supabase profile persistence with role validation
- Campus feed with social posts, engagement actions, and quick sections
- Groups, Chat, Events, and Directory tabs
- Blue campus-themed UI inspired by the provided mockups

## Run the app

```bash
flutter pub get
flutter run
```

## Connect Supabase By creating an account.(visit: www.supabase.com)

1. Open Supabase SQL Editor and run:
   - `supabase/schema.sql`
2. Run the app with your Supabase keys:

Pass your Supabase values when running the app:

```bash
flutter run \
  --dart-define=SUPABASE_URL=your_project_url \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key
```
When keys are not provided, the app falls back to local demo auth so UI development can continue.

## USING AN EMULATOR TO OPEN THE APP:
An APK is not opened like a normal file on Windows. It must be installed on an Android phone.

## Do this:

-Copy this file to your phone:

>>>>Path: campus_connect\build\app\outputs\flutter-apk\app-release.apk

-On your phone, open Files / File Manager.

-Tap app-release.apk.

## If Android blocks it, enable:

In settings >> Enable Install unknown apps
for your file manager or browser.

Tap Install:
>>If you want to test from the computer directly with a USB-connected Android phone, run:<<
```bash
adb install -r build\app\outputs\flutter-apk\app-release.apk
```
If Windows says “unsupported format,” that is normal. Windows cannot run APK files directly unless you use an Android emulator


## EXPECTED FLOW AND ACTIONS:
Based on the current app, the expected flow should be:

Splash screen
The app opens with the Campus Connect / Customized branding first for any institution.

## Auth choice screen
After splash, it should take you to login/register choices if you are not already signed in.

## Login / Register
Users create an account or log in through Supabase.

## Main app
After login, it opens Campus Connect experience:

>Feed with stories at the top
>Post cards styled like Instagram
>Create post button
>Reels
>Groups
>Messages
>Events
>Directory / Explore
>Profile / Settings
## The feed UI Will now feel more polished: campus-branded top bar, gradient story/
profile rings, square post images, like/save buttons, double-tap heart animation, loading/
error states, and cleaner empty states

## ENJOY THE FIRST INSTITUTIONAL APP FEELING IN UGANDA ##

