#!/usr/bin/env python3
import sys, json, argparse
from pathlib import Path

# --- ANSI Colors ---
BOLD = "\033[1m"
RESET = "\033[0m"
RED = "\033[31m"
GREEN = "\033[32m"
CYAN = "\033[36m"
YELLOW = "\033[33m"
GRAY = "\033[90m"

def color(text, color_code):
    return f"{color_code}{text}{RESET}"

def diff(a, b, path=""):
    """Recursively diff two JSON structures."""
    changes = []
    if a == b:
        return changes

    if type(a) != type(b):
        changes.append((path, {"from": a, "to": b}))
        return changes

    if isinstance(a, dict):
        keys = set(a.keys()) | set(b.keys())
        for k in sorted(keys):
            new_path = f"{path}.{k}" if path else k
            if k not in a:
                changes.append((new_path, {"from": None, "to": b[k]}))
            elif k not in b:
                changes.append((new_path, {"from": a[k], "to": None}))
            else:
                changes += diff(a[k], b[k], new_path)
        return changes

    if isinstance(a, list):
        if all(isinstance(x, dict) and "id" in x for x in a + b):
            a_map = {x["id"]: x for x in a}
            b_map = {x["id"]: x for x in b}
            ids = set(a_map.keys()) | set(b_map.keys())
            for i in sorted(ids):
                new_path = f"{path}[{i}]"
                if i not in a_map:
                    changes.append((new_path, {"from": None, "to": b_map[i]}))
                elif i not in b_map:
                    changes.append((new_path, {"from": a_map[i], "to": None}))
                else:
                    changes += diff(a_map[i], b_map[i], new_path)
        else:
            if a != b:
                changes.append((path, {"from": a, "to": b}))
        return changes

    changes.append((path, {"from": a, "to": b}))
    return changes


def summarize(data, skip_time_trackings=False):
    prev = data.get("previous")
    curr = data.get("current")

    if prev is None or curr is None:
        return color("❌ JSON must contain 'previous' and 'current' keys.", RED)

    if skip_time_trackings:
        for obj in (prev, curr):
            obj.pop("time_trackings", None)

    changes = diff(prev, curr)
    if not changes:
        return color("✅ No differences found.", GREEN)

    root_changes = [(p, c) for p, c in changes if "." not in p and "[" not in p]
    nested_changes = [(p, c) for p, c in changes if "." in p or "[" in p]

    lines = [color("🔍 Differences found:\n", CYAN)]

    # --- Root-level section ---
    if root_changes:
        lines.append(color(BOLD + "🌐 Root-level changes:" + RESET, YELLOW))
        for path, change in root_changes:
            f = json.dumps(change["from"], ensure_ascii=False)
            t = json.dumps(change["to"], ensure_ascii=False)
            lines.append(f"  • {BOLD}{path}{RESET}")
            lines.append(f"      {RED}- from:{RESET} {GRAY}{f}{RESET}")
            lines.append(f"      {GREEN}+ to:{RESET}   {t}")
        lines.append("")

    # --- Group time_trackings by ID ---
    tt_changes = {}
    other_changes = []
    for path, change in nested_changes:
        if path.startswith("time_trackings["):
            tid = path.split("[", 1)[1].split("]", 1)[0]
            subpath = path.split("]", 1)[1].lstrip(".")
            tt_changes.setdefault(tid, []).append((subpath, change))
        else:
            other_changes.append((path, change))

    # --- TimeTracking section ---
    if tt_changes:
        lines.append(color(BOLD + "🕒 TimeTracking changes:" + RESET, YELLOW))
        for tid, diffs in sorted(tt_changes.items()):
            lines.append(f"{BOLD}  • ID {tid}{RESET}")
            for subpath, change in diffs:
                f = json.dumps(change["from"], ensure_ascii=False)
                t = json.dumps(change["to"], ensure_ascii=False)
                lines.append(f"      - {color(subpath, CYAN)}")
                lines.append(f"        {RED}- from:{RESET} {GRAY}{f}{RESET}")
                lines.append(f"        {GREEN}+ to:{RESET}   {t}")
            lines.append("")

    # --- Other nested changes ---
    if other_changes:
        lines.append(color(BOLD + "📂 Other nested changes:" + RESET, YELLOW))
        for path, change in other_changes:
            f = json.dumps(change["from"], ensure_ascii=False)
            t = json.dumps(change["to"], ensure_ascii=False)
            lines.append(f"  • {BOLD}{path}{RESET}")
            lines.append(f"      {RED}- from:{RESET} {GRAY}{f}{RESET}")
            lines.append(f"      {GREEN}+ to:{RESET}   {t}")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(
        description="Diff 'previous' vs 'current' JSON objects with grouped time_trackings."
    )
    parser.add_argument("file", nargs="?", help="Path to JSON file (or read from stdin)")
    parser.add_argument("--skip-time-trackings", action="store_true",
                        help="Ignore the 'time_trackings' field")
    args = parser.parse_args()

    if args.file:
        path = Path(args.file)
        if not path.exists():
            print(color(f"❌ File not found: {path}", RED), file=sys.stderr)
            sys.exit(1)
        data = json.loads(path.read_text())
    else:
        try:
            data = json.load(sys.stdin)
        except json.JSONDecodeError:
            print(color("❌ Invalid JSON input.", RED), file=sys.stderr)
            sys.exit(1)

    print(summarize(data, skip_time_trackings=args.skip_time_trackings))


if __name__ == "__main__":
    main()
