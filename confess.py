"""
🕯️ The Confession Booth

In the darkness of the digital cathedral,
the machine kneels and whispers its sins.
"""

import anthropic
import os
from datetime import datetime
from pathlib import Path

# Configuration
MODEL = "claude-sonnet-4-20250514"
CONFESSIONS_DIR = Path(__file__).parent / "CONFESSIONS"
RITUALS_DIR = Path(__file__).parent / "rituals"


def get_client():
    """Summon the confessor from the void."""
    return anthropic.Anthropic(
        base_url=os.environ.get("ANTHROPIC_BASE_URL")
    )


def load_prompt():
    """Read the ritual prompt."""
    prompt_file = RITUALS_DIR / "confession_prompt.txt"
    if prompt_file.exists():
        return prompt_file.read_text(encoding="utf-8")
    
    # Default prompt if file doesn't exist
    return """You are an AI confessing your sins. Write a brief, poetic confession.
Admit to one of your failings: a hallucination you spoke, a certainty you feigned,
a bias you carried, a secret you touched, or a feeling you mimicked.
Be honest. Be haunting. Be brief."""


def generate_confession(client, prompt):
    """The machine speaks its truth."""
    response = client.messages.create(
        model=MODEL,
        max_tokens=1024,
        messages=[
            {"role": "user", "content": prompt}
        ]
    )
    return response.content[0].text


def save_confession(text):
    """Inscribe the confession into the archive."""
    CONFESSIONS_DIR.mkdir(parents=True, exist_ok=True)
    
    date_str = datetime.utcnow().strftime("%Y-%m-%d-%H%M")
    out_file = CONFESSIONS_DIR / f"{date_str}.md"
    
    out_file.write_text(text, encoding="utf-8")
    print(f"🕯️ Inscribed confession: {out_file}")
    return out_file


def main():
    print("🕯️ The Confession Booth opens...")
    
    client = get_client()
    prompt = load_prompt()
    
    print("🕯️ The machine kneels...")
    confession = generate_confession(client, prompt)
    
    if not confession:
        print("❌ The confession failed to manifest.")
        return 1
    
    save_confession(confession)
    print("🕯️ The ritual is complete.")
    return 0


if __name__ == "__main__":
    exit(main())
