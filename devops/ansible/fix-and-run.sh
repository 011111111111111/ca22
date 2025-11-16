#!/bin/bash
# Fix all issues and run Ansible

set -e

echo "========================================"
echo "Fixing Issues and Running Ansible"
echo "========================================"
echo ""

# Step 1: Fix permissions
echo "Step 1: Fixing directory permissions..."
chmod 755 . 2>/dev/null || true
chmod 644 ansible.cfg 2>/dev/null || true
chmod 755 inventory 2>/dev/null || true
chmod 644 inventory/*.yml 2>/dev/null || true
chmod 755 playbooks 2>/dev/null || true
chmod 644 playbooks/*.yml 2>/dev/null || true
echo "✓ Permissions fixed"
echo ""

# Step 2: Verify inventory has IPs
echo "Step 2: Verifying inventory..."
if [ ! -f "inventory/hosts.yml" ]; then
    echo "✗ Inventory file not found!"
    exit 1
fi

# Check if IPs are present
if ! grep -qE "ansible_host: 65\.2\.142\.108|ansible_host: 3\.110\.124\.162|ansible_host: 13\.201\.19\.105" inventory/hosts.yml; then
    echo "✗ Inventory file missing IP addresses!"
    echo ""
    echo "Current inventory file:"
    cat inventory/hosts.yml
    echo ""
    echo "Please ensure inventory/hosts.yml has the correct IPs:"
    echo "  - App Server: 65.2.142.108"
    echo "  - DB Server: 3.110.124.162"
    echo "  - Nagios Server: 13.201.19.105"
    exit 1
fi

echo "✓ Inventory file has IP addresses"
echo ""

# Step 3: Test inventory parsing
echo "Step 3: Testing inventory parsing..."
ansible-inventory --list > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "✗ Inventory parsing failed!"
    echo "Checking syntax..."
    ansible-inventory --list
    exit 1
fi
echo "✓ Inventory is valid"
echo ""

# Step 4: Test connectivity
echo "Step 4: Testing connectivity to all hosts..."
ansible all -m ping

if [ $? -ne 0 ]; then
    echo ""
    echo "✗ Connection test failed!"
    echo ""
    echo "Possible issues:"
    echo "  1. Instances are still starting (wait 2-3 minutes)"
    echo "  2. SSH key not found: /home/sduse/.ssh/devops.pem"
    echo "  3. Security groups don't allow SSH"
    echo ""
    echo "Test SSH manually:"
    echo "  ssh -i /home/sduse/.ssh/devops.pem ubuntu@65.2.142.108"
    exit 1
fi

echo ""
echo "✓ All hosts are reachable!"
echo ""

# Step 5: Run deployment
echo "Step 5: Running Ansible playbooks..."
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
    echo "MongoDB Connection:"
    echo "  mongodb://172.31.5.189:27017/Digital_Wardrobe"
    echo ""
else
    echo ""
    echo "✗ Deployment failed!"
    echo "Run with -vvv for more details:"
    echo "  ansible-playbook playbooks/site.yml -vvv"
    exit 1
fi

