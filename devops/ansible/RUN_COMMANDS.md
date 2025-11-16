# Commands to Run Ansible

## Prerequisites
1. Terraform infrastructure must be deployed first
2. Get IP addresses from Terraform: `cd ../terraform && terraform output`
3. Have your SSH key ready

## Step-by-Step Commands

### Step 1: Navigate to Ansible Directory

**Windows (PowerShell):**
```powershell
cd C:\Users\sduse\Downloads\Python\devops\ansible
```

**Linux/WSL/Ubuntu:**
```bash
cd /mnt/c/Users/sduse/Downloads/Python/devops/ansible
```

### Step 2: Update Inventory from Terraform

**Windows:**
```powershell
.\update-inventory-from-terraform.ps1
```

**Linux/WSL:**
```bash
chmod +x update-inventory-from-terraform.sh
./update-inventory-from-terraform.sh
```

**Manual (if script doesn't work):**
1. Get IPs: `cd ../terraform && terraform output`
2. Edit `inventory/hosts.yml` with the IPs

### Step 3: Test Connectivity

```bash
ansible all -m ping
```

Expected output: All hosts should return `pong`

### Step 4: Run Ansible Playbooks

#### Option A: Run Everything (Recommended)
```bash
ansible-playbook playbooks/site.yml
```

#### Option B: Run Step by Step

**1. Common configuration (all servers):**
```bash
ansible-playbook playbooks/common.yml
```

**2. Database server setup:**
```bash
ansible-playbook playbooks/database.yml
```

**3. Application server setup:**
```bash
ansible-playbook playbooks/application.yml
```

**4. Nagios monitoring setup:**
```bash
ansible-playbook playbooks/nagios.yml
```

## Complete Command Sequence

### Windows (PowerShell)
```powershell
# Navigate
cd C:\Users\sduse\Downloads\Python\devops\ansible

# Update inventory
.\update-inventory-from-terraform.ps1

# Test connectivity
ansible all -m ping

# Deploy everything
ansible-playbook playbooks/site.yml
```

### Linux/WSL/Ubuntu
```bash
# Navigate
cd /mnt/c/Users/sduse/Downloads/Python/devops/ansible

# Update inventory
chmod +x update-inventory-from-terraform.sh
./update-inventory-from-terraform.sh

# Test connectivity
ansible all -m ping

# Deploy everything
ansible-playbook playbooks/site.yml
```

## Quick Start (One Command)

### Windows
```powershell
cd C:\Users\sduse\Downloads\Python\devops\ansible; .\quick-start.ps1
```

### Linux/WSL
```bash
cd /mnt/c/Users/sduse/Downloads/Python/devops/ansible && chmod +x run-ansible.sh && ./run-ansible.sh
```

## Useful Commands

### Check Ansible Version
```bash
ansible --version
```

### List All Hosts
```bash
ansible-inventory --list
```

### Test Specific Host
```bash
ansible app_servers -m ping
ansible db_servers -m ping
ansible monitoring_servers -m ping
```

### Run with Verbose Output (for debugging)
```bash
ansible-playbook playbooks/site.yml -vvv
```

### Run Specific Playbook with Tags
```bash
ansible-playbook playbooks/site.yml --tags "common"
```

### Check What Would Change (Dry Run)
```bash
ansible-playbook playbooks/site.yml --check
```

### Run Only on Specific Hosts
```bash
ansible-playbook playbooks/site.yml --limit app_servers
```

## Verify Deployment

### Check Application Server
```bash
ansible app_servers -a "pm2 list"
ansible app_servers -a "systemctl status nginx"
```

### Check Database Server
```bash
ansible db_servers -a "systemctl status mongod"
ansible db_servers -a "mongosh --eval 'db.adminCommand(\"ping\")'"
```

### Check Nagios Server
```bash
ansible monitoring_servers -a "systemctl status nagios"
ansible monitoring_servers -a "systemctl status apache2"
```

## Troubleshooting Commands

### Test SSH Connection Manually
```bash
# Get IP from Terraform
cd ../terraform
terraform output app_instance_public_ip

# Test SSH (replace with actual IP and key path)
ssh -i ~/.ssh/devops.pem ubuntu@<APP_IP>
```

### Check Ansible Configuration
```bash
ansible-config dump
```

### Validate Inventory
```bash
ansible-inventory --list --yaml
```

### Run with Specific User
```bash
ansible-playbook playbooks/site.yml -u ubuntu
```

## Common Issues and Fixes

### Issue: "Host key verification failed"
**Fix:** Already handled by `host_key_checking = False` in ansible.cfg

### Issue: "Permission denied (publickey)"
**Fix:** Check SSH key path in inventory file
```bash
# Verify key exists and has correct permissions (Linux)
chmod 400 ~/.ssh/devops.pem
```

### Issue: "Connection timeout"
**Fix:** 
1. Wait a few minutes after Terraform creates instances
2. Check security groups allow SSH (port 22)
3. Verify instances are running in AWS console

### Issue: "Module not found"
**Fix:** Install required Ansible modules
```bash
ansible-galaxy collection install community.general
```

## After Successful Deployment

### Get Service URLs
```bash
cd ../terraform
terraform output
```

### Access Services
- **Application:** `http://<app-ip>:3000`
- **Nagios:** `http://<nagios-ip>/nagios`
  - Username: `nagiosadmin`
  - Password: (what you set in inventory)

