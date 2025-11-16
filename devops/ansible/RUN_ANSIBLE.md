# Running Ansible Playbooks

## Quick Start

### Step 1: Update Inventory from Terraform

**Windows (PowerShell):**
```powershell
cd devops\ansible
.\update-inventory-from-terraform.ps1
```

**Linux/WSL:**
```bash
cd devops/ansible
chmod +x update-inventory-from-terraform.sh
./update-inventory-from-terraform.sh
```

This script will:
- Read IP addresses from Terraform outputs
- Ask for your SSH key path
- Ask for Nagios admin password
- Update `inventory/hosts.yml` automatically

### Step 2: Test Connectivity

```bash
ansible all -m ping
```

All hosts should return `pong`.

### Step 3: Run Ansible Playbooks

**Deploy everything:**
```bash
ansible-playbook playbooks/site.yml
```

**Or deploy step by step:**
```bash
# Common configuration
ansible-playbook playbooks/common.yml

# Database setup
ansible-playbook playbooks/database.yml

# Application setup
ansible-playbook playbooks/application.yml

# Nagios setup
ansible-playbook playbooks/nagios.yml
```

## Manual Inventory Update

If the script doesn't work, manually edit `inventory/hosts.yml`:

```yaml
---
all:
  children:
    app_servers:
      hosts:
        app_server:
          ansible_host: "YOUR_APP_IP"  # Get from: terraform output app_instance_public_ip
          ansible_user: ubuntu
          ansible_ssh_private_key_file: "~/.ssh/your-key.pem"
          app_port: 3000
          node_version: "20.x"
    
    db_servers:
      hosts:
        db_server:
          ansible_host: "YOUR_DB_IP"  # Get from: terraform output db_instance_public_ip
          ansible_user: ubuntu
          ansible_ssh_private_key_file: "~/.ssh/your-key.pem"
          mongodb_version: "7.0"
          mongodb_port: 27017
    
    monitoring_servers:
      hosts:
        nagios_server:
          ansible_host: "YOUR_NAGIOS_IP"  # Get from: terraform output nagios_instance_public_ip
          ansible_user: ubuntu
          ansible_ssh_private_key_file: "~/.ssh/your-key.pem"
          nagios_admin_user: nagiosadmin
          nagios_admin_password: "your-password"
```

## Get IP Addresses from Terraform

```bash
cd devops/terraform
terraform output
```

Or get individual IPs:
```bash
terraform output app_instance_public_ip
terraform output db_instance_public_ip
terraform output nagios_instance_public_ip
```

## Troubleshooting

### SSH Connection Issues

1. **Test SSH manually:**
   ```bash
   ssh -i ~/.ssh/your-key.pem ubuntu@<IP_ADDRESS>
   ```

2. **Check security groups:**
   - Ensure port 22 is open in AWS security groups

3. **Verify key permissions (Linux/WSL):**
   ```bash
   chmod 400 ~/.ssh/your-key.pem
   ```

### Ansible Can't Connect

1. **Check inventory syntax:**
   ```bash
   ansible-inventory --list
   ```

2. **Test with verbose output:**
   ```bash
   ansible all -m ping -vvv
   ```

3. **Verify IP addresses are correct:**
   ```bash
   terraform output
   ```

### Playbook Fails

1. **Run with verbose output:**
   ```bash
   ansible-playbook playbooks/site.yml -vvv
   ```

2. **Run specific playbook to isolate issue:**
   ```bash
   ansible-playbook playbooks/common.yml -vvv
   ```

3. **Check if servers are ready:**
   - Wait a few minutes after Terraform creates instances
   - SSH into servers manually to verify they're up

## Common Issues

### "Host key verification failed"
- Already handled by `host_key_checking = False` in ansible.cfg

### "Permission denied (publickey)"
- Check SSH key path in inventory
- Verify key file permissions: `chmod 400 ~/.ssh/your-key.pem`
- Ensure key name matches what you used in Terraform

### "Connection timeout"
- Check security group allows SSH (port 22)
- Verify instances are running: `terraform output`
- Wait a few minutes for instances to fully boot

## Next Steps After Ansible

Once Ansible completes successfully:

1. **Access Application:**
   - URL: `http://<app-ip>:3000`

2. **Access Nagios:**
   - URL: `http://<nagios-ip>/nagios`
   - Username: `nagiosadmin`
   - Password: (what you set in inventory)

3. **Verify Services:**
   ```bash
   # Check application
   ansible app_servers -a "pm2 list"
   
   # Check database
   ansible db_servers -a "systemctl status mongod"
   
   # Check Nagios
   ansible monitoring_servers -a "systemctl status nagios"
   ```

