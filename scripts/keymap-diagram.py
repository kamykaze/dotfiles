#!/usr/bin/env python3
"""Draw the kanata layers as an SVG, with app names pulled from BetterTouchTool.

kanata knows which chord a key fires (Meh+1); BetterTouchTool knows what that
chord *does* (Obsidian). Neither file is readable on its own, so this stitches
them: keymap-drawer parses the layers, then every raw chord is relabelled from
the BTT preset before drawing.

Run it through scripts/keymap-diagram.sh, which supplies keymap-drawer.
"""

import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path

import yaml

REPO = Path(__file__).resolve().parent.parent
KANATA_CFG = REPO / "_configs" / "kanata.kbd"
MBP_LAYOUT = REPO / "scripts" / "keymap-mbp.json"
BTT_PRESET = REPO / "bettertouchtool" / "kam_btt_presets.bttpreset"
OUTPUT_SVG = REPO / "assets" / "keyboard-layers.svg"

# BTT stores modifiers as an NSEvent flag mask.
SHIFT, CTRL, OPT, CMD = 131072, 262144, 524288, 1048576
MEH = SHIFT | CTRL | OPT
HYPER = MEH | CMD
CTRL_OPT = CTRL | OPT

# BTT's key names vs kanata's, for the handful that differ.
BTT_TO_KANATA = {
    "SPACE": "spc", "RETURN": "ret", "DELETE": "bspc", "TAB": "tab",
    "ESCAPE": "esc", "LEFT": "lft", "RIGHT": "rght", "UP": "up", "DOWN": "down",
}

# Keys macOS never sends, so kanata cannot see them and keymap-drawer cannot
# parse them. Fn is worth drawing anyway: held, it starts voice dictation.
SYNTHETIC = {
    "fn": {"t": "fn", "h": "dictation", "type": "ghost"},
    "touchid": {"t": "Touch  ID", "type": "ghost"},
}

PRETTY = {"spc": "space", "ret": "return", "bspc": "delete", "grv": "`"}

# What a key does when no layer touches it. Drawn faint on the base layer only,
# so the trigger keys can be found against a recognisable keyboard.
DEFAULT_LEGENDS = {
    "grv": "`", "bspc": "delete", "tab": "tab", "caps": "caps", "ret": "return",
    "lshift": "shift", "rsft": "shift", "lctl": "ctrl", "lalt": "opt",
    "lmet": "cmd", "rmet": "cmd", "ralt": "opt", "spc": "space", "esc": "esc",
    "lft": "←", "rght": "→", "up": "↑", "down": "↓",
}

# The symbols layer exists to move these within reach, so draw what they type
# rather than the chord that types it: "%" says more than "lsft+5".
SHIFTED = {
    "grv": "~", "1": "!", "2": "@", "3": "#", "4": "$", "5": "%", "6": "^",
    "7": "&", "8": "*", "9": "(", "0": ")", "-": "_", "=": "+", "[": "{",
    "]": "}", "\\": "|", ";": ":", "'": '"', ",": "<", ".": ">", "/": "?",
}

# One colour per layer, reused for the keys that switch to it. Opacity does the
# light/dark work, so each layer needs a single colour rather than two.
LAYER_COLORS = {
    "base": None,  # the resting layer — tinting all of it would say nothing
    "jump": "#3f51b5",
    "numbers": "#2e7d32",
    "Symbols": "#ef6c00",
    "navigation": "#7b1fa2",
    "shortcuts": "#c9a227",  # gold: the teal sat too close to the numbers green
    "mirror": "#bf360c",
    "plain": "#455a64",
    "disabled": "#9e9e9e",
}


# Window management reads far better as a picture than as "Resize Window to
# Bottom Right Quarter". No icon set carries thirds vs two-thirds vs quarters,
# so the glyphs are generated from the geometry the label describes.
GLYPH_BOX = 'viewBox="0 0 24 16"'


