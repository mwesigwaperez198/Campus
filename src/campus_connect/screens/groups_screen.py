import toga
from toga.style import Pack
from toga.style.pack import COLUMN, ROW, CENTER, BOLD, START

class GroupsScreen:
    def __init__(self, db, main_window):
        self.db = db
        self.main_window = main_window
        self.container = toga.Box(style=Pack(direction=COLUMN, flex=1, background_color='#F0F2F5'))
        self.create_ui()

    def create_ui(self):
        # Header
        header = toga.Box(style=Pack(direction=ROW, padding=15, align_items=CENTER, background_color='white'))
        title = toga.Label("Communities", style=Pack(font_size=20, font_weight=BOLD, flex=1, color='#BA0C2F'))
        add_btn = toga.Button("+ Create", on_press=self.show_create_group, style=Pack(width=100, background_color='#BA0C2F', color='white'))

        header.add(title)
        header.add(add_btn)

        # Groups List
        self.scroll = toga.ScrollContainer(horizontal=False, style=Pack(flex=1))
        self.content_box = toga.Box(style=Pack(direction=COLUMN, padding=10))
        self.scroll.content = self.content_box

        self.container.add(header)
        self.container.add(self.scroll)
        self.refresh_groups()

    def refresh_groups(self):
        # Safe clear for all Toga versions
        while len(self.content_box.children) > 0:
            self.content_box.remove(self.content_box.children[0])

        groups = self.db.get_groups()

        if not groups:
            no_data = toga.Box(style=Pack(direction=COLUMN, align_items=CENTER, padding=50))
            no_data.add(toga.Label("No groups found yet.", style=Pack(color='grey')))
            self.content_box.add(no_data)
            return

        for g in groups:
            card = toga.Box(style=Pack(direction=ROW, padding=12, background_color='white', margin_bottom=5, align_items=CENTER))

            avatar = toga.Box(style=Pack(width=50, height=50, background_color='#EDF2F7', padding=10, margin_right=15))
            avatar.add(toga.Label("👥", style=Pack(font_size=20)))

            info = toga.Box(style=Pack(direction=COLUMN, flex=1))
            info.add(toga.Label(str(g.name), style=Pack(font_weight=BOLD, font_size=12)))
            info.add(toga.Label(f"Focus: {g.focus or 'General'}", style=Pack(font_size=10, color='grey')))

            card.add(avatar)
            card.add(info)
            card.add(toga.Button("Join", style=Pack(width=70)))
            self.content_box.add(card)

    def show_create_group(self, widget):
        self.main_window.info_dialog("Communities", "Group creation coming soon!")
