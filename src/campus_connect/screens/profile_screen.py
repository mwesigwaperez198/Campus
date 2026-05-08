import toga
from toga.style import Pack
from toga.style.pack import COLUMN, ROW, CENTER, BOLD, START, END

class ProfileScreen:
    def __init__(self, db, main_window, on_logout):
        self.db = db
        self.main_window = main_window
        self.on_logout = on_logout
        self.container = toga.ScrollContainer(horizontal=False, style=Pack(flex=1, background_color='white'))

        # Safe initialization without 'children='
        loading_box = toga.Box(style=Pack(padding=20))
        loading_box.add(toga.Label("Loading Profile..."))
        self.container.content = loading_box

        try:
            self.refresh()
        except Exception as e:
            print(f"Profile Load Error: {e}")
            err_box = toga.Box(style=Pack(padding=20))
            err_box.add(toga.Label("Error loading profile details."))
            self.container.content = err_box

    def refresh(self):
        if not self.db.current_user:
            no_session = toga.Box(style=Pack(padding=20))
            no_session.add(toga.Label("No active session."))
            self.container.content = no_session
            return

        user = self.db.current_user
        main_box = toga.Box(style=Pack(direction=COLUMN))

        # 1. Profile Header
        header = toga.Box(style=Pack(direction=ROW, padding=20, align_items=CENTER))
        avatar_outer = toga.Box(style=Pack(width=90, height=90, background_color='#BA0C2F', padding=2))
        avatar_inner = toga.Box(style=Pack(flex=1, background_color='#EDF2F7', justify_content=CENTER, align_items=CENTER))
        avatar_inner.add(toga.Label("👤", style=Pack(font_size=40)))
        avatar_outer.add(avatar_inner)

        stats_box = toga.Box(style=Pack(direction=ROW, flex=1, justify_content=CENTER, padding_left=20))
        for val, label in [("12", "Posts"), ("1.2k", "Followers"), ("450", "Following")]:
            s_box = toga.Box(style=Pack(direction=COLUMN, align_items=CENTER, margin_right=20))
            s_box.add(toga.Label(val, style=Pack(font_weight=BOLD, font_size=14)))
            s_box.add(toga.Label(label, style=Pack(font_size=10, color='grey')))
            stats_box.add(s_box)

        header.add(avatar_outer)
        header.add(stats_box)
        main_box.add(header)

        # 2. Bio Section
        bio_box = toga.Box(style=Pack(direction=COLUMN, padding_left=20, padding_right=20))
        bio_box.add(toga.Label(str(user.full_name), style=Pack(font_weight=BOLD, font_size=14)))
        bio_box.add(toga.Label(f"🎓 {user.role.value.capitalize()} | {user.institution}", style=Pack(font_size=11, color='#4A5568')))
        bio_box.add(toga.Label("Building for the future. 🏗️✨", style=Pack(font_size=11, margin_top=5)))
        main_box.add(bio_box)

        # 3. Logout
        logout_btn = toga.Button(
            "Logout from Makerere",
            on_press=lambda x: self.on_logout(),
            style=Pack(margin=20, background_color='#BA0C2F', color='white', font_weight=BOLD)
        )
        main_box.add(logout_btn)

        self.container.content = main_box
