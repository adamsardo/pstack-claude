#!/bin/sh
echo "pstack skills reference each other by name (poteto-mode, principle-*, architect, arena, interrogate, reflect, and others). Most are user-invoked only, so the Skill tool refuses them. When a pstack skill or playbook names one, Read ${CLAUDE_PLUGIN_ROOT}/skills/<name>/SKILL.md directly."
config="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/pstack-models.md"
[ -f "$config" ] || exit 0
echo
echo "pstack model configuration (from $config). These override the skill defaults; a role not listed here uses its skill default."
cat "$config"
