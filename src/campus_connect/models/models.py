from dataclasses import dataclass
from enum import Enum
from typing import Optional, List

class UserRole(Enum):
    STUDENT = 'student'
    ADMIN = 'admin'

@dataclass
class SessionUser:
    id: str
    email: str
    full_name: str
    role: UserRole
    avatar_url: Optional[str] = None
    institution: str = "Makerere University"

    @classmethod
    def from_json(cls, data: dict):
        if not data: data = {}
        role_raw = str(data.get('role', 'student')).lower()
        try:
            role_enum = UserRole(role_raw)
        except ValueError:
            role_enum = UserRole.STUDENT

        return cls(
            id=str(data.get('id', '')),
            email=str(data.get('email', '')),
            full_name=str(data.get('full_name') or 'Makerere User'),
            role=role_enum,
            avatar_url=data.get('avatar_url'),
            institution=str(data.get('institution') or "Makerere University")
        )

@dataclass
class FeedPost:
    id: str
    author_id: str
    author_name: str
    author_avatar: Optional[str]
    location: str
    caption: str
    image_url: Optional[str]
    likes_count: int
    comments_count: int
    is_verified: bool
    created_at: str

    @classmethod
    def from_json(cls, data: dict):
        if not data: data = {}
        profile = data.get('profiles') or {}
        # Robustly handle if profile is a list or a dict
        if isinstance(profile, list):
            profile = profile[0] if len(profile) > 0 else {}

        # Safe extraction of counts from list or dict
        likes = data.get('post_likes', [])
        l_count = 0
        if isinstance(likes, list) and len(likes) > 0:
            l_count = likes[0].get('count', 0)
        elif isinstance(likes, dict):
            l_count = likes.get('count', 0)

        comments = data.get('post_comments', [])
        c_count = 0
        if isinstance(comments, list) and len(comments) > 0:
            c_count = comments[0].get('count', 0)
        elif isinstance(comments, dict):
            c_count = comments.get('count', 0)

        return cls(
            id=str(data.get('id', '')),
            author_id=str(data.get('author_id', '')),
            author_name=str(profile.get('full_name') or 'Makerere User'),
            author_avatar=profile.get('avatar_url'),
            location=str(profile.get('location') or 'Makerere University'),
            caption=str(data.get('caption') or ''),
            image_url=data.get('image_url'),
            likes_count=int(l_count),
            comments_count=int(c_count),
            is_verified=bool(profile.get('is_verified', False)),
            created_at=str(data.get('created_at', ''))
        )

@dataclass
class CampusStatus:
    id: str
    user_id: str
    full_name: str
    content_url: str
    created_at: str

    @classmethod
    def from_json(cls, data: dict):
        if not data: data = {}
        profile = data.get('profiles') or {}
        if isinstance(profile, list):
            profile = profile[0] if len(profile) > 0 else {}

        return cls(
            id=str(data.get('id', '')),
            user_id=str(data.get('user_id', '')),
            full_name=str(profile.get('full_name') or 'User'),
            content_url=str(data.get('content_url', '')),
            created_at=str(data.get('created_at', ''))
        )

@dataclass
class CampusGroup:
    id: str
    name: str
    focus: str
    avatar_url: Optional[str]

    @classmethod
    def from_json(cls, data: dict):
        if not data: data = {}
        return cls(
            id=str(data.get('id', '')),
            name=str(data.get('name') or 'General Group'),
            focus=str(data.get('focus') or 'Campus Life'),
            avatar_url=data.get('avatar_url')
        )

@dataclass
class CampusEvent:
    id: str
    title: str
    event_date: str
    venue: str
    image_url: Optional[str]

    @classmethod
    def from_json(cls, data: dict):
        if not data: data = {}
        return cls(
            id=str(data.get('id', '')),
            title=str(data.get('title') or 'Upcoming Event'),
            event_date=str(data.get('event_date', '')),
            venue=str(data.get('venue') or 'Makerere Main Campus'),
            image_url=data.get('image_url')
        )
