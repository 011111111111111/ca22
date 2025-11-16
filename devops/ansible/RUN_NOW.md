# Run Ansible Now - Quick Fix

## The Problem
Ansible is not parsing the inventory file because:
1. Directory is world-writable (WSL/Windows filesystem issue)
2. Ansible ignores ansible.cfg in world-writable directories

## Solution: Use Explicit Inventory Path

Run Ansible with the `-i` flag to specify inventory explicitly:

```bash
cd /mnt/c/Users/sduse/Downloads/Python/devops/ansible

# Test connectivity
ansible all -i inventory/hosts.yml -m ping

# Run playbooks
ansible-playbook -i inventory/hosts.yml playbooks/site.yml
```

## Or Use the Fix Script

```bash
cd /mnt/c/Users/sduse/Downloads/Python/devops/ansible
chmod +x force-fix.sh
./force-fix.sh
```

## Quick One-Liner

```bash
cd /mnt/c/Users/sduse/Downloads/Python/devops/ansible && ansible-playbook -i inventory/hosts.yml playbooks/site.yml
```

## Why This Works

By using `-i inventory/hosts.yml`, we bypass the ansible.cfg file and tell Ansible directly where to find the inventory. This works even in world-writable directories.

## Verify It's Working

Before running playbooks, test:
```bash
ansible all -i inventory/hosts.yml -m ping
```

You should see all three hosts respond with `pong`.

