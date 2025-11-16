#!/bin/bash
# Quick fix for all Ansible errors

echo "========================================"
echo "Ansible Quick Fix"
echo "========================================"
echo ""

# 1. Fix permissions
echo "Step 1: Fixing directory permissions..."
chmod 755 .
chmod 644 ansible.cfg 2>/dev/null
chmod 755 inventory 2>/dev/null
chmod 644 inventory/*.yml 2>/dev/null
chmod 755 playbooks 2>/dev/null
chmod 644 playbooks/*.yml 2>/dev/null
echo "✓ Permissions fixed"
echo ""

# 2. Update inventory
echo "Step 2: Updating inventory from Terraform..."
if [ -f "update-inventory-from-terraform.sh" ]; then
    chmod +x update-inventory-from-terraform.sh
    ./update-inventory-from-terraform.sh
else
    echo "⚠ Update script not found. Please update inventory manually."
    echo "Get IPs: cd ../terraform && terraform output"
fi
echo ""

# 3. Check inventory
echo "Step 3: Checking inventory..."
if [ -f "inventory/hosts.yml" ]; then
    # Check if IPs are empty
    if grep -q "ansible_host: $" inventory/hosts.yml || grep -q "ansible_host: $" inventory/hosts.yml; then
        echo "✗ Inventory has empty IP addresses!"
        echo ""
        echo "Please run:"
        echo "  ./update-inventory-from-terraform.sh"
        echo ""
        echo "Or manually edit inventory/hosts.yml with IPs from:"
        echo "  cd ../terraform && terraform output"
        exit 1
    fi
    
    # Test inventory parsing
    ansible-inventory --list > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✓ Inventory is valid"
    else
        echo "✗ Inventory has syntax errors"
        exit 1
    fi
else
    echo "✗ Inventory file not found!"
    exit 1
fi
echo ""

# 4. Test connectivity
echo "Step 4: Testing connectivity..."
ansible all -m ping

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "✓ All fixes applied successfully!"
    echo "========================================"
    echo ""
    echo "You can now run:"
    echo "  ansible-playbook playbooks/site.yml"
    echo ""
else
    echo ""
    echo "⚠ Connectivity test failed"
    echo "This is normal if instances are still starting up."
    echo "Wait 2-3 minutes and try: ansible all -m ping"
    echo ""
fi

