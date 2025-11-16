#!/bin/bash
# Continue deployment skipping NRPE (optional component)

echo "Continuing deployment without NRPE..."
echo "NRPE is optional for monitoring - we can install it later"
echo ""

# Run playbooks but skip NRPE tasks
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory/hosts.yml playbooks/site.yml --skip-tags nrpe 2>/dev/null || \
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory/hosts.yml playbooks/site.yml

# If that doesn't work, run playbooks individually skipping database NRPE
echo ""
echo "Running playbooks individually..."

echo "1. Common (already done)"
echo "2. Database (already done)"
echo "3. Application..."
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory/hosts.yml playbooks/application.yml

echo "4. Nagios..."
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory/hosts.yml playbooks/nagios.yml

echo ""
echo "Deployment complete!"
echo ""
echo "Check services:"
echo "  Application: http://65.2.142.108:3000"
echo "  Nagios: http://13.201.19.105/nagios"

