"""Deployment configuration loader for the CodeTrack demo app."""

import os

REGION = os.getenv("AWS_REGION", "eu-west-2")


def load_config():
    """Return deployment settings, reading credentials from the environment."""
    return {
        "region": REGION,
        "access_key_id": os.environ["AWS_ACCESS_KEY_ID"],
    }
