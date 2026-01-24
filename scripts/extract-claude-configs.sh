#!/bin/bash
# Extract Claude Code configurations from multiple projects for comparison
# Each unique filename becomes a folder with project-prefixed versions inside

set -euo pipefail

# =============================================================================
# CONFIGURATION - Add/remove source paths here
# Format: "project-name|/path/to/project"
# =============================================================================
SOURCES=(
    "inmobiliaria-main|/home/hata/projects/raiz/inmobiliaria/main"
    "opensearch-dashboard|/home/hata/projects/raiz/acustica_marina/opensearch-dashboard"
    "bm-sop|/home/hata/projects/raiz/blumar/bm-sop_backup-20250924/bm-sop"
    "crediopciones|/home/hata/projects/personal/crediopciones"
    "teatro-uch|/home/hata/projects/personal/teatro-uch"
)

# Output directory
OUTPUT_DIR="/home/hata/projects/personal/dotfiles/templates/claude-project-analysis"

# =============================================================================
# SCRIPT
# =============================================================================

# Clean and create output directory
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo "Extracting Claude configs to: $OUTPUT_DIR"
echo "Sources: ${#SOURCES[@]}"
echo ""

for source in "${SOURCES[@]}"; do
    IFS='|' read -r project_name project_path <<< "$source"
    echo "Processing: $project_name ($project_path)"

    # Copy CLAUDE.md
    if [[ -f "$project_path/CLAUDE.md" ]]; then
        mkdir -p "$OUTPUT_DIR/CLAUDE.md"
        cp "$project_path/CLAUDE.md" "$OUTPUT_DIR/CLAUDE.md/${project_name}.md"
        echo "  - CLAUDE.md"
    fi

    # Copy settings.local.json
    if [[ -f "$project_path/.claude/settings.local.json" ]]; then
        mkdir -p "$OUTPUT_DIR/settings.local.json"
        cp "$project_path/.claude/settings.local.json" "$OUTPUT_DIR/settings.local.json/${project_name}.json"
        echo "  - settings.local.json"
    fi

    # Process subdirectories: hooks, skills, memories, agents, commands, plans
    for subdir in hooks skills memories agents commands plans; do
        src_dir="$project_path/.claude/$subdir"
        if [[ -d "$src_dir" ]]; then
            # Find all files recursively
            while IFS= read -r -d '' file; do
                # Get relative path from subdir
                rel_path="${file#$src_dir/}"
                # Get filename without path
                filename=$(basename "$file")
                # Get subdirectory path if nested
                subpath=$(dirname "$rel_path")

                if [[ "$subpath" == "." ]]; then
                    target_dir="$OUTPUT_DIR/$subdir/$filename"
                else
                    target_dir="$OUTPUT_DIR/$subdir/$subpath/$filename"
                fi

                mkdir -p "$target_dir"

                # Determine extension
                ext="${filename##*.}"
                if [[ "$ext" == "$filename" ]]; then
                    # No extension
                    cp "$file" "$target_dir/${project_name}"
                else
                    # Has extension - use it
                    cp "$file" "$target_dir/${project_name}.${ext}"
                fi
            done < <(find "$src_dir" -type f -print0 2>/dev/null)

            # Count files
            count=$(find "$src_dir" -type f 2>/dev/null | wc -l)
            if [[ $count -gt 0 ]]; then
                echo "  - $subdir/ ($count files)"
            fi
        fi
    done
    echo ""
done

echo "Done! Structure:"
find "$OUTPUT_DIR" -type d | head -30 | sed 's|'"$OUTPUT_DIR"'|.|'
echo ""
echo "Total files extracted:"
find "$OUTPUT_DIR" -type f | wc -l
