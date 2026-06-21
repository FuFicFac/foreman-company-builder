#!/usr/bin/env python3
"""Foreman brain helper — handles multi-turn conversation with brain providers.
Called by foreman-chat.sh during AI-driven onboarding.

Usage:
  foreman-brain.py --provider openai --model gpt-4 \\
    --system-prompt "..." --history /tmp/conv.json --user-msg "Hello"

Reads conversation history from --history (JSON array of {role, content}).
Appends the user message, calls the provider, appends the response, writes
updated history back, and prints the response text to stdout.
"""

import argparse
import json
import os
import sys
import urllib.request


def call_openai(model, messages, api_key, base_url="https://api.openai.com/v1/chat/completions"):
    payload = json.dumps({"model": model, "messages": messages, "max_tokens": 500}).encode()
    req = urllib.request.Request(
        base_url,
        data=payload,
        headers={"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=30) as resp:
        data = json.loads(resp.read())
    return data["choices"][0]["message"]["content"]


def call_xai(model, messages, api_key):
    return call_openai(model, messages, api_key, base_url="https://api.x.ai/v1/chat/completions")


def call_ollama(model, system_prompt, conversation_text):
    import subprocess
    result = subprocess.run(
        ["ollama", "run", model, f"{system_prompt}\n\n{conversation_text}"],
        capture_output=True, text=True, timeout=30
    )
    return result.stdout.strip()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--provider", required=True)
    parser.add_argument("--model", required=True)
    parser.add_argument("--system-prompt", required=True)
    parser.add_argument("--history", required=True, help="Path to conversation history JSON file")
    parser.add_argument("--user-msg", required=True)
    args = parser.parse_args()

    # Load or init conversation history
    history = []
    if os.path.exists(args.history):
        with open(args.history) as f:
            history = json.load(f)

    # Append user message
    history.append({"role": "user", "content": args.user_msg})

    # Build messages for API call
    messages = [{"role": "system", "content": args.system_prompt}] + history

    response = ""
    if args.provider == "openai":
        api_key = os.environ.get("OPENAI_API_KEY", "")
        if not api_key:
            print("(no OPENAI_API_KEY set)")
            return 1
        try:
            response = call_openai(args.model, messages, api_key)
        except Exception as e:
            response = f"(brain error: {e})"

    elif args.provider == "xai":
        api_key = os.environ.get("XAI_API_KEY", "")
        if not api_key:
            print("(no XAI_API_KEY set)")
            return 1
        try:
            response = call_xai(args.model, messages, api_key)
        except Exception as e:
            response = f"(brain error: {e})"

    elif args.provider == "ollama":
        # Ollama doesn't have a REST chat API in the same way; use CLI
        conv_text = "\n".join(f"{m['role'].capitalize()}: {m['content']}" for m in history)
        try:
            response = call_ollama(args.model, args.system_prompt, conv_text)
        except Exception as e:
            response = f"(brain error: {e})"

    else:
        print(f"(unsupported provider: {args.provider})")
        return 1

    # Append response to history and save
    history.append({"role": "assistant", "content": response})
    with open(args.history, "w") as f:
        json.dump(history, f, indent=2)

    # Print response (without the completion marker — that's parsed by the caller)
    print(response)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())