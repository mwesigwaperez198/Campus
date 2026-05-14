# 📐 App Architecture & Data Flow

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    CAMPUS CONNECT APP                       │
└─────────────────────────────────────────────────────────────┘
                              ↓
                    ┌─────────────────┐
                    │  Flutter UI     │
                    │                 │
                    │  - LoginPage    │
                    │  - RegisterPage │
                    │  - HomePage     │
                    │  - Feed/Chat    │
                    │  - Events       │
                    │  - Directory    │
                    └────────┬────────┘
                             ↓
                    ┌─────────────────┐
                    │ AuthService     │◄─── Singleton Pattern
                    │                 │     (only one instance)
                    │ - signUp()      │
                    │ - signIn()      │
                    │ - signOut()     │
                    └────────┬────────┘
                             ↓
                    ┌─────────────────┐
                    │  Supabase SDK   │
                    │                 │
                    │ Real-time Auth  │
                    └────────┬────────┘
                             ↓
              ┌──────────────────────────┐
              │                          │
              ▼                          ▼
    ┌──────────────────┐      ┌──────────────────┐
    │  Supabase Cloud  │      │  Auth Database   │
    │                  │      │                  │
    │ - Users table    │      │ - Email          │
    │ - Sessions       │      │ - Hashed password│
    │ - Auth tokens    │      │ - User ID        │
    └──────────────────┘      └──────────────────┘
```

---

## Authentication Flow Diagram

### Registration Flow:
```
User Enters Data          AuthService              Supabase
       ↓                      ↓                       ↓
  Email & Password            │                       │
  │                           │                       │
  ├─Validation (6+ chars)     │                       │
  │        │                  │                       │
  │        ├─→ signUp()       │                       │
  │        │        │         │                       │
  │        │        └────────→│ Create Auth User      │
  │        │                  │         │             │
  │        │                  │         └────────────→│
  │        │                  │  ← Email + Hash PWD   │
  │        │                  │ ← User ID created     │
  │        │                  │                       │
  │        └←─ Success        │                       │
  │                           │                       │
  └─→ Show Success Message    │                       │
      "Registration Complete" │                       │
      Return to Login         │                       │
```

### Login Flow:
```
User Enters Data          AuthService              Supabase
       ↓                      ↓                       ↓
  Email & Password            │                       │
  │                           │                       │
  ├─Basic Validation          │                       │
  │        │                  │                       │
  │        ├─→ signIn()       │                       │
  │        │        │         │                       │
  │        │        └────────→│ Verify Email & PWD    │
  │        │                  │         │             │
  │        │                  │         └────────────→│
  │        │                  │  ← Match Check        │
  │        │                  │                       │
  │        │ ← Success        │  ← Create Session     │
  │        │   + Session      │  ← Auth Token         │
  │        │   + Auth Token   │                       │
  │        │                  │                       │
  │        ├─ Credentials Match                       │
  │        │        │                                 │
  │        │        └─→ Save Session Token            │
  │        │                                          │
  │        └─ Redirect to Home/Feed                   │
  │                                                   │
  └─→ Show Home Page                                  │
```

### Failed Login Flow:
```
User Enters Data          AuthService              Supabase
       ↓                      ↓                       ↓
  Email & Password            │                       │
  │                           │                       │
  ├─→ signIn()               │                       │
  │        │         │        │                       │
  │        │         └───────→│ Verify Email & PWD    │
  │        │                  │         │             │
  │        │                  │ ✗ Wrong Password      │
  │        │                  │ ✗ User not found      │
  │        │                  │                       │
  │        │ ← Error          │ ← Auth Exception      │
  │        │ "Credentials     │                       │
  │        │  Don't Match"    │                       │
  │        │                  │                       │
  │        └─→ Show Error Message                     │
  │            "Login failed: credentials don't match"│
  │                                                   │
  └─→ Stay on Login Screen                            │
      User can try again                              │
