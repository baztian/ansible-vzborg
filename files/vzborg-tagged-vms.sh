#!/bin/bash
# Run vzborg sequentially for all config files except 'default'
# Only VMs tagged with 'backup' or 'backup-<config_name>' are included

set -e  # Exit on any error

CONFIG_DIR="/etc/vzborg"
EXIT_CODE=0

# Find all files in /etc/vzborg/ except 'default'
for config_file in "$CONFIG_DIR"/*; do
    [ -f "$config_file" ] || continue
    config_name=$(basename "$config_file")
    [ "$config_name" = "default" ] && continue
    # Get list of VMs with 'backup' tag or 'backup-<config_name>' tag
    VM_IDS=$(pvesh get /cluster/resources --type vm --output-format json | \
        jq -r --arg config "$config_name" \
        'map(select(.tags and (.tags | split(";") | any(. == "backup" or . == ("backup-" + $config))))) | map(.vmid) | join(" ")')
    if [ -z "$VM_IDS" ]; then
        echo "Warning: No VMs found with 'backup' or 'backup-$config_name' tag for config $config_name" >&2
        continue
    fi
    echo "Running vzborg with config: $config_name for VMs: $VM_IDS"
    if ! /usr/local/bin/vzborg backup -i "$VM_IDS" -c "$config_name"; then
        echo "Error: vzborg failed for config $config_name" >&2
        EXIT_CODE=1
        # Continue to next config instead of exiting immediately
    fi
done

exit $EXIT_CODE