#!/bin/bash
# clear_all_caches.sh - Clear all circuit-synth caches for fresh testing

echo "🧹 Clearing all circuit-synth caches..."

# 1. Main circuit_synth cache directory
CACHE_DIR="$HOME/.cache/circuit_synth"
if [ -d "$CACHE_DIR" ]; then
    echo "  📁 Removing $CACHE_DIR"
    rm -rf "$CACHE_DIR"
    echo "     ✅ Removed main cache directory"
else
    echo "     ℹ️  No main cache directory found"
fi

# 2. Remove any Python __pycache__ directories in the project
echo "  🐍 Removing Python __pycache__ directories"
find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null
echo "     ✅ Removed Python cache files"

# 3. Clear UV caches (optional - these are package caches, not symbol caches)
echo "  📦 Clearing UV package caches (optional)"
uv cache clean 2>/dev/null || echo "     ℹ️  UV cache clean not available"

# 4. Remove any temporary files
echo "  🗑️  Removing temporary files"
find /tmp -name "*circuit*" -type f -user "$(whoami)" 2>/dev/null | head -5 | while read file; do
    echo "     Removing: $file"
    rm -f "$file"
done

# 5. Clear any environment variables that might affect caching
echo "  🌍 Clearing cache environment variables"
unset CIRCUIT_SYNTH_CACHE_DIR
unset RUST_LOG

echo "
🎯 CACHE CLEARING COMPLETE!

To test lazy loading from fresh state:

1. Run the example:
   uv run python examples/example_kicad_project.py

2. Check the logs for lazy loading messages:
   - Look for 'Found symbol file by name' (Strategy 1)
   - Look for 'Found symbol via ripgrep' (Strategy 2)  
   - Look for 'Found symbol via Python grep' (Strategy 3)
   - Should NOT see 'Building complete symbol library index'

3. Time the execution:
   time uv run python examples/example_kicad_project.py

Expected results:
- First run: ~0.5-1.0 seconds (lazy loading)
- Subsequent runs: ~0.3-0.5 seconds (cached)
- Should NOT see 17+ second delay on first run

🧪 Test Commands:
# Basic test
uv run python examples/example_kicad_project.py

# With timing
time uv run python examples/example_kicad_project.py

# With debug logging
PYTHONPATH=. python -c \"
import logging
logging.basicConfig(level=logging.DEBUG)
from examples.example_kicad_project import *
\"
"