```

---

## App State Management

```
    ┌─────────────────────────────────┐
    │    Supabase Auth State Stream    │
    │                                 │
    │  Emits: AuthState changes       │
    │  - User logged in               │
    │  - User logged out              │
    │  - Session expired              │
    │  - Auth error                   │
    └────────────────┬────────────────┘
                     │
                     ▼
    ┌─────────────────────────────────┐
    │   Main.dart StreamBuilder        │
    │                                 │
    │  Listens to Auth State          │
    │         │                       │
    │         ├─→ User Logged In      │
    │         │   └─ Show HomePage    │
    │         │       (Feed/Chat...)  │
    │         │                       │
    │         └─→ User Not Logged In  │
    │             └─ Show LoginPage   │
    └─────────────────────────────────┘
```

---

## File Structure

```
campus_connect/
├── lib/
│   ├── main.dart                 ← App initialization & routing
│   ├── auth_service.dart         ← Authentication logic (NEW!)
│   │
│   ├── screens/
│   │   ├── login.dart            ← Login UI + logic
│   │   └── register.dart         ← Registration UI + logic
│   │
│   └── pages/
│       └── splash.dart           ← Splash screen with "from Novara"
│
├── pubspec.yaml                  ← Dependencies (supabase_flutter)
├── QUICK_START.md               ← Setup instructions
├── SETUP_GUIDE.md               ← Detailed setup
└── CHANGES_SUMMARY.md           ← What was changed
```

---

## Data Models

### User (Supabase Auth)
```
User {
  id: UUID                    ← Generated by Supabase
  email: String              ← Login identifier
  password_hash: String      ← Encrypted (never exposed)
  email_confirmed_at: DateTime
  created_at: DateTime
  ...
}
```

### Session (Automatic)
```
Session {
  access_token: JWT          ← Identifies logged-in user
  refresh_token: JWT         ← Used to refresh access
  expires_in: Number         ← Token expiration time
  user_id: UUID              ← Links to User
}
```

---

## Credential Security

```
User Password: "MyPassword123"
        ↓
   HASHING FUNCTION (bcrypt)
        ↓
   Hash: "$2b$10$xyz..."  ← Never reversible!
        ↓
   STORED IN SUPABASE
        ↓
   
   On Login:
   User Password: "MyPassword123"
        ↓
   Hash & Compare
        ↓
   Match Stored Hash?
        ↓
   ✓ YES → Grant Access
   ✗ NO  → Deny Access
```

---

## Error Handling Flow

```
    User Action
        ↓
    Try Block
        │
        ├─→ Validation Passes
        │        ↓
        │   Supabase Call
        │        │
        │        ├─→ Success
        │        │    └─ Update UI + Navigate
        │        │
        │        └─→ Exception
        │             └─ Catch Block
        │                   ↓
        │            Extract Error Message
        │                   ↓
        │            Display to User
        │                   ↓
        │            Stay on Same Screen
        │
        └─→ Validation Fails
                 ↓
            Show Error Message
                 ↓
            Stay on Same Screen
```

---

## Instagram-Like Features Implementation

```
HOME (Feed Tab)
├── Posts List
│   ├── User Avatar
│   ├── User Name
│   ├── Post Content
│   └── Actions (Like/Comment/Share)
├── Sample Posts (placeholder)
└── Expandable in future

MESSAGES Tab
├── Conversation List
│   ├── User Avatar
│   ├── User Name
│   ├── Last Message Preview
│   └── Timestamp
└── Can tap to open chat

EVENTS Tab
├── Event Cards
│   ├── Event Name
│   ├── Date & Time
│   ├── Location
│   └── Register Button
└── Event Details on tap

DIRECTORY Tab
├── User List
│   ├── User Avatar
│   ├── User Name
│   ├── Department
│   └── View Profile on tap
└── Search (future enhancement)
```

This architecture ensures:
✅ Security (credentials encrypted)
✅ Scalability (cloud-based Supabase)
✅ Real-time (auth state updates)
✅ Error handling (comprehensive)
✅ User experience (smooth navigation)
