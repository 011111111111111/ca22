#!/bin/bash
# Complete Ansible deployment script
# This script runs all Ansible playbooks in the correct order

set -e  # Exit on error

echo "========================================"
echo "Ansible Complete Deployment"
echo "========================================"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR" || exit 1

# Check prerequisites
if [ ! -f "playbooks/site.yml" ]; then
    echo "Error: Please run this from the ansible directory"
    exit 1
fi

# Check if inventory exists
if [ ! -f "inventory/hosts.yml" ]; then
    echo "Error: inventory/hosts.yml not found"
    echo "Please run update-inventory-from-terraform.sh first"
    exit 1
fi

# Step 1: Check inventory (skip update if IPs already exist)
echo "Step 1: Checking inventory..."
if grep -qE "ansible_host: [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" inventory/hosts.yml 2>/dev/null; then
    echo "✓ Inventory already has IP addresses"
else
    echo "⚠ Inventory missing IP addresses"
    echo "Please update inventory/hosts.yml with your server IPs"
    echo "Or run: ./update-inventory-from-terraform.sh (if terraform is available)"
    exit 1
fi
echo ""

# Step 2: Test connectivity
echo "Step 2: Testing connectivity to all hosts..."
ansible all -m ping

if [ $? -ne 0 ]; then
    echo ""
    echo "✗ Connection test failed!"
    echo ""
    echo "Please check:"
    echo "  1. SSH key path is correct in inventory/hosts.yml"
    echo "  2. IP addresses are correct (run: cd ../terraform && terraform output)"
    echo "  3. Security groups allow SSH (port 22)"
    echo "  4. Instances are running (wait 2-3 minutes after Terraform)"
    echo ""
    exit 1
fi

echo "✓ All hosts are reachable!"
echo ""

# Step 3: Run deployment
echo "Step 3: Running complete deployment..."
echo "This will run all playbooks in order:"
echo "  1. common.yml - Base configuration"
echo "  2. database.yml - MongoDB setup"
echo "  3. application.yml - Application deployment"
echo "  4. nagios.yml - Monitoring setup"
echo ""
echo "This may take 10-15 minutes..."
echo ""

# Run the main playbook
ansible-playbook playbooks/site.yml

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "✓ Deployment Completed Successfully!"
    echo "========================================"
    echo ""
    echo "Next steps:"
    echo ""
    echo "1. Get service IPs:"
    echo "   cd ../terraform && terraform output"
    echo ""
    echo "2. Access services:"
    echo "   - Application: http://<app-ip>:3000"
    echo "   - Nagios: http://<nagios-ip>/nagios"
    echo "     Username: nagiosadmin"
    echo "     Password: (check inventory/hosts.yml)"
    echo ""
    echo "3. Verify services:"
    echo "   ansible app_servers -a 'pm2 list'"
    echo "   ansible db_servers -a 'systemctl status mongod'"
    echo "   ansible monitoring_servers -a 'systemctl status nagios'"
    echo ""
else
    echo ""
    echo "========================================"
    echo "✗ Deployment Failed!"
    echo "========================================"
    echo ""
    echo "Check the error messages above."
    echo "Run with verbose output for details:"
    echo "  ansible-playbook playbooks/site.yml -vvv"
    echo ""
    exit 1
fi

