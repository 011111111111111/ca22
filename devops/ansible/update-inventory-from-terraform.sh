#!/bin/bash
# Script to update Ansible inventory from Terraform outputs

TERRAFORM_DIR="../terraform"
INVENTORY_FILE="inventory/hosts.yml"

echo "Updating Ansible inventory from Terraform outputs..."

# Change to terraform directory and get outputs
cd "$TERRAFORM_DIR" || exit 1

APP_IP=$(terraform output -raw app_instance_public_ip)
DB_IP=$(terraform output -raw db_instance_public_ip)
NAGIOS_IP=$(terraform output -raw nagios_instance_public_ip)

cd - > /dev/null || exit 1

echo "Found IPs:"
echo "  App Server:    $APP_IP"
echo "  DB Server:     $DB_IP"
echo "  Nagios Server: $NAGIOS_IP"

# Get SSH key path
read -p "Enter SSH key path (default: ~/.ssh/devops.pem): " SSH_KEY
SSH_KEY=${SSH_KEY:-~/.ssh/devops.pem}

# Get Nagios admin password
read -p "Enter Nagios admin password (default: changeme123): " NAGIOS_PASSWORD
NAGIOS_PASSWORD=${NAGIOS_PASSWORD:-changeme123}

# Create inventory content
cat > "$INVENTORY_FILE" << EOF
---
all:
  children:
    app_servers:
      hosts:
        app_server:
          ansible_host: $APP_IP
          ansible_user: ubuntu
          ansible_ssh_private_key_file: $SSH_KEY
          app_port: 3000
          node_version: "20.x"
    
    db_servers:
      hosts:
        db_server:
          ansible_host: $DB_IP
          ansible_user: ubuntu
          ansible_ssh_private_key_file: $SSH_KEY
          mongodb_version: "7.0"
          mongodb_port: 27017
    
    monitoring_servers:
      hosts:
        nagios_server:
          ansible_host: $NAGIOS_IP
          ansible_user: ubuntu
          ansible_ssh_private_key_file: $SSH_KEY
          nagios_admin_user: nagiosadmin
          nagios_admin_password: "$NAGIOS_PASSWORD"
EOF

echo ""
echo "✓ Inventory file updated: $INVENTORY_FILE"
echo ""
echo "You can now run Ansible playbooks:"
echo "  ansible-playbook playbooks/site.yml"

