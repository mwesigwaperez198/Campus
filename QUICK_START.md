# 🔧 Quick Start - Email Verification Setup (3 Steps)

## Step 1️⃣: Configure Supabase Email Verification (3 minutes)

### Go to https://supabase.com/dashboard

**Create Account** (if needed):
- Sign up with GitHub, Google, or email
- Create a new project

**Enable Email Verification**:
1. Click **Authentication** in left sidebar
2. Click **Providers** tab
3. Find **Email** → Toggle **ON**
4. Scroll to **Email Confirmation**
5. Toggle **"Require email confirmation"** → **ON**
6. Click **Save**

**Get Your Credentials**:
1. Click ⚙️ **Project Settings** (bottom left)
2. Click **API** in left sidebar
3. Copy:
   - 📋 **Project URL**
   - 🔑 **anon public** key

---

## Step 2️⃣: Add Credentials to Code (1 minute)

### Open: `lib/main.dart`

Find lines 11-14:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',           // ← PASTE HERE
  anonKey: 'YOUR_SUPABASE_ANON_KEY',  // ← PASTE HERE
);
```

Replace with your credentials:
```dart
await Supabase.initialize(
  url: 'https://your-project.supabase.co',        // Example
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...', // Example
);
```

**Save!** ✅

---

## Step 3️⃣: Run Your App (1 minute)

Open terminal:
```bash
flutter pub get
flutter run
```

---

## 🎉 Test Email Verification

### Registration Test:
1. App opens → Splash screen
2. Click **"CREATE ACCOUNT"**
3. Enter email & password
4. Click **"REGISTER"**
5. See **"Check Your Email"** screen ✓
6. Check your email inbox
7. Click **verification link** from Supabase
8. Email verified ✓

### Login Test:
1. Go back to app
2. Click **"Back to Login"**
3. Enter your credentials
4. Click **"LOG IN"**
5. Should redirect to **Home/Feed** ✓

### Test Unverified Login:
1. Register new account (don't verify)
2. Go back to login
3. Try to login
4. Should see: **"📧 Please verify your email first"** ✓

---

## ✅ What's Working Now

| Feature | Status |
|---------|--------|
| Registration with email | ✅ |
| Verification email sent | ✅ |
| Email verification required | ✅ |
| Login after verification | ✅ |
| Error on unverified login | ✅ |
| Resend verification email | ✅ |
| Feed/Messages/Events/Directory | ✅ |

---

## 📧 Email Verification Flow

```
Register → Email Sent → Verify Email → Login → Home
```

1. **Register**: Create account with email
2. **Email Sent**: Supabase sends verification email
3. **Verify**: Click link in email to verify
4. **Login**: Use verified email to login
5. **Home**: Access feed, messages, events, etc.

---

## 🚨 If Email Not Received

On the "Check Your Email" screen:
- Click **"RESEND VERIFICATION EMAIL"**
- Check spam/junk folder
- Verify email address spelling

---

## 📚 More Details

Full guides available:
- `EMAIL_VERIFICATION_GUIDE.md` - Detailed setup
- `ARCHITECTURE.md` - How it works
- `SETUP_GUIDE.md` - Additional options

---

## 🎯 You're All Set! 🚀

Once you add Supabase credentials and configure email verification, your app is ready with secure authentication.

