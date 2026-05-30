#!/usr/bin/env python3
"""
Local sync server for the Factorio Vanilla Progress Guide.

Serves index.html and exposes the mod's live progress so the webpage can
auto-poll and update in real time. Factorio mods cannot launch processes or
reach the network, so this server is the bridge: the mod writes
guide_progress.json + guide_heartbeat.json into Factorio's script-output
folder, and this server hands those files to the browser.

Usage:
    python serve.py [--port 8777] [--script-output PATH] [--no-browser]

If --script-output is omitted, the Factorio script-output folder is
auto-detected from %APPDATA%\\Factorio\\script-output (Windows). Override with
the FACTORIO_SCRIPT_OUTPUT environment variable or the --script-output flag.

Endpoints:
    GET /                 -> index.html (the guide)
    GET /index.html       -> same
    GET /progress.json    -> the mod's guide_progress.json (no-cache)
    GET /status           -> { connected, age_seconds, ... } from heartbeat
"""

import argparse
import http.server
import json
import os
import sys
import time
import webbrowser
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
INDEX_HTML = REPO_ROOT / "index.html"

# Consider Factorio "connected" if the heartbeat file was touched within this
# many seconds. The mod writes the heartbeat every 300 ticks (~5s at 60 UPS).
HEARTBEAT_FRESH_SECONDS = 15


def detect_script_output() -> Path:
    env = os.environ.get("FACTORIO_SCRIPT_OUTPUT")
    if env:
        return Path(env)
    appdata = os.environ.get("APPDATA")
    if appdata:
        return Path(appdata) / "Factorio" / "script-output"
    # Fallback for non-Windows / portable installs.
    return Path.home() / ".factorio" / "script-output"


class Handler(http.server.BaseHTTPRequestHandler):
    # Injected by main().
    script_output: Path = Path()

    def log_message(self, fmt, *args):
        # Quieter logging: only show the request line.
        sys.stderr.write("[server] %s - %s\n" % (self.address_string(), fmt % args))

    def _send(self, code, body, content_type="text/plain; charset=utf-8", no_cache=False):
        if isinstance(body, str):
            body = body.encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        if no_cache:
            self.send_header("Cache-Control", "no-store, no-cache, must-revalidate")
        self.end_headers()
        self.wfile.write(body)

    def _send_json(self, code, obj, no_cache=True):
        self._send(code, json.dumps(obj), "application/json; charset=utf-8", no_cache)

    def do_GET(self):
        path = self.path.split("?", 1)[0]

        if path in ("/", "/index.html"):
            return self._serve_index()
        if path == "/progress.json":
            return self._serve_progress()
        if path == "/status":
            return self._serve_status()

        self._send(404, "Not found")

    def _serve_index(self):
        try:
            body = INDEX_HTML.read_bytes()
        except OSError as e:
            return self._send(500, "Cannot read index.html: %s" % e)
        self._send(200, body, "text/html; charset=utf-8", no_cache=True)

    def _serve_progress(self):
        f = self.script_output / "guide_progress.json"
        try:
            body = f.read_bytes()
        except FileNotFoundError:
            return self._send_json(404, {
                "error": "guide_progress.json not found",
                "path": str(f),
                "hint": "Open the in-game guide and play, or click Export Progress.",
            })
        except OSError as e:
            return self._send_json(500, {"error": str(e), "path": str(f)})
        self._send(200, body, "application/json; charset=utf-8", no_cache=True)

    def _serve_status(self):
        hb = self.script_output / "guide_heartbeat.json"
        prog = self.script_output / "guide_progress.json"
        now = time.time()

        def age(p):
            try:
                return round(now - p.stat().st_mtime, 1)
            except OSError:
                return None

        hb_age = age(hb)
        connected = hb_age is not None and hb_age <= HEARTBEAT_FRESH_SECONDS
        self._send_json(200, {
            "connected": connected,
            "heartbeat_age_seconds": hb_age,
            "progress_age_seconds": age(prog),
            "progress_exists": prog.exists(),
            "script_output": str(self.script_output),
        })


def main():
    ap = argparse.ArgumentParser(description="Factorio guide local sync server")
    ap.add_argument("--port", type=int, default=8777)
    ap.add_argument("--script-output", default=None,
                    help="Path to Factorio script-output folder")
    ap.add_argument("--no-browser", action="store_true",
                    help="Do not auto-open the guide in a browser")
    args = ap.parse_args()

    script_output = Path(args.script_output) if args.script_output else detect_script_output()
    Handler.script_output = script_output

    if not INDEX_HTML.exists():
        print("ERROR: index.html not found at %s" % INDEX_HTML, file=sys.stderr)
        sys.exit(1)

    print("Factorio Guide sync server")
    print("  serving guide : %s" % INDEX_HTML)
    print("  script-output : %s%s" % (
        script_output, "" if script_output.exists() else "  (NOT FOUND yet)"))
    url = "http://localhost:%d/" % args.port
    print("  open in browser: %s" % url)
    print("  press Ctrl+C to stop")

    if not args.no_browser:
        try:
            webbrowser.open(url)
        except Exception:
            pass

    server = http.server.ThreadingHTTPServer(("127.0.0.1", args.port), Handler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nstopping...")
        server.shutdown()


if __name__ == "__main__":
    main()
