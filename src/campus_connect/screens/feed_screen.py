import toga
from toga.style import Pack
from toga.style.pack import COLUMN, ROW, CENTER, BOLD, START, END, TOP

class FeedScreen:
    def __init__(self, db, main_window):
        self.db = db
        self.main_window = main_window
        self.container = toga.ScrollContainer(horizontal=False, style=Pack(flex=1, background_color='#FAFAFA'))
        try:
            self.refresh()
        except Exception as e:
            print(f"Feed Init Error: {e}")
            err_box = toga.Box(style=Pack(padding=20))
            err_box.add(toga.Label("Feed failed to load. Check console for details."))
            self.container.content = err_box

    def refresh(self):
        main_box = toga.Box(style=Pack(direction=COLUMN))

        # Header with Safe Logo Loading
        header = toga.Box(style=Pack(direction=ROW, align_items=CENTER, padding=10, background_color='white'))
        try:
            logo_path = self.main_window.app.paths.app / "resources/makerere_logo.jpg"
            logo_view = toga.ImageView(toga.Image(logo_path), style=Pack(width=40, height=32, margin_right=10))
            header.add(logo_view)
        except:
            placeholder = toga.Box(style=Pack(width=40, height=32, background_color='#BA0C2F', margin_right=10))
            header.add(placeholder)

        header.add(toga.Label("CampusConnect", style=Pack(font_size=20, font_weight=BOLD, color='#1A365D', flex=1)))
        main_box.add(header)

        # Stories Bar
        stories_scroll = toga.ScrollContainer(vertical=False, style=Pack(height=110, background_color='white', margin_bottom=1))
        stories_box = toga.Box(style=Pack(direction=ROW, padding=10))

        try:
            statuses = self.db.get_statuses()
            for status in statuses:
                s_item = toga.Box(style=Pack(direction=COLUMN, align_items=CENTER, margin_right=15))
                circle = toga.Box(style=Pack(width=60, height=60, background_color='#F6AD55', padding=2))
                inner = toga.Box(style=Pack(flex=1, background_color='white', justify_content=CENTER, align_items=CENTER))
                inner.add(toga.Label("👤", style=Pack(font_size=25)))
                circle.add(inner)

                display_name = (status.full_name.split()[0] if status.full_name else "user").lower()
                s_item.add(circle)
                s_item.add(toga.Label(display_name, style=Pack(font_size=9, margin_top=5)))
                stories_box.add(s_item)
        except: pass

        stories_scroll.content = stories_box
        main_box.add(stories_scroll)

        # Post Cards
        content_box = toga.Box(style=Pack(direction=COLUMN, padding=10))
        try:
            posts = self.db.get_feed()
            for post in posts:
                card = toga.Box(style=Pack(direction=COLUMN, background_color='white', margin_bottom=15))
                p_header = toga.Box(style=Pack(direction=ROW, align_items=CENTER, padding=10))
                p_header.add(toga.Label("👤", style=Pack(font_size=20, margin_right=10)))
                p_header.add(toga.Label(str(post.author_name), style=Pack(font_weight=BOLD, font_size=12)))
                card.add(p_header)
                card.add(toga.Label(str(post.caption), style=Pack(padding=10, font_size=11)))
                content_box.add(card)
        except: pass

        main_box.add(content_box)
        self.container.content = main_box
