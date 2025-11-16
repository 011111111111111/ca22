#!/bin/bash
# Check if inventory file exists and is properly configured

INVENTORY_FILE="inventory/hosts.yml"

echo "Checking Ansible inventory..."

if [ ! -f "$INVENTORY_FILE" ]; then
    echo "✗ Error: $INVENTORY_FILE not found!"
    echo ""
    echo "Please run:"
    echo "  ./update-inventory-from-terraform.sh"
    echo ""
    echo "Or manually create the inventory file with your server IPs."
    exit 1
fi

echo "✓ Inventory file exists: $INVENTORY_FILE"
echo ""

# Check if it has placeholder values
if grep -q "{{ app_public_ip }}" "$INVENTORY_FILE" || \
   grep -q "{{ db_public_ip }}" "$INVENTORY_FILE" || \
   grep -q "{{ nagios_public_ip }}" "$INVENTORY_FILE"; then
    echo "✗ Warning: Inventory file contains placeholder values!"
    echo ""
    echo "Please update the inventory file with actual IP addresses:"
    echo "  1. Run: cd ../terraform && terraform output"
    echo "  2. Edit: $INVENTORY_FILE"
    echo "  3. Replace placeholders with actual IPs"
    echo ""
    echo "Or run: ./update-inventory-from-terraform.sh"
    exit 1
fi

# Check if it has actual IP addresses
if grep -qE "ansible_host: [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" "$INVENTORY_FILE"; then
    echo "✓ Inventory file contains IP addresses"
else
    echo "✗ Warning: Inventory file may not have valid IP addresses"
fi

# Test inventory parsing
echo ""
echo "Testing inventory parsing..."
ansible-inventory --list > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✓ Inventory file is valid"
    echo ""
    echo "Hosts found:"
    ansible-inventory --list | grep -E '"hosts"|"children"' | head -10
else
    echo "✗ Error: Inventory file has syntax errors"
    echo ""
    echo "Please check the YAML syntax in $INVENTORY_FILE"
    exit 1
fi

echo ""
echo "✓ Inventory check complete!"

