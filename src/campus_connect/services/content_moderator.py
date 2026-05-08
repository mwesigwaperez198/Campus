import re

class ContentModerator:
    @staticmethod
    def validate_text(text: str) -> str | None:
        """
        Validates text for inappropriate content, threats, and spam links.
        Returns an error message if invalid, else None.
        """
        if not text:
            return "Content cannot be empty."

        # 1. Block inappropriate language (Placeholder for a larger list)
        banned_words = ['offensive_word1', 'offensive_word2'] # Add actual banned words
        for word in banned_words:
            if word in text.lower():
                return f"Your post contains inappropriate language: {word}"

        # 2. Block potential spam links (External URLs)
        url_pattern = r'http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+'
        links = re.findall(url_pattern, text)
        for link in links:
            if "novara.ac.ug" not in link: # Only allow internal university links
                return "External links are not allowed for security reasons."

        # 3. Detect aggressive patterns (Simple placeholder for threat detection)
        threat_keywords = ['kill', 'bomb', 'attack']
        if any(keyword in text.lower() for keyword in threat_keywords):
            return "Your post contains keywords that violate our safety policies."

        return None
