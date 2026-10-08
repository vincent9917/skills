#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
SOURCE_ROOT="${SCRIPT_DIR}/.claude/skills"
DEST_ROOT="${AGENTS_SKILLS_DIR:-${HOME}/.agents/skills}"
FORCE=0
DRY_RUN=0

SKILLS=(
  # 项目理解
  prime-codebase
  prime-backend
  prime-frontend

  # 产品与架构
  plan-create-prd
  plan-architecture

  # 实施计划
  piv-plan-implementation

  # 开发
  piv-implement

  # 验证与审查
  piv-validate
  piv-review-changes
  piv-review-pr
)

usage() {
  cat <<'EOF'
Install selected skills from this repository into ~/.agents/skills using
symbolic links. Repository updates are therefore available immediately.

Usage:
  ./install-codex-skills.sh [options]

Options:
  --dest DIR   Install into DIR instead of ~/.agents/skills.
  --force      Back up and replace existing files, directories, or links.
  --dry-run    Show what would be installed without changing any files.
  -h, --help   Show this help message.

Environment:
  AGENTS_SKILLS_DIR  Alternative destination directory. --dest takes priority.
EOF
}

while (($# > 0)); do
  case "$1" in
    --dest)
      if (($# < 2)); then
        echo "error: --dest requires a directory" >&2
        exit 2
      fi
      DEST_ROOT="$2"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ ! -d "$SOURCE_ROOT" ]]; then
  echo "error: source skill directory not found: $SOURCE_ROOT" >&2
  exit 1
fi

for skill in "${SKILLS[@]}"; do
  if [[ ! -f "$SOURCE_ROOT/$skill/SKILL.md" ]]; then
    echo "error: missing source skill: $SOURCE_ROOT/$skill/SKILL.md" >&2
    exit 1
  fi
done

conflicts=()
for skill in "${SKILLS[@]}"; do
  target="$DEST_ROOT/$skill"
  if [[ (-e "$target" || -L "$target") ]] && ! { [[ -L "$target" ]] && [[ "$target" -ef "$SOURCE_ROOT/$skill" ]]; }; then
    conflicts+=("$skill")
  fi
done

if ((${#conflicts[@]} > 0 && FORCE == 0)); then
  echo "error: the following destinations exist but are not links to this repository:" >&2
  printf '  - %s\n' "${conflicts[@]}" >&2
  echo "Re-run with --force to back them up and replace them with symbolic links." >&2
  exit 1
fi

if ((DRY_RUN == 1)); then
  echo "Destination: $DEST_ROOT"
  for skill in "${SKILLS[@]}"; do
    target="$DEST_ROOT/$skill"
    if [[ ! -e "$target" && ! -L "$target" ]]; then
      echo "LINK     $skill -> $SOURCE_ROOT/$skill"
    elif [[ -L "$target" ]] && [[ "$target" -ef "$SOURCE_ROOT/$skill" ]]; then
      echo "CURRENT  $skill"
    else
      echo "RELINK   $skill (existing destination will be backed up)"
    fi
  done
  exit 0
fi

mkdir -p "$DEST_ROOT"

timestamp="$(date +%Y%m%d-%H%M%S)"
backup_root="$DEST_ROOT/.backup-selected-skills-$timestamp"
stage_root="$(mktemp -d "$DEST_ROOT/.install-selected-skills.XXXXXX")"

cleanup() {
  if [[ -n "${stage_root:-}" && -d "$stage_root" ]]; then
    rm -rf -- "$stage_root"
  fi
}
trap cleanup EXIT

for skill in "${SKILLS[@]}"; do
  target="$DEST_ROOT/$skill"

  if [[ -L "$target" ]] && [[ "$target" -ef "$SOURCE_ROOT/$skill" ]]; then
    echo "CURRENT  $skill"
    continue
  fi

  staged="$stage_root/$skill"
  ln -s "$SOURCE_ROOT/$skill" "$staged"

  if [[ -e "$target" || -L "$target" ]]; then
    mkdir -p "$backup_root"
    mv "$target" "$backup_root/$skill"
    echo "BACKUP   $skill -> $backup_root/$skill"
  fi

  mv "$staged" "$target"
  echo "LINK     $skill -> $SOURCE_ROOT/$skill"
done

echo
echo "Linked selected skills into: $DEST_ROOT"
if [[ -d "$backup_root" ]]; then
  echo "Previous versions were backed up to: $backup_root"
fi
echo "Codex will detect the installed skills automatically; restart Codex if they do not appear."
