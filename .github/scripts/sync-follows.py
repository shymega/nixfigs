#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
# Reads flake.lock, finds sub-inputs that share a name with a top-level input
# but aren't following it, then patches flake.nix to add the missing follows
# declarations co-located with each input's own block.

import json
import re
import sys
from collections import defaultdict


def load_needed_follows(lock_path: str = "flake.lock") -> dict[str, list[str]]:
    with open(lock_path) as f:
        lock = json.load(f)

    nodes = lock["nodes"]
    raw_root = nodes["root"]["inputs"]

    # Indirect follows are encoded as lists (e.g. ["hyprnix", "hyprland"]) — skip them.
    root_inputs: dict[str, str] = {k: v for k, v in raw_root.items() if isinstance(v, str)}
    node_to_input = {v: k for k, v in root_inputs.items()}
    top_level_names = set(root_inputs.keys())

    needed: dict[str, list[str]] = defaultdict(list)
    for node_name, node_data in nodes.items():
        if node_name == "root" or node_name not in node_to_input:
            continue
        input_name = node_to_input[node_name]
        for sub_name, sub_node in node_data.get("inputs", {}).items():
            if (
                sub_name in top_level_names
                and isinstance(sub_node, str)
                and sub_node != root_inputs[sub_name]
            ):
                needed[input_name].append(sub_name)

    return dict(needed)


def is_already_declared(content: str, input_name: str, sub_name: str) -> bool:
    """Return True if a follows for sub_name is already present for input_name."""
    patterns = [
        # dotted at top level: foo.inputs.bar.follows =
        rf'\b{re.escape(input_name)}\.inputs\.{re.escape(sub_name)}\.follows\s*=',
        # inside a block: inputs.bar.follows = or bar.follows = inside inputs = {}
        rf'\b{re.escape(input_name)}\s*=\s*\{{[^}}]*\binputs\.{re.escape(sub_name)}\.follows\s*=',
        rf'\b{re.escape(input_name)}\s*=\s*\{{[^}}]*\binputs\s*=\s*\{{[^}}]*\b{re.escape(sub_name)}\.follows\s*=',
    ]
    return any(re.search(p, content, re.DOTALL) for p in patterns)


def find_block_end(content: str, open_brace: int) -> int:
    """Given the index of an opening {, return the index of its matching }."""
    depth = 0
    for i, ch in enumerate(content[open_brace:]):
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return open_brace + i
    return -1


def add_follows_for_input(content: str, input_name: str, sub_names: list[str]) -> str:
    missing = [s for s in sub_names if not is_already_declared(content, input_name, s)]
    if not missing:
        return content

    for s in missing:
        print(f"  Adding: inputs.{input_name}.inputs.{s}.follows = \"{s}\"")

    # --- Block form: input_name = { ... } ---
    block_pat = re.compile(rf'(?m)^(\s*)\b{re.escape(input_name)}\s*=\s*(\{{)')
    m = block_pat.search(content)
    if m:
        indent = m.group(1)          # leading whitespace of the line
        open_pos = m.start(2)        # position of {
        close_pos = find_block_end(content, open_pos)
        if close_pos != -1:
            inner_indent = indent + "  "
            follows_text = "".join(
                f'\n{inner_indent}inputs.{s}.follows = "{s}";' for s in missing
            )
            return content[:close_pos] + follows_text + "\n" + indent + content[close_pos:]

    # --- Single-line form: input_name.something = ...; (possibly multiple lines) ---
    single_pat = re.compile(rf'(?m)^(\s*)\b{re.escape(input_name)}\.[^\n]+;\n')
    m = single_pat.search(content)
    if m:
        indent = m.group(1)
        # Collect all consecutive dotted-attribute lines for this input.
        block_pat2 = re.compile(
            rf'(?m)((?:^{re.escape(indent)}{re.escape(input_name)}\.[^\n]+;\n)+)'
        )
        bm = block_pat2.search(content, m.start())
        if bm:
            raw_lines = bm.group(1)
            url_m = re.search(rf'{re.escape(input_name)}\.url\s*=\s*([^;]+);', raw_lines)
            url_val = url_m.group(1).strip() if url_m else '"UNKNOWN"'

            inner = indent + "  "
            follows_text = "".join(f'\n{inner}inputs.{s}.follows = "{s}";' for s in missing)
            new_block = (
                f'{indent}{input_name} = {{\n'
                f'{inner}url = {url_val};'
                f'{follows_text}\n'
                f'{indent}}};\n'
            )
            return content[: bm.start()] + new_block + content[bm.end() :]

    print(f"  WARNING: could not locate declaration for '{input_name}' in flake.nix", file=sys.stderr)
    return content


def main() -> None:
    needed = load_needed_follows()

    if not needed:
        print("All sub-inputs already follow their top-level counterparts.")
        return

    with open("flake.nix") as f:
        content = f.read()

    original = content
    for input_name, sub_names in sorted(needed.items()):
        genuinely_missing = [s for s in sub_names if not is_already_declared(content, input_name, s)]
        if not genuinely_missing:
            continue
        print(f"Processing: {input_name}")
        content = add_follows_for_input(content, input_name, genuinely_missing)

    if content == original:
        print("No changes needed.")
        return

    with open("flake.nix", "w") as f:
        f.write(content)
    print("Done.")


if __name__ == "__main__":
    main()