def rounded_rect(x: float, y: float, w: float, h: float, r: float = 1.5) -> str:
    """A rounded rectangle as a path.

    Paths, not <rect>: keymap-drawer strips every width= and height= attribute
    out of glyph definitions before inlining them, which leaves a rect with
    nothing to draw. Callers must also style paths with a style= attribute
    rather than fill=/stroke=, because its stylesheet carries a blanket
    "svg path { fill: inherit }" that beats any presentation attribute.
    """
    r = min(r, w / 2, h / 2)
    return (
        f"M{x + r:.1f} {y:.1f} H{x + w - r:.1f} A{r:.1f} {r:.1f} 0 0 1 {x + w:.1f} {y + r:.1f} "
        f"V{y + h - r:.1f} A{r:.1f} {r:.1f} 0 0 1 {x + w - r:.1f} {y + h:.1f} "
        f"H{x + r:.1f} A{r:.1f} {r:.1f} 0 0 1 {x:.1f} {y + h - r:.1f} "
        f"V{y + r:.1f} A{r:.1f} {r:.1f} 0 0 1 {x + r:.1f} {y:.1f} Z"
    )


# Kanata's ∅ (no-op) parses to an empty legend, indistinguishable from a key
# this keyboard simply doesn't have. On the disabled layer that difference is
# the whole point, so those keys get drawn explicitly.
NO_OP_GLYPH = (
    '<svg viewBox="0 0 24 16" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M5.8 8 A6.2 6.2 0 1 0 18.2 8 A6.2 6.2 0 1 0 5.8 8 Z" '
    'style="fill:none;stroke:currentColor;stroke-width:1.5"/>'
    '<path d="M7.6 12.4 L16.4 3.6" style="fill:none;stroke:currentColor;stroke-width:1.5"/>'
    "</svg>"
)


def block_arrow(x0: float, x1: float, right: bool = True, cy: float = 8.0) -> str:
    """A solid arrow spanning x0..x1 on the centre line, pointing either way.

    x0 < x1 always: `right` mirrors the finished shape rather than reversing
    the span, so the arrow keeps its proportions in both directions.
    """
    shaft, head_len, head_half = 1.1, 3.4, 3.0
    points = [
        (x0, cy - shaft), (x1 - head_len, cy - shaft), (x1 - head_len, cy - head_half),
        (x1, cy),
        (x1 - head_len, cy + head_half), (x1 - head_len, cy + shaft), (x0, cy + shaft),
    ]
    if not right:
        points = [(x0 + x1 - px, py) for px, py in points]
    return "M" + " L".join(f"{px:.1f} {py:.1f}" for px, py in points) + " Z"


def glyph_svg(*shapes: str) -> str:
    return f'<svg {GLYPH_BOX} xmlns="http://www.w3.org/2000/svg">{"".join(shapes)}</svg>'


OUTLINE = "fill:none;stroke:currentColor;stroke-width:1.6"
DASHED = "stroke-dasharray:2.6 2.2"
SOLID = "fill:currentColor;stroke:none"
FRAME = f'<path d="{rounded_rect(1, 1, 22, 14, 2)}" style="{OUTLINE}"/>' 


