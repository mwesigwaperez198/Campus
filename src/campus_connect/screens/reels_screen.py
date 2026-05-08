import toga
from toga.style import Pack
from toga.style.pack import COLUMN, ROW, CENTER, BOLD, END, START

class ReelsScreen:
    def __init__(self, db, main_window):
        self.db = db
        self.main_window = main_window
        # Black background for Reels/Videos
        self.container = toga.Box(style=Pack(direction=COLUMN, flex=1, background_color='black'))
        self.refresh()

    def refresh(self):
        # Simulated Instagram Reels Layout
        main_box = toga.Box(style=Pack(direction=COLUMN, flex=1))

        # Full screen video area (simulated)
        video_area = toga.Box(style=Pack(direction=COLUMN, flex=1, justify_content=CENTER, align_items=CENTER))

        # Overlay Content (Bottom of the reel)
        overlay = toga.Box(style=Pack(direction=ROW, padding=20))

        # Left side: Author and Description
        text_info = toga.Box(style=Pack(direction=COLUMN, flex=1, justify_content=END))
        author_row = toga.Box(style=Pack(direction=ROW, align_items=CENTER, margin_bottom=10))

        avatar = toga.Box(style=Pack(width=35, height=35, background_color='#BA0C2F', padding=1, margin_right=10))
        avatar.add(toga.Box(style=Pack(flex=1, background_color='white'))) # Inner circle placeholder

        author_name = toga.Label("@makerere_official", style=Pack(color='white', font_weight=BOLD, font_size=12))
        follow_btn = toga.Button("Follow", style=Pack(width=70, height=25, background_color='transparent', color='white', font_size=9))

        author_row.add(avatar)
        author_row.add(author_name)
        author_row.add(follow_btn)

        caption = toga.Label("Preparing for the 74th Graduation Ceremony at Makerere! 🎓✨ #WeBuildForTheFuture",
                            style=Pack(color='white', font_size=10, margin_bottom=10))

        music_row = toga.Box(style=Pack(direction=ROW, align_items=CENTER))
        music_icon = toga.Label("♫", style=Pack(color='white', margin_right=5))
        music_name = toga.Label("Makerere Anthem - Instrumental", style=Pack(color='white', font_size=9))
        music_row.add(music_icon)
        music_row.add(music_name)

        text_info.add(author_row)
        text_info.add(caption)
        text_info.add(music_row)

        # Right side: Action icons (Like, Comment, Share)
        actions = toga.Box(style=Pack(direction=COLUMN, align_items=CENTER, justify_content=END, padding_left=10))

        like = toga.Box(style=Pack(direction=COLUMN, align_items=CENTER, margin_bottom=20))
        like.add(toga.Label("❤️", style=Pack(font_size=20, color='white')))
        like.add(toga.Label("25.4K", style=Pack(color='white', font_size=9)))

        comment = toga.Box(style=Pack(direction=COLUMN, align_items=CENTER, margin_bottom=20))
        comment.add(toga.Label("💬", style=Pack(font_size=20, color='white')))
        comment.add(toga.Label("842", style=Pack(color='white', font_size=9)))

        share = toga.Box(style=Pack(direction=COLUMN, align_items=CENTER))
        share.add(toga.Label("✈️", style=Pack(font_size=20, color='white')))
        share.add(toga.Label("Share", style=Pack(color='white', font_size=9)))

        actions.add(like)
        actions.add(comment)
        actions.add(share)

        overlay.add(text_info)
        overlay.add(actions)

        # Background Placeholder
        video_placeholder = toga.Label("🎥 GRADUATION REEL PREVIEW",
                                      style=Pack(color='#2D3748', font_size=24, font_weight=BOLD, text_align=CENTER))

        video_area.add(video_placeholder)

        main_box.add(video_area)
        main_box.add(overlay)

        self.container.add(main_box)
