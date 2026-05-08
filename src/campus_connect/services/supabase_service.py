import os
from supabase import create_client, Client
from ..models.models import SessionUser, FeedPost, CampusGroup, CampusEvent, CampusStatus, UserRole

class SupabaseService:
    def __init__(self):
        self.url = "https://yderyptbjhzkaalxhbpa.supabase.co"
        self.key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlkZXJ5cHRiamh6a2FhbHhoYnBhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUwNzY2OTgsImV4cCI6MjA5MDY1MjY5OH0.JeFvuTSbUP4KfGSfB3sG3fDUGMCWP6isAaOskfDN3a8"
        self.client = None
        try:
            self.client = create_client(self.url, self.key)
        except Exception as e:
            print(f"Supabase Initialization Error: {e}")
        self.current_user = None

    def sign_in(self, email, password):
        if not self.client: return None
        try:
            clean_email = email.strip()
            clean_pass = password.strip()
            res = None
            try:
                res = self.client.auth.sign_in_with_password({"email": clean_email, "password": clean_pass})
            except TypeError:
                res = self.client.auth.sign_in_with_password(email=clean_email, password=clean_pass)

            if not res or not res.user: return None

            # Profile Fetch
            try:
                p_res = self.client.from_('profiles').select('*').eq('id', res.user.id).single().execute()
                if p_res and p_res.data:
                    self.current_user = SessionUser.from_json(p_res.data)
                    return self.current_user
            except: pass

            meta = getattr(res.user, 'user_metadata', {}) or {}
            self.current_user = SessionUser(
                id=res.user.id,
                email=clean_email,
                full_name=str(meta.get('full_name', 'Makerere User')),
                role=UserRole.STUDENT
            )
            return self.current_user
        except: return None

    async def sign_up(self, email, password, full_name, role):
        if not self.client: return "DB Not Initialized"
        try:
            params = {
                "email": email.strip(),
                "password": password.strip(),
                "options": {"data": {"full_name": full_name, "role": role.value}}
            }
            try:
                res = self.client.auth.sign_up(params)
            except TypeError:
                res = self.client.auth.sign_up(
                    email=params["email"],
                    password=params["password"],
                    options=params["options"]
                )

            if res and res.user:
                return True
            return "Registration failed"
        except Exception as e:
            msg = str(e)
            if "already registered" in msg.lower(): return "EXISTS"
            return msg

    def get_feed(self, limit=10):
        try:
            res = self.client.from_('posts').select('*, profiles(full_name, avatar_url)').order('created_at', desc=True).limit(limit).execute()
            return [FeedPost.from_json(p) for p in res.data] if res and res.data else []
        except: return []

    def get_groups(self):
        try:
            res = self.client.from_('groups').select('*').execute()
            return [CampusGroup.from_json(g) for g in res.data] if res and res.data else []
        except: return []

    def get_upcoming_events(self, limit=5):
        try:
            res = self.client.from_('events').select('*').limit(limit).execute()
            return [CampusEvent.from_json(e) for e in res.data] if res and res.data else []
        except: return []

    def get_statuses(self):
        try:
            res = self.client.from_('statuses').select('*, profiles(full_name, avatar_url)').execute()
            return [CampusStatus.from_json(s) for s in res.data] if res and res.data else []
        except: return []
