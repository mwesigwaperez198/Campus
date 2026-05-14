# Campus Connect - Email Verification Setup Guide

## 🔐 Email Verification Authentication

Your app now uses **Email Verification** for user registration. This is more secure than instant login.

---

## How Email Verification Works

### 1️⃣ Registration Process
```
User fills in form
    ↓
Click "REGISTER"
    ↓
Account created in Supabase
    ↓
Verification email sent to user's inbox
    ↓
User sees "Check Your Email" screen
    ↓
User clicks link in email
    ↓
Email verified ✓
```

### 2️⃣ Login Process
```
User enters credentials
    ↓
System checks email is verified
    ↓
Email verified? 
    ├─ YES → Login successful → Home page
    └─ NO → Show error: "Please verify your email first"
```

---

## ⚙️ REQUIRED Supabase Setup

### Step 1: Enable Email Authentication & Verification

1. Go to https://supabase.com/dashboard
2. Select your project
3. Click **Authentication** in left sidebar
4. Click **Providers** tab
5. Find **Email** and toggle it ON
6. Scroll down to **Email Confirmation** section
7. Toggle **"Require email confirmation"** to ON
8. Click **Save**

### Step 2: Configure Email Provider

1. Still in Authentication settings, click the **Email** provider
2. You'll see two options:
   - **Supabase (free)** - Limited emails/day but instant setup
   - **Custom SMTP** - Unlimited but requires email service

3. **For testing**: Use Supabase free tier
4. **For production**: Use SendGrid, Gmail, or other SMTP service

### Step 3: Set Redirect URL

1. In Authentication → Email Provider
2. Look for **Redirect URL** or **Allowed Redirect URLs**
3. Add your app's deep link:
   ```
   campus.connect://verify
   ```
4. Save

### Step 4: Get Your Credentials

1. Click **Project Settings** (gear icon)
2. Click **API**
3. Copy **Project URL** and **anon public key**
4. Add to `lib/main.dart`:
   ```dart
   await Supabase.initialize(
     url: 'YOUR_SUPABASE_URL',           // Paste here
     anonKey: 'YOUR_SUPABASE_ANON_KEY',  // Paste here
   );
   ```

---

## 📱 User Flow - Testing Email Verification

### Step 1: Register New Account
1. Open app → Splash screen appears
2. After 4 seconds → Login screen
3. Click **"CREATE ACCOUNT"**
4. Fill in form:
   - Email: `test@gmail.com`
   - Password: `Test@123456`
   - Confirm: `Test@123456`
5. Click **"REGISTER"**
6. See **"Check Your Email"** screen

### Step 2: Verify Email
1. Open your email inbox (Gmail, etc.)
2. Look for email from Supabase
3. Subject: *"Confirm your signup"* or similar
4. **Click the verification link** in the email
5. Browser opens → Email is now verified ✓

### Step 3: Login
1. Go back to the app
2. Click **"Back to Login"**
3. Enter credentials:
   - Email: `test@gmail.com`
   - Password: `Test@123456`
4. Click **"LOG IN"**
5. **Should redirect to Home page** ✓

### Step 4: Test Failed Login (Unverified Email)
1. Click "CREATE ACCOUNT" again
2. Use new email: `test2@gmail.com`
3. Register → See "Check Your Email"
4. **DON'T click the verification link**
5. Go back to login
6. Try to login with `test2@gmail.com`
7. **Should show error**: "📧 Please verify your email first"

---

## 📧 Email Content

### Registration Email (from Supabase)
```
Subject: Confirm your signup

You've signed up for Campus Connect.

Click the link below to confirm your email:
[VERIFY EMAIL LINK]

This link expires in 24 hours.
```

### What User Needs to Do
1. Open the email
2. Click the verification link
3. Should see confirmation page
4. Can now login to the app

---

## ✅ Features Implemented

| Feature | Status | Details |
|---------|--------|---------|
| Email verification required | ✅ | Must verify before login |
| Verification email sent | ✅ | Automatic via Supabase |
| Resend email button | ✅ | If user missed first email |
| Clear error messages | ✅ | Shows what's needed |
| Verification status check | ✅ | Checked on every login |
| Email confirmation screen | ✅ | After registration |

---

## 🔄 User Can Resend Verification Email

If user doesn't receive the email:
1. On "Check Your Email" screen
2. Click **"RESEND VERIFICATION EMAIL"** button
3. New email sent to their inbox
4. They can click the new link

---

## 🚨 Common Issues & Solutions

### Issue: "No email received after registration"
**Solutions**:
1. Check spam/junk folder in email
2. Verify email address is spelled correctly
3. Click "RESEND VERIFICATION EMAIL" button in app
4. Check Supabase Auth Settings → Ensure email provider is configured

### Issue: Verification link doesn't work
**Solution**:
1. Check if link has expired (24 hours max)
2. Click "RESEND VERIFICATION EMAIL" in app
3. Use the new link sent

### Issue: "Email already exists" error
**Solution**:
1. Use a different email address
2. Or if you own the account:
   - Check your verified email list
   - Register with same email again (will add to existing account)

### Issue: Can't login even after verifying
**Solution**:
1. Wait 10 seconds for Supabase to update
2. Try logging in again
3. Check Supabase Dashboard → Authentication → Users
4. Verify `email_confirmed_at` has a date

### Issue: "Deep link not configured"
**Solution**:
1. This is optional - app still works
2. Email verification link will open browser
3. User will see confirmation page in browser
4. Can then return to app to login

---

## 📋 Supabase Email Settings Checklist

- [ ] Email provider enabled
- [ ] "Require email confirmation" toggled ON
- [ ] Email from address configured
- [ ] Redirect URL added (`campus.connect://verify`)
- [ ] Project URL copied to main.dart
- [ ] Anon key copied to main.dart
- [ ] Tested registration → email received
- [ ] Tested verification → link works
- [ ] Tested login → verified user can login
- [ ] Tested unverified login → shows error

---

## 🔒 Security Benefits

✅ **Email Verification ensures**:
- User owns the email address
- Reduces spam accounts
- Real university email only (if required)
- Can add college domain restriction later
- Recovery option if password forgotten

---

## 🎯 Next Steps

1. Set up Supabase email provider (free tier works)
2. Copy credentials to `lib/main.dart`
3. Run: `flutter pub get && flutter run`
4. Test registration → verification → login
5. All working? You're ready! 🚀

---

## 📞 Need Help?

Check these files:
- `QUICK_START.md` - Fast setup overview
- `ARCHITECTURE.md` - How email verification works
- `lib/auth_service.dart` - Email verification code
- `lib/screens/register.dart` - Registration UI with verification screen
