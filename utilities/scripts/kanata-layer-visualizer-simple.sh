#!/bin/bash
# Kanata Layer Visualizer (Simple Version)
#
# This script monitors Kanata's log output to display the current layer.
# Requires Kanata to be started with log-layer-changes enabled in config.
#
# Usage:
#   ./kanata-layer-visualizer-simple.sh

# ANSI color codes
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
DIM='\033[2m'
RESET='\033[0m'

# Function to display layer information
show_layer() {
    local layer=$1
    clear

    echo -e "${BOLD}${GREEN}================================================================================${RESET}"
    echo -e "${BOLD}${GREEN}  KANATA LAYER VISUALIZER${RESET}"
    echo -e "${BOLD}${GREEN}================================================================================${RESET}"
    echo ""
    echo -e "${BOLD}${YELLOW}Current Layer: $(echo $layer | tr '[:lower:]' '[:upper:]')${RESET}"

    case "$layer" in
        "base")
            echo -e "${DIM}Description: Base layer with home row modifiers${RESET}"
            echo ""
            echo -e "${BOLD}${CYAN}Active Key Mappings:${RESET}"
            echo -e "${DIM}--------------------------------------------------------------------------------${RESET}"
            echo "  Tab (hold)      → Numbers layer"
            echo "  Esc/Caps (hold) → Shortcuts layer"
            echo "  Return (hold)   → Shortcuts layer"
            echo "  Space (hold)    → Navigation layer"
            echo "  E/I (hold)      → Jump layer"
            echo "  V/N (hold)      → Symbols layer"
            echo ""
            echo -e "${BOLD}Home Row Mods:${RESET}"
            echo "  A → tap:a hold:Ctrl  |  J → tap:j hold:Shift"
            echo "  S → tap:s hold:Alt   |  K → tap:k hold:Meta"
            echo "  D → tap:d hold:Meta  |  L → tap:l hold:Alt"
            echo "  F → tap:f hold:Shift |  ; → tap:; hold:Ctrl"
            echo "  G → tap:g hold:Ctrl+Meta"
            echo "  H → tap:h hold:Alt+Shift"
            ;;
        "numbers")
            echo -e "${DIM}Description: Number pad layout${RESET}"
            echo ""
            echo -e "${BOLD}${CYAN}Number Pad Layout:${RESET}"
            echo -e "${DIM}--------------------------------------------------------------------------------${RESET}"
            echo "         7    8    9    -"
            echo "         4    5    6    +"
            echo "         1    2    3  Enter"
            echo "         0 (space)  ."
            echo ""
            echo "  Del  =  /  *  (top row)"
            ;;
        "navigation")
            echo -e "${DIM}Description: Arrow keys and navigation${RESET}"
            echo ""
            echo -e "${BOLD}${CYAN}Navigation Keys:${RESET}"
            echo -e "${DIM}--------------------------------------------------------------------------------${RESET}"
            echo "  Arrows:  J←  K↓  I↑  L→"
            echo "  Words:   U (prev/home)  O (next/end)"
            echo "  Pages:   P (up)  ; (down)"
            echo "  Tabs:    M (prev)  . (next)"
            echo "  Caps:    tap (Caps Word)  hold (Caps Lock)"
            ;;
        "shortcuts")
            echo -e "${DIM}Description: Meh shortcuts (Shift+Ctrl+Alt+key)${RESET}"
            echo ""
            echo -e "${BOLD}${CYAN}Shortcut Keys:${RESET}"
            echo -e "${DIM}--------------------------------------------------------------------------------${RESET}"
            echo "  All keys send Meh+key on tap"
            echo "  All keys send Hyper+key on hold"
            echo "  (Meh = Shift+Ctrl+Alt, Hyper = Shift+Ctrl+Alt+Meta)"
            ;;
        "symbols"|"Symbols")
            echo -e "${DIM}Description: Special characters on home row${RESET}"
            echo ""
            echo -e "${BOLD}${CYAN}Symbol Mappings:${RESET}"
            echo -e "${DIM}--------------------------------------------------------------------------------${RESET}"
            echo "  Q → \\    E → =    R → -    Tab → \`"
            echo "  Home row: ! @ # \$ % ^ & * ( )"
            echo "  Shifted symbols accessible on home row"
            ;;
        "jump")
            echo -e "${DIM}Description: Layer switching hub${RESET}"
            echo ""
            echo -e "${BOLD}${CYAN}Available Actions:${RESET}"
            echo -e "${DIM}--------------------------------------------------------------------------------${RESET}"
            echo "  Space    → Switch to Mirror layer"
            echo "  E/I      → Switch to Plain layer"
            echo "  Caps     → Switch to Disabled layer"
            echo "  Q/W/Esc  → Return to Base layer"
            ;;
        "mirror")
            echo -e "${DIM}Description: One-handed mirrored layout${RESET}"
            echo ""
            echo -e "${BOLD}${CYAN}Mirror Mode:${RESET}"
            echo -e "${DIM}--------------------------------------------------------------------------------${RESET}"
            echo "  Right side of keyboard mirrors left side"
            echo "  Useful for one-handed typing"
            echo "  Hold Esc > 1s to return to base"
            ;;
        "plain")
            echo -e "${DIM}Description: Normal keyboard (no modifiers/layers)${RESET}"
            echo ""
            echo -e "${BOLD}${CYAN}Plain Mode:${RESET}"
            echo -e "${DIM}--------------------------------------------------------------------------------${RESET}"
            echo "  All keys behave normally"
            echo "  No home row modifiers"
            echo "  No layer triggers"
            echo "  Hold Esc > 1s to return to base"
            ;;
        "disabled")
            echo -e "${DIM}Description: Keyboard disabled for security${RESET}"
            echo ""
            echo -e "${BOLD}${CYAN}Disabled Mode:${RESET}"
            echo -e "${DIM}--------------------------------------------------------------------------------${RESET}"
            echo "  All keys are blocked"
            echo "  Hold Esc > 1s to return to base"
            ;;
        *)
            echo -e "${DIM}Description: Unknown layer${RESET}"
            ;;
    esac

    echo ""
    echo -e "${DIM}--------------------------------------------------------------------------------${RESET}"
    echo -e "${DIM}Monitoring Kanata layer changes... Press Ctrl+C to exit${RESET}"
}

