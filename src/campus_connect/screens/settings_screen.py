import toga
from toga.style import Pack
from toga.style.pack import COLUMN, ROW, CENTER, BOLD

class SettingsScreen:
    def __init__(self, db, main_window, on_logout):
        self.db = db
        self.main_window = main_window
        self.on_logout = on_logout
        self.container = toga.ScrollContainer(horizontal=False, style=Pack(flex=1, background_color='white'))
        self.refresh()

    def refresh(self):
        content = toga.Box(style=Pack(direction=COLUMN, padding=20))

        # 1. Profile / Account Settings
        content.add(toga.Label("Account Settings", style=Pack(font_size=18, font_weight=BOLD, margin_bottom=15)))

        profile_box = toga.Box(style=Pack(direction=ROW, align_items=CENTER, margin_bottom=20))
        profile_box.add(toga.Label("👤", style=Pack(font_size=40, margin_right=15)))

        edit_profile_btn = toga.Button("Update Profile Picture", style=Pack(flex=1))
        profile_box.add(edit_profile_btn)
        content.add(profile_box)

        # 2. Information Fields
        fields = [
            ("Full Name", self.db.current_user.full_name if self.db.current_user else ""),
            ("Email", self.db.current_user.email if self.db.current_user else ""),
            ("Phone", "+256 ..."),
            ("Location", "Makerere University, Kampala"),
            ("About", "Proudly Building for the Future at Makerere.")
        ]

        for label, val in fields:
            f_box = toga.Box(style=Pack(direction=COLUMN, margin_bottom=10))
            f_box.add(toga.Label(label, style=Pack(font_size=10, color='grey')))
            f_box.add(toga.TextInput(value=val, style=Pack(margin_top=5)))
            content.add(f_box)

        content.add(toga.Button("Save Changes", style=Pack(margin_top=10, background_color='#004AAD', color='white')))

        # 3. App Settings
        content.add(toga.Label("App Settings", style=Pack(font_size=18, font_weight=BOLD, margin_top=30, margin_bottom=15)))

        app_opts = ["Notifications", "Privacy", "Security", "Help & Support"]
        for opt in app_opts:
            row = toga.Box(style=Pack(direction=ROW, padding=10, background_color='#F5F5F5', margin_bottom=5))
            row.add(toga.Label(opt, style=Pack(flex=1)))
            row.add(toga.Label("⚙️"))
            content.add(row)

        logout_btn = toga.Button(
            "Log Out",
            on_press=lambda x: self.on_logout(),
            style=Pack(margin_top=30, color='red')
        )
        content.add(logout_btn)

        self.container.content = content
