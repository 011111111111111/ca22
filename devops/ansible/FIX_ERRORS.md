# Fixing Ansible Errors

## Error 1: "No inventory was parsed"

**Problem:** Ansible can't find or parse the inventory file.

**Solution:**
```bash
# Check if inventory file exists
ls -la inventory/hosts.yml

# If it doesn't exist or has placeholders, update it:
./update-inventory-from-terraform.sh

# Or manually edit with actual IPs:
nano inventory/hosts.yml
```

**Verify inventory:**
```bash
ansible-inventory --list
```

## Error 2: "conflicting action statements: shell, creates"

**Problem:** Syntax error in nagios.yml - `creates` must be under `args:` when using multi-line shell.

**Solution:** Already fixed! The file has been updated. If you still see this error:
```bash
# Re-pull the latest version or manually fix:
# Change from:
#   shell: |
#     command
#   creates: /path/file
# 
# To:
#   shell: |
#     command
#   args:
#     creates: /path/file
```

## Error 3: "Ansible is being run in a world writable directory"

**Problem:** Directory permissions are too open (world-writable).

**Solution:**
```bash
# Fix permissions
chmod 755 .
chmod 644 ansible.cfg
chmod 755 inventory
chmod 644 inventory/*.yml
chmod 755 playbooks
chmod 644 playbooks/*.yml

# Or use the fix script:
chmod +x fix-permissions.sh
./fix-permissions.sh
```

## Complete Fix Sequence

```bash
# 1. Fix permissions
chmod +x fix-permissions.sh
./fix-permissions.sh

# 2. Check/update inventory
chmod +x check-inventory.sh
./check-inventory.sh

# If inventory needs updating:
chmod +x update-inventory-from-terraform.sh
./update-inventory-from-terraform.sh

# 3. Test connectivity
ansible all -m ping

# 4. Run playbooks
ansible-playbook playbooks/site.yml
```

## Quick Fix (All at Once)

```bash
# Fix everything
chmod +x fix-permissions.sh check-inventory.sh update-inventory-from-terraform.sh
./fix-permissions.sh
./check-inventory.sh || ./update-inventory-from-terraform.sh
ansible all -m ping
ansible-playbook playbooks/site.yml
```

