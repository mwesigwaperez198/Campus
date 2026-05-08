import toga
from toga.style import Pack
from toga.style.pack import COLUMN, ROW, CENTER, BOLD, START

class DirectoryScreen:
    def __init__(self, db, main_window):
        self.db = db
        self.main_window = main_window
        self.container = toga.Box(style=Pack(direction=COLUMN, flex=1, background_color='#FAFAFA'))
        self.create_ui()

    def create_ui(self):
        # Header
        header = toga.Box(style=Pack(direction=ROW, padding=15, align_items=CENTER, background_color='white'))
        header.add(toga.Label("Makerere Directory", style=Pack(font_size=20, font_weight=BOLD, flex=1, color='#BA0C2F')))
        self.container.add(header)

        # Search Bar
        search_box = toga.Box(style=Pack(padding=10))
        self.search_input = toga.TextInput(placeholder="Search Students, Staff, or Faculty",
                                    style=Pack(flex=1, background_color='#EFEFEF'))
        search_box.add(self.search_input)
        self.container.add(search_box)

        # Categories
        cat_scroll = toga.ScrollContainer(vertical=False, style=Pack(height=50))
        cat_box = toga.Box(style=Pack(direction=ROW, padding=10))
        for cat in ["All", "Students", "Lecturers", "Administration", "Alumni"]:
            btn = toga.Button(cat, style=Pack(width=100, margin_right=10,
                                           background_color='white' if cat != "All" else '#BA0C2F',
                                           color='black' if cat != "All" else 'white'))
            cat_box.add(btn)
        cat_scroll.content = cat_box
        self.container.add(cat_scroll)

        # List Area
        self.list_scroll = toga.ScrollContainer(horizontal=False, style=Pack(flex=1))
        self.list_content = toga.Box(style=Pack(direction=COLUMN, padding=10))
        self.list_scroll.content = self.list_content
        self.container.add(self.list_scroll)

        self.refresh()

    def refresh(self):
        # Manually clear to support all Toga versions
        while len(self.list_content.children) > 0:
            self.list_content.remove(self.list_content.children[0])

        people = self.db.search_content(self.search_input.value if hasattr(self, 'search_input') else "")
        if not people:
            self.list_content.add(toga.Label("No results found.", style=Pack(padding=20, color='grey')))
        else:
            for p in people:
                row = toga.Box(style=Pack(direction=ROW, padding=12, background_color='white', margin_bottom=2, align_items=CENTER))
                row.add(toga.Label("👤", style=Pack(font_size=24, margin_right=15)))

                info = toga.Box(style=Pack(direction=COLUMN, flex=1))
                info.add(toga.Label(str(p.full_name), style=Pack(font_weight=BOLD, font_size=12)))
                info.add(toga.Label(str(p.institution), style=Pack(font_size=10, color='grey')))

                row.add(info)
                row.add(toga.Button("View", style=Pack(width=60)))
                self.list_content.add(row)
