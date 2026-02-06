#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/coco-de/bmad.git"
TMPDIR=$(mktemp -d)
CLAUDE_DIR="$HOME/.claude"

cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

echo "Installing BMAD Method v6..."

git clone --depth 1 "$REPO" "$TMPDIR/bmad" 2>/dev/null

mkdir -p "$CLAUDE_DIR/config/bmad" "$CLAUDE_DIR/commands/bmad" "$CLAUDE_DIR/skills/bmad"

cp -r "$TMPDIR/bmad/config/bmad/" "$CLAUDE_DIR/config/bmad/"
cp -r "$TMPDIR/bmad/commands/bmad/" "$CLAUDE_DIR/commands/bmad/"
cp -r "$TMPDIR/bmad/skills/bmad/" "$CLAUDE_DIR/skills/bmad/"

echo ""
echo "BMAD Method v6 installed successfully!"
echo ""
echo "Installed to:"
echo "  $CLAUDE_DIR/config/bmad/    (settings, helpers, templates)"
echo "  $CLAUDE_DIR/commands/bmad/  (15 slash commands)"
echo "  $CLAUDE_DIR/skills/bmad/    (9 agent skills)"
echo ""
echo "Next steps:"
echo "  1. Edit ~/.claude/config/bmad/config.yaml to set your user_name"
echo "  2. Open Claude Code in your project and run: /bmad:workflow-init"
echo ""
