#!/bin/bash
# Continue deployment after fixing the SSH key issue

echo "========================================"
echo "Continuing Ansible Deployment"
echo "========================================"
echo ""

echo "The SSH key setup task has been fixed."
echo "It will now skip if the public key doesn't exist."
echo ""

echo "Running Ansible playbooks again..."
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
    echo "✗ Deployment had errors. Check output above."
    echo "Run with -vvv for more details:"
    echo "  ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory/hosts.yml playbooks/site.yml -vvv"
fi

