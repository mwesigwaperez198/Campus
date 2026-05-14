# 📧 Email Verification - Visual Overview

## Authentication Flow with Email Verification

```
┌─────────────────────────────────────────────────────────────┐
│                  CAMPUS CONNECT LOGIN FLOW                  │
└─────────────────────────────────────────────────────────────┘

┌──────────────────────────┐
│  REGISTRATION PROCESS    │
└──────────────────────────┘
         ↓
    User Registers
    (email + password)
         ↓
┌─────────────────────────────────────┐
│  Account Created in Supabase        │
│  Status: Email Unverified ❌        │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────┐
│  Verification Email Sent            │
│  ✉️ Contains verification link      │
│  ⏱️ Link expires in 24 hours        │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────┐
│  User Sees: "Check Your Email"      │
│  - Email shown                      │
│  - Resend button available          │
│  - Back to login button             │
└─────────────────────────────────────┘
         ↓
    User Checks Email
         ↓
    User Clicks Link
         ↓
┌─────────────────────────────────────┐
│  Email Verified ✅                  │
│  Account Status: Ready to Login     │
└─────────────────────────────────────┘
         ↓
    User Returns to App
         ↓

┌──────────────────────────┐
│    LOGIN PROCESS         │
└──────────────────────────┘
         ↓
    User Enters Credentials
         ↓
┌─────────────────────────────────────┐
│  Supabase Checks:                   │
│  1. Email exists? ✓                 │
│  2. Password correct? ✓             │
│  3. Email verified? ✓               │
└─────────────────────────────────────┘
         ↓
       ALL CHECKS PASS?
         ├─ YES → User Logged In ✅
         │        Redirect to Home
         │
         └─ NO → Show Error ❌
                 "Please verify email"
```

---

## Registration Flow vs Login Flow

### REGISTRATION FLOW (First Time)
```
Fill Form
  ↓
Click "REGISTER"
  ↓
Validation ✓
  ↓
Send to Supabase
  ↓
Account Created
  ↓
Verification Email Sent
  ↓
Show "Check Your Email"
  ↓
User Verifies Email
  ↓
Account Ready ✓
```

### LOGIN FLOW (After Verification)
```
Enter Email & Password
  ↓
Click "LOG IN"
  ↓
Check Credentials
  ↓
Check Email Verified
  ↓
  ├─ Verified → Login Success ✓
  │           Redirect to Home
  │
  └─ NOT Verified → Show Error
                   "Verify email first"
```

---

## Screen Flow in App

```
┌──────────────────────┐
│   Splash Screen      │
│   (4 seconds)        │
│   "from Novara"      │
└──────────┬───────────┘
           ↓
┌──────────────────────┐
│   Check Auth State   │
└──────────┬───────────┘
           ↓
      User Logged In?
      ├─ YES → Home/Feed
      └─ NO  → Login Screen
               ↓
        ┌─────────────────────┐
        │   LOGIN PAGE        │
        │                     │
        │ - Email field       │
        │ - Password field    │
        │ - Error messages    │
        │                     │
        │ Buttons:            │
        │ - LOG IN            │
        │ - CREATE ACCOUNT    │
        └────┬────────┬───────┘
             │        │
          Login    Register
             │        │
             ↓        └───────────────┐
          ┌──────┐                    ↓
          │HOME  │         ┌──────────────────────┐
          │FEED  │         │  REGISTER PAGE       │
          │MSGS  │         │                      │
          │      │         │ - Email field        │
          │      │         │ - Password field     │
          │      │         │ - Confirm password   │
          └──────┘         │                      │
                           │ Buttons:             │
                           │ - REGISTER           │
                           │ - Back to Login      │
                           └────────┬─────────────┘
                                    ↓
                          ┌──────────────────────┐
                          │ Check Your Email     │
                          │                      │
                          │ ✉️ Email shown      │
                          │ 📧 Link sent        │
                          │                      │
                          │ Buttons:             │
                          │ - Resend email       │
                          │ - Back to login      │
                          └────────┬─────────────┘
                                   ↓
                        User Verifies Email
                        (clicks link in email)
                                   ↓
                          ┌──────────────────────┐
                          │ Return to App        │
                          │ Log in with          │
                          │ verified email       │
                          └────────┬─────────────┘
                                   ↓
                                 ┌──────┐
                                 │HOME  │
                                 │FEED  │
                                 └──────┘
```

