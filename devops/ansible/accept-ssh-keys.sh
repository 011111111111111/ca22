#!/bin/bash
# Accept SSH host keys for all servers

echo "Adding SSH host keys to known_hosts..."

# Get IPs from inventory
APP_IP=$(grep -A 5 "app_server:" inventory/hosts.yml | grep ansible_host | awk '{print $2}')
DB_IP=$(grep -A 5 "db_server:" inventory/hosts.yml | grep ansible_host | awk '{print $2}')
NAGIOS_IP=$(grep -A 5 "nagios_server:" inventory/hosts.yml | grep ansible_host | awk '{print $2}')

echo "App Server: $APP_IP"
echo "DB Server: $DB_IP"
echo "Nagios Server: $NAGIOS_IP"
echo ""

# Add to known_hosts using ssh-keyscan
ssh-keyscan -H $APP_IP >> ~/.ssh/known_hosts 2>/dev/null
ssh-keyscan -H $DB_IP >> ~/.ssh/known_hosts 2>/dev/null
ssh-keyscan -H $NAGIOS_IP >> ~/.ssh/known_hosts 2>/dev/null

echo "✓ SSH host keys added to known_hosts"
echo ""

# Test connectivity
echo "Testing connectivity..."
ansible all -i inventory/hosts.yml -m ping

