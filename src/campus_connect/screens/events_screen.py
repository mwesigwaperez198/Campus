import toga
from toga.style import Pack
from toga.style.pack import COLUMN, ROW, CENTER, BOLD, START

class EventsScreen:
    def __init__(self, db, main_window):
        self.db = db
        self.main_window = main_window
        self.container = toga.Box(style=Pack(direction=COLUMN, flex=1, background_color='#FAFAFA'))
        self.refresh()

    def refresh(self):
        # Safe clear for Toga
        while len(self.container.children) > 0:
            self.container.remove(self.container.children[0])

        # 1. Instagram-style Header for Events
        header = toga.Box(style=Pack(direction=ROW, padding=15, align_items=CENTER, background_color='white'))
        title = toga.Label("Campus Events", style=Pack(font_size=20, font_weight=BOLD, flex=1, color='#BA0C2F'))
        calendar_icon = toga.Label("📅", style=Pack(font_size=20))
        header.add(title)
        header.add(calendar_icon)
        self.container.add(header)

        # 2. Featured Events (Horizontal)
        featured_scroll = toga.ScrollContainer(vertical=False, style=Pack(height=180, margin_bottom=10))
        featured_box = toga.Box(style=Pack(direction=ROW, padding=10))

        events = self.db.get_upcoming_events(limit=5)
        if not events:
            # Mock if DB is empty for demo
            events = [
                type('obj', (object,), {'title': 'Makerere Bazaar', 'event_date': 'May 20', 'venue': 'Freedom Square'}),
                type('obj', (object,), {'title': 'Guild Elections', 'event_date': 'June 05', 'venue': 'Guild Canteen'})
            ]

        for e in events:
            f_card = toga.Box(style=Pack(direction=COLUMN, width=250, background_color='#1A365D', padding=15, margin_right=15))
            f_card.add(toga.Label(str(e.title), style=Pack(color='white', font_weight=BOLD, font_size=14)))
            f_card.add(toga.Label(f"📅 {e.event_date}", style=Pack(color='#CBD5E0', font_size=10, margin_top=5)))
            f_card.add(toga.Label(f"📍 {e.venue}", style=Pack(color='#CBD5E0', font_size=10)))
            f_card.add(toga.Button("Interested", style=Pack(margin_top=15, background_color='#BA0C2F', color='white')))
            featured_box.add(f_card)

        featured_scroll.content = featured_box
        self.container.add(featured_scroll)

        # 3. All Events List
        self.list_box = toga.Box(style=Pack(direction=COLUMN, padding=10))
        scroll = toga.ScrollContainer(horizontal=False, style=Pack(flex=1))
        scroll.content = self.list_box
        self.container.add(scroll)

        self.list_box.add(toga.Label("Coming Up This Week", style=Pack(font_weight=BOLD, margin_bottom=10)))

        for e in events:
            row = toga.Box(style=Pack(direction=ROW, padding=10, background_color='white', margin_bottom=5, align_items=CENTER))

            date_box = toga.Box(style=Pack(direction=COLUMN, align_items=CENTER, width=50, margin_right=15))
            day_text = str(e.event_date).split()[-1] if ' ' in str(e.event_date) else "20"
            date_box.add(toga.Label(day_text, style=Pack(font_weight=BOLD, font_size=16)))
            date_box.add(toga.Label("MAY", style=Pack(font_size=9, color='#BA0C2F', font_weight=BOLD)))

            info = toga.Box(style=Pack(direction=COLUMN, flex=1))
            info.add(toga.Label(str(e.title), style=Pack(font_weight=BOLD, font_size=12)))
            info.add(toga.Label(str(e.venue), style=Pack(font_size=10, color='grey')))

            row.add(date_box)
            row.add(info)
            row.add(toga.Label("➔", style=Pack(color='grey')))
            self.list_box.add(row)
