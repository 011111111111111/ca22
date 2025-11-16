# Quick Commands Reference

## Navigation Commands

### Windows (PowerShell)
```powershell
# Terraform directory
cd C:\Users\sduse\Downloads\Python\devops\terraform

# Ansible directory
cd C:\Users\sduse\Downloads\Python\devops\ansible

# From project root
cd devops\terraform
cd devops\ansible
```

### Linux/WSL/Ubuntu
```bash
# Terraform directory
cd /mnt/c/Users/sduse/Downloads/Python/devops/terraform

# Ansible directory
cd /mnt/c/Users/sduse/Downloads/Python/devops/ansible

# From project root
cd devops/terraform
cd devops/ansible
```

## Terraform Commands

### Windows
```powershell
cd devops\terraform
terraform init
terraform plan -var="resource_name_suffix=-v2"
terraform apply -var="resource_name_suffix=-v2"
terraform output
```

### Linux/WSL
```bash
cd /mnt/c/Users/sduse/Downloads/Python/devops/terraform
terraform init
terraform plan -var="resource_name_suffix=-v2"
terraform apply -var="resource_name_suffix=-v2"
terraform output
```

## Ansible Commands

### Windows
```powershell
cd devops\ansible

# Update inventory
.\update-inventory-from-terraform.ps1

# Test connectivity
ansible all -m ping

# Deploy
ansible-playbook playbooks/site.yml
```

### Linux/WSL
```bash
cd /mnt/c/Users/sduse/Downloads/Python/devops/ansible

# Update inventory
chmod +x update-inventory-from-terraform.sh
./update-inventory-from-terraform.sh

# Test connectivity
ansible all -m ping

# Deploy
ansible-playbook playbooks/site.yml
```

## Quick Start Scripts

### Windows
```powershell
cd devops\ansible
.\quick-start.ps1
```

### Linux/WSL
```bash
cd /mnt/c/Users/sduse/Downloads/Python/devops/ansible
chmod +x run-ansible.sh
./run-ansible.sh
```

## Full Workflow

### Step 1: Deploy Infrastructure (Terraform)
**Windows:**
```powershell
cd C:\Users\sduse\Downloads\Python\devops\terraform
terraform apply -var="resource_name_suffix=-v2"
```

**Linux/WSL:**
```bash
cd /mnt/c/Users/sduse/Downloads/Python/devops/terraform
terraform apply -var="resource_name_suffix=-v2"
```

### Step 2: Configure Servers (Ansible)
**Windows:**
```powershell
cd C:\Users\sduse\Downloads\Python\devops\ansible
.\update-inventory-from-terraform.ps1
ansible-playbook playbooks/site.yml
```

**Linux/WSL:**
```bash
cd /mnt/c/Users/sduse/Downloads/Python/devops/ansible
./update-inventory-from-terraform.sh
ansible-playbook playbooks/site.yml
```

## Environment-Specific Notes

### WSL Path Conversion
Windows path: `C:\Users\sduse\Downloads\Python`
WSL path: `/mnt/c/Users/sduse/Downloads/Python`

**Rule:** 
- `C:\` becomes `/mnt/c/`
- Backslashes `\` become forward slashes `/`
- Case-sensitive in Linux

### SSH Key Paths
**Windows:**
```powershell
~/.ssh/devops.pem
C:\Users\sduse\.ssh\devops.pem
```

**Linux/WSL:**
```bash
~/.ssh/devops.pem
/home/username/.ssh/devops.pem
```

## Troubleshooting Paths

### Check Current Directory
**Windows:**
```powershell
pwd
Get-Location
```

**Linux/WSL:**
```bash
pwd
```

### List Files
**Windows:**
```powershell
ls
Get-ChildItem
```

**Linux/WSL:**
```bash
ls -la
```

### Verify Path Exists
**Windows:**
```powershell
Test-Path "devops\ansible"
```

**Linux/WSL:**
```bash
test -d "devops/ansible" && echo "Exists" || echo "Not found"
```

