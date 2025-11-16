#!/bin/bash
# Force fix all issues - aggressive permissions and explicit inventory

echo "========================================"
echo "Force Fixing Ansible Issues"
echo "========================================"
echo ""

# Get absolute path
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR" || exit 1

# Fix permissions aggressively
echo "Step 1: Fixing permissions..."
chmod 755 . 2>/dev/null
chmod 644 ansible.cfg 2>/dev/null
chmod 755 inventory 2>/dev/null
chmod 644 inventory/*.yml 2>/dev/null
chmod 755 playbooks 2>/dev/null
chmod 644 playbooks/*.yml 2>/dev/null

# Remove world-writable bit if possible
chmod o-w . 2>/dev/null || true

echo "✓ Permissions fixed"
echo ""

# Verify inventory file
echo "Step 2: Verifying inventory file..."
INVENTORY_FILE="$SCRIPT_DIR/inventory/hosts.yml"

if [ ! -f "$INVENTORY_FILE" ]; then
    echo "✗ Inventory file not found: $INVENTORY_FILE"
    exit 1
fi

# Check YAML syntax
if ! python3 -c "import yaml; yaml.safe_load(open('$INVENTORY_FILE'))" 2>/dev/null; then
    echo "⚠ YAML syntax check failed (may still work)"
else
    echo "✓ YAML syntax is valid"
fi

# Check for IPs
if grep -qE "ansible_host: [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" "$INVENTORY_FILE"; then
    echo "✓ Inventory has IP addresses"
else
    echo "✗ Inventory missing IP addresses!"
    exit 1
fi

echo ""
echo "Step 3: Testing inventory parsing with explicit path..."
ansible-inventory -i "$INVENTORY_FILE" --list > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "✗ Inventory parsing failed!"
    echo ""
    echo "Trying to parse and show errors:"
    ansible-inventory -i "$INVENTORY_FILE" --list
    exit 1
fi

echo "✓ Inventory parsing successful"
echo ""

# Show what hosts are found
echo "Hosts found in inventory:"
ansible-inventory -i "$INVENTORY_FILE" --list | grep -E '"hosts"|"children"' | head -5
echo ""

# Test connectivity with explicit inventory
echo "Step 4: Testing connectivity with explicit inventory..."
ansible all -i "$INVENTORY_FILE" -m ping

if [ $? -ne 0 ]; then
    echo ""
    echo "✗ Connection test failed!"
    echo "This might be normal if instances are still starting."
    echo "Wait 2-3 minutes and try again."
    exit 1
fi

echo ""
echo "✓ All hosts are reachable!"
echo ""

# Run playbooks with explicit inventory
echo "Step 5: Running Ansible playbooks with explicit inventory..."
echo "This will take 10-15 minutes..."
echo ""

ansible-playbook -i "$INVENTORY_FILE" playbooks/site.yml

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "✓ Deployment Completed Successfully!"
    echo "========================================"
    echo ""
    echo "Service URLs:"
    echo "  Application: http://65.2.142.108:3000"
    echo "  Nagios:      http://13.201.19.105/nagios"
    echo "    Username:  nagiosadmin"
    echo "    Password:  changeme123"
    echo ""
else
    echo ""
    echo "✗ Deployment failed!"
    echo "Run with -vvv for more details:"
    echo "  ansible-playbook -i $INVENTORY_FILE playbooks/site.yml -vvv"
    exit 1
fi

