# Quick Run - Bypass SSH Key Prompts

## The Issue
Ansible is asking you to accept SSH host keys for each server. You need to type "yes" three times.

## Quick Solution

### Option 1: Auto-accept SSH Keys (Recommended)
```bash
cd /mnt/c/Users/sduse/Downloads/Python/devops/ansible

# Add SSH keys automatically
ssh-keyscan -H 65.2.142.108 3.110.124.162 13.201.19.105 >> ~/.ssh/known_hosts

# Then run Ansible
ansible-playbook -i inventory/hosts.yml playbooks/site.yml
```

### Option 2: Use Environment Variable
```bash
cd /mnt/c/Users/sduse/Downloads/Python/devops/ansible

ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory/hosts.yml playbooks/site.yml
```

### Option 3: Use the Automated Script
```bash
cd /mnt/c/Users/sduse/Downloads/Python/devops/ansible
chmod +x run-with-auto-accept.sh
./run-with-auto-accept.sh
```

## If You're Already Stuck

If you're already at the prompt asking "Are you sure you want to continue connecting (yes/no/[fingerprint])?":

**Just type `yes` and press Enter three times** (once for each server).

Then the playbooks will continue running.

## One-Liner (Easiest)

```bash
cd /mnt/c/Users/sduse/Downloads/Python/devops/ansible && ssh-keyscan -H 65.2.142.108 3.110.124.162 13.201.19.105 >> ~/.ssh/known_hosts && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory/hosts.yml playbooks/site.yml
```

This will:
1. Add all SSH keys automatically
2. Run Ansible without host key checking
3. Deploy everything