def window_glyph(label: str) -> tuple[str, str] | None:
    """Build a "screen with the target region shaded" glyph for a BTT window
    action. Returns (glyph name, SVG), or None if the label describes something
    this can't draw."""
    text = label.lower()

    # Moving the window elsewhere: draw where it goes, not a region.
    right = "right" in text or "next" in text
    side = "right" if right else "left"

    # Both of these put the arrow OUTSIDE the screen: an arrow drawn inside the
    # box just reads as an arrow key.
    if "monitor" in text or "display" in text:
        # Two screens with the window crossing to the filled one.
        source, target = (0.5, 15.2) if right else (15.5, 0.5)
        near = f'<path d="{rounded_rect(source, 3, 8.3, 10)}" style="{OUTLINE}"/>'
        far = f'<path d="{rounded_rect(target, 3, 8.3, 10)}" style="{SOLID}"/>'
        arrow = f'<path d="{block_arrow(9.6, 14.4, right)}" style="{SOLID}"/>'
        return f"win-monitor-{side}", glyph_svg(near, arrow, far)

    if "space" in text or "desktop" in text:
        # Same shape as the monitor glyph, but the destination is drawn with a
        # broken border: a space you can't see right now, not a second screen.
        source, target = (0.5, 15.2) if right else (15.5, 0.5)
        near = f'<path d="{rounded_rect(source, 3, 8.3, 10)}" style="{OUTLINE}"/>'
        far = f'<path d="{rounded_rect(target, 3, 8.3, 10)}" style="{OUTLINE};{DASHED}"/>'
        arrow = f'<path d="{block_arrow(9.6, 14.4, right)}" style="{SOLID}"/>'
        return f"win-space-{side}", glyph_svg(near, arrow, far)

    # Otherwise the label names a fraction and the edges it hugs. Whichever
    # axis is named takes the fraction; the other one stays full.
    if "two third" in text:
        size, word = 2 / 3, "two-thirds"
    elif "third" in text:
        size, word = 1 / 3, "third"
    elif "quarter" in text or "corner" in text:
        size, word = 0.5, "quarter"
    elif "half" in text:
        size, word = 0.5, "half"
    elif "maximize" in text or "full" in text:
        size, word = 1.0, "full"
    else:
        return None  # a window action this doesn't know how to draw

    horizontal = "left" if "left" in text else "right" if "right" in text else None
    vertical = "top" if "top" in text else "bottom" if "bottom" in text else None

    x, w = (0.0, 1.0) if not horizontal else (0.0, size) if horizontal == "left" else (1 - size, size)
    y, h = (0.0, 1.0) if not vertical else (0.0, size) if vertical == "top" else (1 - size, size)

    name = "win-" + "-".join(part for part in (vertical, horizontal, word) if part)

    # Inset inside the frame's stroke, so the region sits flush against it —
    # except a maximised window, which would swallow the frame entirely.
    ix, iy, iw, ih = (3.0, 3.0, 18.0, 10.0) if w == h == 1.0 else (1.8, 1.8, 20.4, 12.4)
    region = f'<path d="{rounded_rect(ix + x * iw, iy + y * ih, w * iw, h * ih, 1)}" style="{SOLID}"/>' 
    return name, glyph_svg(FRAME, region)


def config_labels() -> dict[str, str]:
    """Read the ";; :label <binding> = <text>" lines out of kanata.kbd.

    Some mappings only make sense by intent: lalt+left is "prev word". kanata
    has nowhere to record that and BTT never sees these keys, so the config
    carries the labels in comments, where they sit next to the mapping they
    describe and stay invisible to kanata itself.
    """
    pattern = re.compile(r"^\s*;;\s*:label\s+(.+?)\s*=\s*(.+?)\s*$")
    return {
        m[1]: m[2]
        for line in KANATA_CFG.read_text().splitlines()
        if (m := pattern.match(line))
    }


