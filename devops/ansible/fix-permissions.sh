#!/bin/bash
# Fix permissions for Ansible directory to avoid world-writable warning

echo "Fixing directory permissions..."

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR" || exit 1

# Remove world-writable permissions
chmod 755 .

# Fix permissions for ansible.cfg
if [ -f "ansible.cfg" ]; then
    chmod 644 ansible.cfg
fi

# Fix permissions for inventory directory
if [ -d "inventory" ]; then
    chmod 755 inventory
    chmod 644 inventory/*.yml 2>/dev/null
fi

# Fix permissions for playbooks directory
if [ -d "playbooks" ]; then
    chmod 755 playbooks
    chmod 644 playbooks/*.yml 2>/dev/null
fi

echo "✓ Permissions fixed!"
echo "You can now run ansible-playbook without the warning."