---

## Email Message Example

### From: noreply@supabase.io

```
Subject: Confirm your signup

You've signed up for Campus Connect.

Click the link below to confirm your email:
https://your-project.supabase.co/auth/v1/verify?...

This link expires in 24 hours.

If you didn't sign up, you can ignore this email.
```

---

## State Timeline for User

### Unverified User
```
Time | Status              | Can Login? | What They See
-----|---------------------|-----------|------------------
0s   | Account Created     | ❌ NO      | "Check Your Email"
10m  | Email Not Verified  | ❌ NO      | "Check Your Email"
1h   | Email Not Verified  | ❌ NO      | "Check Your Email"
...
```

### Verified User
```
Time | Status              | Can Login? | What They See
-----|---------------------|-----------|------------------
0s   | Account Created     | ❌ NO      | "Check Your Email"
5m   | Clicks Link         | ✅ YES    | Can login
10m  | Email Verified      | ✅ YES    | Home/Feed
...
```

---

## Error Scenarios

### Scenario 1: Try Login Before Verification
```
User Action          → System Check        → Result
─────────────────────────────────────────────────────
Enter credentials    → Email verified?     → ❌ NO
                       Show Error:
                       "📧 Please verify 
                        your email first"
                       Stay on login page
```

### Scenario 2: Verification Link Expired
```
User Action          → System Check        → Result
─────────────────────────────────────────────────────
Click old email link → Is link valid?      → ❌ EXPIRED
                       (24 hours)
                       → In app:
                         "Resend email"
                         button available
```

### Scenario 3: Didn't Receive Email
```
User Action          → System Action       → Result
─────────────────────────────────────────────────────
Click Resend button  → Send new email      → ✅ New link
on verification      → with fresh link     → User clicks
screen                                     → Email verified
```

---

## Authentication Status Indicators

### In Registration:
- 📧 Account created (email unverified)
- 🔄 Verification email sent
- ⏳ Waiting for verification (up to 24h)

### In Login:
- ✅ Email verified
- 🔒 Password correct
- 👤 Logged in & authenticated

### Error States:
- ❌ Email not verified
- ❌ Password wrong
- ❌ User not found
- ❌ Link expired

---

## Security: What Gets Verified

### Registration Verification:
✅ Email ownership (must verify email)
✅ Password strength (min 6 chars)
✅ Unique email (no duplicates)

### Login Verification:
✅ Email exists in system
✅ Password matches hashed version
✅ Email is verified (most important)

### Data Security:
✅ Passwords hashed (not stored as plain text)
✅ HTTPS encryption (all communications)
✅ Session tokens (secure & expiring)
✅ Email validation (confirms real email)

---

## Quick Reference

| Action | What Happens | User Sees |
|--------|--------------|-----------|
| Register | Email sent, account waiting | "Check Email" screen |
| Click verification link | Email marked verified | Confirmation page |
| Try login (unverified) | Login blocked | Error message |
| Try login (verified) | Login allowed | Home page |
| Click resend button | New email sent | "Email resent" message |
| Link expires (24h) | Must resend | Resend button available |

---

## Files Modified Summary

```
lib/
├── auth_service.dart         ← Added email verification logic
├── screens/
│   ├── login.dart            ← Updated error handling
│   └── register.dart         ← Added "Check Email" screen
└── main.dart                 ← Unchanged (credentials same)

docs/
├── EMAIL_VERIFICATION_GUIDE.md  ← Complete setup guide
├── QUICK_START.md               ← Updated with email steps
├── CHANGES_SUMMARY.md           ← Updated summary
└── EMAIL_VERIFICATION_FLOW.md   ← This file
```

---

## What User Needs to Do

1. **Configure Supabase**: Enable email verification (5 min)
2. **Add Credentials**: Copy URL & key to main.dart (1 min)
3. **Run App**: `flutter pub get && flutter run` (1 min)
4. **Test Registration**: Create account → get email → verify (5 min)
5. **Test Login**: Login with verified email (1 min)

**Total Time**: ~15 minutes setup ✅
