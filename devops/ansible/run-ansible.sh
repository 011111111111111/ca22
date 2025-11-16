#!/bin/bash
# Quick start script for Ansible deployment (Linux/WSL)

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR" || exit 1

echo "========================================"
echo "Ansible Quick Start"
echo "========================================"
echo ""

# Check if we're in the right directory
if [ ! -f "playbooks/site.yml" ]; then
    echo "Error: Please run this from the ansible directory"
    exit 1
fi

# Step 1: Update inventory
echo "Step 1: Updating inventory from Terraform..."
if [ -f "update-inventory-from-terraform.sh" ]; then
    chmod +x update-inventory-from-terraform.sh
    ./update-inventory-from-terraform.sh
else
    echo "Warning: update script not found. Please update inventory manually."
    echo "See RUN_ANSIBLE.md for instructions."
    exit 1
fi

echo ""
echo "Step 2: Testing connectivity..."
ansible all -m ping

if [ $? -ne 0 ]; then
    echo ""
    echo "Connection test failed!"
    echo "Please check:"
    echo "  1. SSH key path is correct"
    echo "  2. IP addresses are correct"
    echo "  3. Security groups allow SSH (port 22)"
    echo "  4. Instances are running (wait a few minutes after Terraform)"
    exit 1
fi

echo ""
echo "✓ All hosts are reachable!"

# Step 3: Ask if user wants to proceed
echo ""
echo "Step 3: Ready to deploy!"
read -p "Do you want to run the full deployment now? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo ""
    echo "You can run the deployment manually with:"
    echo "  ansible-playbook playbooks/site.yml"
    exit 0
fi

echo ""
echo "Step 4: Running full deployment..."
echo "This may take 10-15 minutes..."
echo ""

ansible-playbook playbooks/site.yml

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Deployment completed successfully!"
    echo ""
    echo "Next steps:"
    echo "  1. Get IP addresses: cd ../terraform && terraform output"
    echo "  2. Access application: http://<app-ip>:3000"
    echo "  3. Access Nagios: http://<nagios-ip>/nagios"
else
    echo ""
    echo "✗ Deployment failed!"
    echo "Check the error messages above for details."
    echo "Run with -vvv for more details: ansible-playbook playbooks/site.yml -vvv"
fi