# Check if Kanata is running
if ! pgrep -x "kanata" > /dev/null; then
    echo "Error: Kanata is not running!"
    echo ""
    echo "Start Kanata with:"
    echo "  sudo kanata -c ~/.configs/kanata.kbd"
    exit 1
fi

# Get Kanata PID
KANATA_PID=$(pgrep -x "kanata")

# Show initial state
show_layer "base"

# Monitor Kanata logs
# Note: This requires Kanata to be running with log-layer-changes enabled
# and we need to capture its output

# Try to find Kanata's log output
if command -v log >/dev/null 2>&1; then
    # macOS unified logging
    log stream --predicate 'process == "kanata"' --style syslog 2>/dev/null | while read -r line; do
        if echo "$line" | grep -q "Entered layer"; then
            layer=$(echo "$line" | sed -n 's/.*Entered layer \([^ ]*\).*/\1/p')
            if [ -n "$layer" ]; then
                show_layer "$layer"
            fi
        fi
    done
else
    echo ""
    echo "Note: Unable to monitor logs automatically."
    echo "This script works best when Kanata is started in a terminal where you can see its output."
    echo ""
    echo "Alternative: Use the Python version (kanata-layer-visualizer.py) with TCP support:"
    echo "  1. Start Kanata with: sudo kanata -c ~/.configs/kanata.kbd -p 12321"
    echo "  2. Run: python3 kanata-layer-visualizer.py"
fi
