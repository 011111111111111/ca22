#!/bin/bash
# Test connectivity and run Ansible playbooks

echo "========================================"
echo "Testing Ansible Setup"
echo "========================================"
echo ""

# Fix permissions first
chmod 755 . 2>/dev/null
chmod 644 ansible.cfg inventory/*.yml playbooks/*.yml 2>/dev/null

# Test inventory
echo "Step 1: Validating inventory..."
ansible-inventory --list > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "✗ Inventory validation failed!"
    exit 1
fi
echo "✓ Inventory is valid"
echo ""

# Test connectivity
echo "Step 2: Testing connectivity to all hosts..."
echo "This may take a moment..."
ansible all -m ping

if [ $? -ne 0 ]; then
    echo ""
    echo "✗ Connection test failed!"
    echo ""
    echo "Possible issues:"
    echo "  1. Instances are still starting (wait 2-3 minutes)"
    echo "  2. SSH key path is incorrect"
    echo "  3. Security groups don't allow SSH"
    echo ""
    echo "Test SSH manually:"
    echo "  ssh -i /home/sduse/.ssh/devops.pem ubuntu@65.2.142.108"
    exit 1
fi

echo ""
echo "✓ All hosts are reachable!"
echo ""

# Ask to proceed
read -p "Do you want to run the Ansible playbooks now? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "You can run it later with:"
    echo "  ansible-playbook playbooks/site.yml"
    exit 0
fi

echo ""
echo "Step 3: Running Ansible playbooks..."
echo "This will take 10-15 minutes..."
echo ""

ansible-playbook playbooks/site.yml

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
    echo "✗ Deployment failed. Check errors above."
    echo "Run with -vvv for more details:"
    echo "  ansible-playbook playbooks/site.yml -vvv"
fi