def slug(name: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", name.lower())


def tidy(label: str) -> str:
    """Trim BTT's boilerplate. "Maximize Window to Top Half" -> "Top Half"."""
    label = " ".join(re.split(r"\s+or\s+", " ".join(label.split()))[0].split())
    trimmed = re.sub(r"^(Resize|Maximize)\s+[Ww]indow\s+(to\s+)?", "", label)
    return trimmed or label  # bare "Maximize Window" would trim to nothing


def btt_legends() -> dict[tuple[int, str], tuple[str, str]]:
    """Map (modifier mask, key) -> (what BetterTouchTool does, its group name).

    The group is what tells window management apart from everything else — far
    safer than sniffing labels, since "Docker Desktop" is an app, not a desktop.

    BTT nests a group's children inside the group's own BTTActionsToExecute, so
    this walks the whole preset rather than trusting a fixed depth.
    """
    preset = json.loads(BTT_PRESET.read_text())
    legends: dict[tuple[int, str], tuple[str, str]] = {}

    def label_for(node: dict) -> str:
        if notes := (node.get("BTTGestureNotes") or "").strip():
            return notes  # Kam's own label, always the best one
        if app := node.get("BTTAppToShowOrHide"):
            return Path(app).stem
        if named := node.get("BTTNamedTriggerToTrigger"):
            return named.replace("app_", "").replace("_", " ")
        # Kept whole: "Move Window One Space or Desktop Right" only says which
        # direction in its second half. tidy() trims it for display later.
        if name := (node.get("BTTPredefinedActionName") or "").strip():
            return " ".join(name.split())
        # Otherwise the trigger is a bare shell and its action sits one level
        # down. Only follow real actions: a *group's* children live in the same
        # field, and those are triggers in their own right.
        for action in node.get("BTTActionsToExecute", []):
            if action.get("BTTIsPureAction") and (label := label_for(action)):
                return label
        return ""

    def walk(node, group: str = "") -> None:
        if isinstance(node, dict):
            group = node.get("BTTGroupName") or group
            code = node.get("BTTShortcutKeyCode")
            if isinstance(code, int) and code >= 0 and node.get("BTTLayoutIndependentChar"):
                char = node["BTTLayoutIndependentChar"]
                key = BTT_TO_KANATA.get(char, char.lower())
                if label := label_for(node):
                    legends.setdefault(
                        (node.get("BTTShortcutModifierKeys") or 0, key), (label, group)
                    )
            for value in node.values():
                walk(value, group)
        elif isinstance(node, list):
            for value in node:
                walk(value, group)

    walk(preset)
    return legends


def split_forms(text: str) -> list[str]:
    """Split "(multi lsft lctl lalt u) (multi lctl lalt u)" into its two forms."""
    forms, depth, current = [], 0, ""
    for char in text:
        if char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
        if char == " " and depth == 0:
            if current:
                forms.append(current)
            current = ""
        else:
            current += char
    if current:
        forms.append(current)
    return forms


class Relabeller:
    """Turn a raw kanata binding into something a human can read."""

    def __init__(self, legends: dict[tuple[int, str], tuple[str, str]], labels: dict[str, str]):
        self.legends = legends
        self.labels = labels
        self.unmapped: set[str] = set()
        self.glyphs: dict[str, str] = {}

    def chord(self, mask: int, key: str, fallback: str) -> str:
        if found := self.legends.get((mask, key)):
            label, group = found
            if "window" in group.lower() and (glyph := window_glyph(label)):
                name, svg = glyph
                self.glyphs[name] = svg
                return f"$${name}$$"
            return tidy(label)
        self.unmapped.add(fallback)
        return fallback

    def __call__(self, binding: str) -> str:
        binding = binding.strip()

        # A label written in kanata.kbd beats anything derived here.
        if label := self.labels.get(binding):
            return label

        if m := re.fullmatch(r"lsft\+(.+)", binding):
            if symbol := SHIFTED.get(m[1]):
                return symbol

        # The shortcuts layer's three tiers, in order of specificity.
        if m := re.fullmatch(r"lsft\+lctl\+lalt\+lmet\+(.+)", binding):
            return self.chord(HYPER, m[1], f"hyper+{PRETTY.get(m[1], m[1])}")
        if m := re.fullmatch(r"lsft\+lctl\+lalt\+(.+)", binding):
            return self.chord(MEH, m[1], f"meh+{PRETTY.get(m[1], m[1])}")
        if m := re.fullmatch(r"\(multi lctl lalt (.+)\)|lctl\+lalt\+(.+)", binding):
            key = m[1] or m[2]
            return self.chord(CTRL_OPT, key, f"ctrl+opt+{PRETTY.get(key, key)}")
        if m := re.fullmatch(r"\(multi lsft lctl lalt (.+)\)", binding):
            return self.chord(MEH, m[1], f"meh+{PRETTY.get(m[1], m[1])}")

        # Constructs keymap-drawer leaves as raw text.
        if binding.startswith("(caps-word"):
            return "caps word"
        if binding.startswith("(switch"):
            return "⇧ smart"
        return PRETTY.get(binding, binding.lstrip("@"))


def relabel_key(key, relabel: Relabeller):
    """Rewrite one parsed key, unpacking tap-dance into a third legend."""
    if isinstance(key, str):
        return relabel(key)
    if not isinstance(key, dict):
        return key

    out = dict(key)
    for field in ("t", "h", "s"):
        value = out.get(field)
        if not isinstance(value, str):
            continue
        # tap-dance is the double-tap tier; keymap-drawer dumps it raw.
        if m := re.fullmatch(r"\(tap-dance \d+ \((.*)\)\)", value):
            forms = split_forms(m[1])
            out[field] = relabel(forms[0]) if forms else value
            if len(forms) > 1 and field == "t":
                # Double-tap sits above the tap legend. It carries no "2×"
                # marker: that only collides with the label on narrow keys, and
                # the three positions are explained in the README instead.
                out["s"] = relabel(forms[1])
        else:
            out[field] = relabel(value)
    return out


def colorize(layers: dict[str, list]) -> None:
    """Tag each key with its layer's colour, and layer-switch keys with the
    colour of the layer they lead to."""
    for name, keys in layers.items():
        for index, key in enumerate(keys):
            # A key with nothing but a tap legend is parsed as a bare string.
            if isinstance(key, str):
                if not key:
                    continue
                key = keys[index] = {"t": key}
            if not isinstance(key, dict):
                continue
            # Only colour keys this layer actually changes: leaving the
            # transparent ones plain is what makes the layer's shape readable.
            if key.get("type") in ("ghost", "trans"):
                continue
            legends = [v for f, v in key.items() if f != "type" and isinstance(v, str)]
            if not any(legends):
                continue  # a key this keyboard has but this layer leaves empty

            classes = [key["type"]] if key.get("type") else []
            if LAYER_COLORS.get(name):
                classes.append(f"lay-{slug(name)}")
            # A legend that names another layer is a key that switches to it.
            for legend in legends:
                if legend in layers and LAYER_COLORS.get(legend):
                    classes.append(f"trg-{slug(legend)}")
            if classes:
                key["type"] = " ".join(classes)


def stylesheet() -> str:
    """CSS for the layer colours. Opacity carries light vs dark mode, so the
    palette stays one colour per layer instead of two."""
    rules = []
    for name, color in LAYER_COLORS.items():
        if color:
            rules.append(f"g.layer-{name} text.label {{ fill: {color}; }}")
            rules.append(f"rect.key.lay-{slug(name)} {{ fill: {color}; fill-opacity: 0.10; }}")
    # After the layer rules, so a switch key wins over its own layer's tint.
    for name, color in LAYER_COLORS.items():
        if color:
            rules.append(
                f"rect.key.trg-{slug(name)} {{ fill: {color}; fill-opacity: 0.3; "
                f"stroke: {color}; stroke-width: 2; }}"
            )
    # Glyphs draw themselves in currentColor, so one rule themes them all.
    rules.append("use.glyph { color: #24292f; }")
    rules.append("use.glyph.no-op { color: #b0b6bd; }")
    rules.append("text.untouched { fill: #b0b6bd; }")
    # Layer names are links to that layer's diagram; the underline that
    # advertises it just reads as noise now the colours do the same job.
    rules.append("text.layer-activator { text-decoration: none; }")
    # Home keys: the same border, just darker. Neutral so it can't be confused
    # with the coloured borders that mark layer triggers, and the same weight so
    # it stays a hint rather than an emphasis.
    rules.append("rect.key.home { stroke: #8c9298; }")
    dark = [
        "use.glyph { color: #c9d1d9; }",
        "use.glyph.no-op { color: #596068; }",
        "text.untouched { fill: #6a7078; }",
        "rect.key.home { stroke: #949aa1; }",
    ] + [
        f"rect.key.lay-{slug(n)} {{ fill-opacity: 0.22; }}" for n, c in LAYER_COLORS.items() if c
    ] + [
        f"rect.key.trg-{slug(n)} {{ fill-opacity: 0.45; }}" for n, c in LAYER_COLORS.items() if c
    ]
    return "\n".join(rules) + "\n@media (prefers-color-scheme: dark) {\n" + "\n".join(dark) + "\n}"


def main() -> int:
    with tempfile.TemporaryDirectory() as tmp:
        tmp = Path(tmp)

        parsed = tmp / "parsed.yaml"
        subprocess.run(
            ["keymap", "parse", "-k", str(KANATA_CFG), "-o", str(parsed)],
            check=True,
        )
        keymap = yaml.safe_load(parsed.read_text())

        # keymap-drawer laid the layers out on one of its stock layouts; find
        # which key sits at which position so we can re-lay them on the MacBook.
        import keymap_drawer.parse.kanata as kanata_parser

        chosen = keymap["layout"]
        sources = json.loads(kanata_parser.PHYSICAL_LAYOUTS.read_text())
        source = next(s for s in sources if s["physical_layout"] == chosen)
        # tkl uses a lookalike glyph for comma; kanata and this repo use ",".
        order = [k.replace("⸴", ",") for k in source["defsrc"]]

        mbp = json.loads(MBP_LAYOUT.read_text())["keys"]
        relabel = Relabeller(btt_legends(), config_labels())

        by_layer = {name: dict(zip(order, keys)) for name, keys in keymap["layers"].items()}

        # A position kanata never mentions is empty on every layer; one that is
        # empty on only some layers is mapped there and set to ∅ (no-op).
        mapped = {key for key in order if any(layer.get(key) for layer in by_layer.values())}

        layers = {}
        for name, by_name in by_layer.items():
            keys = []
            for slot in mbp:
                key = slot["key"]
                if key in SYNTHETIC:
                    keys.append(dict(SYNTHETIC[key]))
                elif not by_name.get(key) and key in mapped:
                    relabel.glyphs["no-op"] = NO_OP_GLYPH
                    keys.append({"t": "$$no-op$$"})
                else:
                    keys.append(relabel_key(by_name.get(key, ""), relabel))
            layers[name] = keys

        # The pass-through marker reads as a down arrow at this size, and a
        # layer is easier to read as "only what it changes" anyway.
        for keys in layers.values():
            for key in keys:
                if isinstance(key, dict) and key.get("type") == "trans":
                    key["t"] = ""

        # The base layer is the exception: with everything blank there is no
        # keyboard left to locate the trigger keys against. Fill the untouched
        # keys back in, faint enough to stay out of the way.
        base = layers[next(iter(layers))]
        for slot, key in zip(mbp, base):
            name = slot["key"]
            if name in SYNTHETIC or name not in mapped:
                continue
            if isinstance(key, dict) and key.get("type") == "trans":
                key["t"] = DEFAULT_LEGENDS.get(name, name)
                key["type"] = "untouched"
        # Fn only dictates from the base layer's point of view; elsewhere it is
        # the same hardware key, so drop the hold legend to cut the noise.
        for name, keys in layers.items():
            if name != next(iter(layers)):
                for key in keys:
                    if isinstance(key, dict) and key.get("t") == "fn":
                        key.pop("h", None)

        colorize(layers)

        # Mark the home keys on every layer — without them there is no way to
        # count across to a key once the legends stop looking like a keyboard.
        # It goes on the border rather than in a legend: f and j carry up to
        # three mappings each, and a marker among them reads as a typo.
        for keys in layers.values():
            for index, slot in enumerate(mbp):
                if slot["key"] not in ("f", "j"):
                    continue
                if isinstance(keys[index], str):
                    keys[index] = {"t": keys[index]}
                key = keys[index]
                key["type"] = " ".join(filter(None, [key.get("type", ""), "home"]))
        for name in layers:
            if name not in LAYER_COLORS:
                print(f"-> no colour set for layer '{name}' — add one in {Path(__file__).name}")

        layout_json = tmp / "mbp-layout.json"
        layout_json.write_text(
            json.dumps([{k: key[k] for k in ("x", "y", "w", "h")} for key in mbp])
        )

        final = tmp / "keymap.yaml"
        final.write_text(
            yaml.safe_dump(
                {
                    "layout": {"qmk_info_json": str(layout_json)},
                    "layers": layers,
                    "draw_config": {
                        "dark_mode": "auto",
                        # Legends here are words ("Spotify"), not single
                        # glyphs, so the keys need more room than the default.
                        "key_h": 76,
                        "shrink_wide_legends": 8,
                        "svg_extra_style": stylesheet(),
                        "glyphs": relabel.glyphs,
                        "glyph_tap_size": 20,
                        "glyph_hold_size": 15,
                        "glyph_shifted_size": 15,
                        "footer_text": "Generated by scripts/keymap-diagram.sh "
                                       "from _configs/kanata.kbd — do not edit by hand",
                    },
                },
                sort_keys=False,
                allow_unicode=True,
            )
        )

        OUTPUT_SVG.parent.mkdir(exist_ok=True)
        subprocess.run(
            ["keymap", "draw", str(final), "-o", str(OUTPUT_SVG)], check=True
        )

    if relabel.unmapped:
        print(f"-> {len(relabel.unmapped)} chords have no BetterTouchTool binding, "
              "drawn as the raw chord:")
        for chord in sorted(relabel.unmapped):
            print(f"     {chord}")
    print(f"✓ wrote {OUTPUT_SVG.relative_to(REPO)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
