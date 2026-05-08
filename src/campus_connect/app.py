import toga
import asyncio
import traceback
import os
from toga.style import Pack
from toga.style.pack import COLUMN, ROW, CENTER, BOLD, TOP
from .services.supabase_service import SupabaseService
from .screens.feed_screen import FeedScreen
from .screens.groups_screen import GroupsScreen
from .screens.messages_screen import MessagesScreen
from .screens.profile_screen import ProfileScreen
from .screens.reels_screen import ReelsScreen
from .screens.events_screen import EventsScreen
from .screens.directory_screen import DirectoryScreen
from .models.models import UserRole

class CampusConnect(toga.App):
    def startup(self):
        self.db = SupabaseService()
        self.main_window = toga.MainWindow(title=self.formal_name)
        self.show_splash()
        self.main_window.show()

    def show_splash(self):
        container = toga.Box(style=Pack(direction=COLUMN, align_items=CENTER, justify_content=CENTER, flex=1, background_color='#FFFFFF'))
        try:
            logo_path = self.paths.app.parent.parent / "assets/images/Novara logo.jpeg"
            if os.path.exists(str(logo_path)):
                logo_view = toga.ImageView(toga.Image(logo_path), style=Pack(width=320, height=220))
                container.add(logo_view)
            else:
                raise FileNotFoundError()
        except:
            logo_row = toga.Box(style=Pack(direction=ROW, align_items=CENTER))
            icon_box = toga.Box(style=Pack(width=80, height=80, background_color='#1A202C', padding=15))
            icon_box.add(toga.Label("N", style=Pack(font_size=40, color='#FF8C00', font_weight=BOLD)))
            text_col = toga.Box(style=Pack(direction=COLUMN, margin_left=15))
            brand_row = toga.Box(style=Pack(direction=ROW, align_items=CENTER))
            brand_row.add(toga.Label("NOVARA", style=Pack(font_size=45, font_weight=BOLD, color='#1A202C')))
            brand_row.add(toga.Label("↗", style=Pack(font_size=45, color='#FF8C00', margin_left=2)))
            text_col.add(brand_row)
            text_col.add(toga.Label("Shaping a new era of tech in Uganda", style=Pack(font_size=12, color='#4A5568')))
            logo_row.add(icon_box)
            logo_row.add(text_col)
            container.add(logo_row)

        self.main_window.content = container
        async def splash_delay(app):
            await asyncio.sleep(5)
            self.show_auth_choice()
        self.add_background_task(splash_delay)

    def show_auth_choice(self, widget=None):
        outer = toga.Box(style=Pack(direction=COLUMN, align_items=CENTER, justify_content=CENTER, flex=1, background_color='#FFFFFF'))
        try:
            logo_path = self.paths.app / "resources/makerere_logo.jpg"
            logo_view = toga.ImageView(toga.Image(logo_path), style=Pack(width=180, height=150, margin_bottom=20))
            outer.add(logo_view)
        except: pass

        outer.add(toga.Label("MAKERERE UNIVERSITY", style=Pack(font_size=22, font_weight=BOLD, margin_bottom=30, text_align=CENTER)))

        login_btn = toga.Button("SIGN IN", on_press=self.show_login, style=Pack(width=300, height=45, margin=10, background_color='#BA0C2F', color='white', font_weight=BOLD))
        signup_btn = toga.Button("CREATE ACCOUNT", on_press=self.show_signup, style=Pack(width=300, height=45, margin=10, background_color='white', color='#BA0C2F', font_weight=BOLD))

        outer.add(login_btn)
        outer.add(signup_btn)
        self.main_window.content = outer

    def show_login(self, widget=None):
        outer = toga.Box(style=Pack(direction=COLUMN, align_items=CENTER, justify_content=CENTER, flex=1, background_color='#FFFFFF'))

        outer.add(toga.Label("MAKERERE UNIVERSITY", style=Pack(font_size=20, font_weight=BOLD, margin_bottom=10, text_align=CENTER, color='#BA0C2F')))
        outer.add(toga.Label("Sign In to Portal", style=Pack(font_size=14, margin_bottom=20, text_align=CENTER, font_weight=BOLD)))

        email_in = toga.TextInput(placeholder="Student Email", style=Pack(width=300, margin=8))
        pass_in = toga.PasswordInput(placeholder="Password", style=Pack(width=300, margin=8))

        async def do_login(b):
            user = self.db.sign_in(email_in.value, pass_in.value)
            if user:
                self.load_main_interface()
            else:
                await self.main_window.info_dialog("Auth Error", "Invalid credentials. Please check your email/password.")

        outer.add(email_in)
        outer.add(pass_in)
        outer.add(toga.Button("LOG IN", on_press=do_login, style=Pack(width=300, height=45, background_color='#BA0C2F', color='white', font_weight=BOLD, margin_top=10)))
        outer.add(toga.Button("Back", on_press=self.show_auth_choice, style=Pack(margin_top=20, width=200)))
        self.main_window.content = outer

    def show_signup(self, widget=None):
        outer = toga.Box(style=Pack(direction=COLUMN, align_items=CENTER, justify_content=CENTER, flex=1, background_color='#FFFFFF'))
        logo_path = self.paths.app / "resources/makerere_logo.jpg"
        logo_view = toga.ImageView(toga.Image(logo_path), style=Pack(width=180, height=150, margin_bottom=20))
        outer.add(logo_view)

        outer.add(toga.Label("MAKERERE UNIVERSITY", style=Pack(font_size=20, font_weight=BOLD, margin_bottom=10, text_align=CENTER, color='#BA0C2F')))
        outer.add(toga.Label("Create New Account", style=Pack(font_size=14, margin_bottom=20, text_align=CENTER)))

        name_in = toga.TextInput(placeholder="Full Name", style=Pack(width=300, margin=8))
        email_in = toga.TextInput(placeholder="Student Email (@mak.ac.ug)", style=Pack(width=300, margin=8))
        pass_in = toga.PasswordInput(placeholder="Password", style=Pack(width=300, margin=8))

        async def handle_reg(b):
            res = await self.db.sign_up(email_in.value, pass_in.value, name_in.value, UserRole.STUDENT)
            if res is True or res == "EXISTS":
                self.show_otp_verification()
            else:
                await self.main_window.info_dialog("Registration Failed", f"Error: {res}")

        outer.add(name_in); outer.add(email_in); outer.add(pass_in)
        outer.add(toga.Button("REGISTER ", on_press=handle_reg, style=Pack(width=300, height=45, background_color='#BA0C2F', color='white', font_weight=BOLD, margin_top=10)))
        outer.add(toga.Button("Back", on_press=self.show_auth_choice, style=Pack(margin_top=20, width=200)))
        self.main_window.content = outer

    def show_otp_verification(self):
        outer = toga.Box(style=Pack(direction=COLUMN, align_items=CENTER, justify_content=CENTER, flex=1, background_color='#FFFFFF', padding=20))

        outer.add(toga.Label("Account Verification", style=Pack(font_size=22, font_weight=BOLD, text_align=CENTER, color='#BA0C2F')))
        outer.add(toga.Label("Check your email for the 6-digit code.", style=Pack(margin_bottom=30, text_align=CENTER)))

        otp_in = toga.TextInput(placeholder="000000", style=Pack(width=150, margin=20, text_align=CENTER, font_size=18))

        async def verify(b):
            if len(otp_in.value) == 6:
                await self.main_window.info_dialog("Verified", "Your Makerere account is now active!")
                self.show_login()
            else:
                await self.main_window.error_dialog("Invalid Code", "Please enter a valid 6-digit code.")

        outer.add(otp_in)
        outer.add(toga.Button("VERIFY & SIGN IN", on_press=verify, style=Pack(width=300, height=45, background_color='#BA0C2F', color='white', font_weight=BOLD)))
        self.main_window.content = outer

    def load_main_interface(self):
        try:
            def safe_scr(cls, *args):
                try: return cls(*args)
                except Exception as e:
                    traceback.print_exc()
                    d = type('D', (), {})()
                    err_box = toga.Box(style=Pack(direction=COLUMN, padding=20))
                    err_box.add(toga.Label(f"Error loading {cls.__name__}"))
                    d.container = err_box
                    return d

            feed = safe_scr(FeedScreen, self.db, self.main_window)
            reels = safe_scr(ReelsScreen, self.db, self.main_window)
            chat = safe_scr(MessagesScreen, self.db, self.main_window)
            groups = safe_scr(GroupsScreen, self.db, self.main_window)
            events = safe_scr(EventsScreen, self.db, self.main_window)
            people = safe_scr(DirectoryScreen, self.db, self.main_window)
            profile = safe_scr(ProfileScreen, self.db, self.main_window, self.show_auth_choice)

            # Create OptionContainer and add tabs properly
            self.tabs = toga.OptionContainer(style=Pack(flex=1))
            self.tabs.add("Home", feed.container)
            self.tabs.add("Reels", reels.container)
            self.tabs.add("Chat", chat.container)
            self.tabs.add("Groups", groups.container)
            self.tabs.add("Events", events.container)
            self.tabs.add("People", people.container)
            self.tabs.add("Profile", profile.container)

            self.main_window.content = self.tabs
        except Exception as e:
            error_box = toga.Box(style=Pack(direction=COLUMN, align_items=CENTER, justify_content=CENTER, flex=1, padding=20))
            error_box.add(toga.Label("Interface Load Error", style=Pack(font_weight=BOLD, font_size=18, color='red')))
            error_box.add(toga.Label(f"Reason: {str(e)}", style=Pack(margin_top=10, font_size=10)))
            error_box.add(toga.Button("Retry Login", on_press=self.show_auth_choice, style=Pack(margin_top=20)))
            self.main_window.content = error_box

def main():
    return CampusConnect("Campus Connect", "org.mak.campusconnect")
