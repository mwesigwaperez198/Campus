import toga
from toga.style import Pack
from toga.style.pack import COLUMN, ROW, CENTER, BOLD, START, END

class MessagesScreen:
    def __init__(self, db, main_window):
        self.db = db
        self.main_window = main_window
        self.container = toga.Box(style=Pack(direction=COLUMN, flex=1, background_color='white'))
        self.create_ui()

    def create_ui(self):
        # 1. Instagram-style Direct Header
        header = toga.Box(style=Pack(direction=ROW, padding=10, align_items=CENTER))

        back_btn = toga.Label("＜", style=Pack(font_size=20, margin_right=15))

        user_name = "Messages"
        if self.db.current_user:
            try:
                raw_name = str(self.db.current_user.full_name)
                user_name = (raw_name.split()[0].lower() if raw_name else "user") + " ⌵"
            except:
                user_name = "messages ⌵"

        title = toga.Label(user_name, style=Pack(font_size=18, font_weight=BOLD, flex=1))

        video_icon = toga.Label("📹", style=Pack(font_size=20, margin_right=15))
        new_msg_icon = toga.Label("📝", style=Pack(font_size=20))

        header.add(back_btn)
        header.add(title)
        header.add(video_icon)
        header.add(new_msg_icon)
        self.container.add(header)

        # 2. Search Bar
        search_box = toga.Box(style=Pack(padding=10))
        search_input = toga.TextInput(placeholder="Search", style=Pack(flex=1, background_color='#EFEFEF'))
        search_box.add(search_input)
        self.container.add(search_box)

        # 3. Horizontal Stories/Active Users
        active_scroll = toga.ScrollContainer(vertical=False, style=Pack(height=100))
        active_box = toga.Box(style=Pack(direction=ROW, padding=10))

        people = self.db.search_content("")
        for p in people[:6]:
            u_box = toga.Box(style=Pack(direction=COLUMN, align_items=CENTER, margin_right=15))
            circle = toga.Box(style=Pack(width=55, height=55, background_color='#EDF2F7', padding=2))
            inner = toga.Box(style=Pack(flex=1, background_color='white'))
            inner.add(toga.Label("👤", style=Pack(font_size=20, text_align=CENTER, margin_top=15)))
            circle.add(inner)

            # Active green dot
            dot = toga.Box(style=Pack(width=12, height=12, background_color='#4CAF50', margin_top=-15, margin_left=40))

            try:
                display_name = str(p.full_name).split()[0]
            except:
                display_name = "User"

            name = toga.Label(display_name, style=Pack(font_size=9, margin_top=5))
            u_box.add(circle)
            u_box.add(dot)
            u_box.add(name)
            active_box.add(u_box)

        active_scroll.content = active_box
        self.container.add(active_scroll)

        # 4. Chat List
        self.scroll = toga.ScrollContainer(horizontal=False, style=Pack(flex=1))
        self.chat_box = toga.Box(style=Pack(direction=COLUMN))
        self.scroll.content = self.chat_box
        self.container.add(self.scroll)

        self.refresh_messages()

    def refresh_messages(self):
        self.chat_box.clear()
        people = self.db.search_content("")

        for p in people:
            if self.db.current_user and p.id == self.db.current_user.id:
                continue

            row = toga.Box(style=Pack(direction=ROW, padding=12, align_items=CENTER))

            avatar = toga.Box(style=Pack(width=55, height=55, background_color='#EDF2F7', padding=1, margin_right=15))
            avatar.add(toga.Label("👤", style=Pack(font_size=25, text_align=CENTER, margin_top=12)))

            info = toga.Box(style=Pack(direction=COLUMN, flex=1))
            name = toga.Label(str(p.full_name), style=Pack(font_weight=BOLD, font_size=12))
            last_msg = toga.Label("Sent a message • 2h", style=Pack(font_size=11, color='grey'))
            info.add(name)
            info.add(last_msg)

            camera = toga.Label("📷", style=Pack(font_size=18, color='grey'))

            row.add(avatar)
            row.add(info)
            row.add(camera)
            self.chat_box.add(row)
