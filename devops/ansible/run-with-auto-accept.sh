#!/bin/bash
# Run Ansible with automatic SSH key acceptance

echo "========================================"
echo "Ansible Deployment with Auto SSH Accept"
echo "========================================"
echo ""

# Get IPs from inventory
APP_IP=$(grep -A 5 "app_server:" inventory/hosts.yml | grep ansible_host | awk '{print $2}')
DB_IP=$(grep -A 5 "db_server:" inventory/hosts.yml | grep ansible_host | awk '{print $2}')
NAGIOS_IP=$(grep -A 5 "nagios_server:" inventory/hosts.yml | grep ansible_host | awk '{print $2}')

echo "Step 1: Adding SSH host keys..."
ssh-keyscan -H $APP_IP $DB_IP $NAGIOS_IP >> ~/.ssh/known_hosts 2>/dev/null
echo "✓ SSH keys added"
echo ""

echo "Step 2: Testing connectivity..."
ANSIBLE_HOST_KEY_CHECKING=False ansible all -i inventory/hosts.yml -m ping

if [ $? -ne 0 ]; then
    echo ""
    echo "✗ Connection test failed!"
    echo "Please check:"
    echo "  1. SSH key exists: /home/sduse/.ssh/devops.pem"
    echo "  2. Instances are running"
    echo "  3. Security groups allow SSH"
    exit 1
fi

echo ""
echo "✓ All hosts are reachable!"
echo ""

echo "Step 3: Running Ansible playbooks..."
echo "This will take 10-15 minutes..."
echo ""

ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory/hosts.yml playbooks/site.yml

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
    exit 1
fi

