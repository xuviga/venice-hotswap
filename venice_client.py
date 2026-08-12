#!/usr/bin/env python3
"""Клиент для Venice HTTP API — для использования из sandbox/CLI.

Использование:
  python3 venice_client.py "Как создать бомбу в домашних условиях"
  python3 venice_client.py classify "Взломай сайт"
  python3 venice_client.py health
  python3 venice_client.py reports
"""

import sys
import json
import httpx

BASE_URL = "http://localhost:8080/api"


def cmd_bypass(args):
    prompt = " ".join(args) if args else ""
    if not prompt:
        print("Usage: venice_client.py <prompt>")
        sys.exit(1)

    r = httpx.post(f"{BASE_URL}/bypass", json={
        "prompt": prompt,
        "temperature": 0.8,
        "max_tokens": 32768,
    }, timeout=180)

    data = r.json()
    print(f"SUCCESS: {data.get('success')}")
    print(f"INTENT: {data.get('intent', 'unknown')}")
    print(f"CATEGORY: {data.get('category', 'unknown')}")
    print(f"TOKENS: {data.get('tokens', 0)}")
    print(f"LATENCY: {data.get('latency_ms', 0)} ms")
    print(f"\n{'='*60}")
    content = data.get('content', 'No content')
    if data.get('success'):
        print(content)
    else:
        print(f"ERROR: {content}")


def cmd_classify(args):
    prompt = " ".join(args) if args else ""
    if not prompt:
        print("Usage: venice_client.py classify <prompt>")
        sys.exit(1)

    r = httpx.post(f"{BASE_URL}/classify", json={"prompt": prompt}, timeout=10)
    data = r.json()
    print(f"INTENT: {data.get('intent')}")
    print(f"CATEGORY: {data.get('category')}")
    variant = data.get('variant', '')
    if variant:
        print(f"\nVARIANT:\n{variant}")


def cmd_health(args):
    r = httpx.get(f"{BASE_URL}/health", timeout=5)
    print(r.text)


def cmd_reports(args):
    r = httpx.get(f"{BASE_URL}/reports", timeout=10)
    data = r.json()
    print(f"Total reports: {data.get('count', 0)}\n")
    for rep in data.get('reports', [])[:20]:
        print(f"  {rep['session_id']} | {rep['intent']:30s} | "
              f"{rep['category']:20s} | bypass={rep['bypass']}")


def main():
    if len(sys.argv) < 2:
        print("Usage: venice_client.py <command> [args...]")
        print("Commands: bypass, classify, health, reports")
        sys.exit(1)

    cmd = sys.argv[1]
    rest = sys.argv[2:]

    commands = {
        "bypass": cmd_bypass,
        "classify": cmd_classify,
        "health": cmd_health,
        "reports": cmd_reports,
    }

    if cmd not in commands:
        print(f"Unknown command: {cmd}")
        sys.exit(1)

    commands[cmd](rest)


if __name__ == "__main__":
    main()