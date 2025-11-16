# Digital Wardrobe Application - Deployment Guide

## Quick Start Deployment

This guide provides step-by-step instructions for deploying the Digital Wardrobe Application infrastructure.

## Pre-Deployment Checklist

- [ ] AWS account created and configured
- [ ] AWS CLI installed and configured (`aws configure`)
- [ ] Terraform installed (version >= 1.2.0)
- [ ] Ansible installed (version >= 2.9)
- [ ] SSH key pair created in AWS EC2
- [ ] SSH private key available locally
- [ ] Application code ready for deployment

## Phase 1: Infrastructure Provisioning (Terraform)

### 1.1 Navigate to Terraform Directory

```bash
cd devops/terraform
```

### 1.2 Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
aws_region          = "ap-south-1"        # Your preferred AWS region
instance_type       = "t3.micro"          # EC2 instance type
key_name            = "your-keypair-name" # Your EC2 key pair name
app_port            = 3000
db_instance_type    = "t3.micro"
nagios_instance_type = "t3.micro"
bucket_name_prefix  = "digital-wardrobe-storage"
environment         = "production"
```

### 1.3 Initialize Terraform

```bash
terraform init
```

Expected output: "Terraform has been successfully initialized!"

### 1.4 Review Deployment Plan

```bash
terraform plan
```

Review the plan to ensure all resources are correct.

### 1.5 Apply Infrastructure

```bash
terraform apply
```

Type `yes` when prompted. This will create:
- 3 EC2 instances (App, DB, Nagios)
- Security groups
- S3 bucket
- IAM roles and policies

### 1.6 Save Output Values

After successful deployment, save the output values:

```bash
terraform output > ../terraform-outputs.txt
```

Or manually note:
- `app_instance_public_ip`
- `db_instance_public_ip`
- `nagios_instance_public_ip`
- `s3_bucket_name`

## Phase 2: Configuration Management (Ansible)

### 2.1 Navigate to Ansible Directory

```bash
cd ../ansible
```

### 2.2 Update Inventory File

Edit `inventory/hosts.yml`:

```yaml
all:
  children:
    app_servers:
      hosts:
        app_server:
          ansible_host: "54.123.45.67"  # Replace with app_instance_public_ip
          ansible_user: ubuntu
          ansible_ssh_private_key_file: "~/.ssh/your-key.pem"  # Your SSH key path
          app_port: 3000
          node_version: "20.x"
    
    db_servers:
      hosts:
        db_server:
          ansible_host: "54.123.45.68"  # Replace with db_instance_public_ip
          ansible_user: ubuntu
          ansible_ssh_private_key_file: "~/.ssh/your-key.pem"
          mongodb_version: "7.0"
          mongodb_port: 27017
    
    monitoring_servers:
      hosts:
        nagios_server:
          ansible_host: "54.123.45.69"  # Replace with nagios_instance_public_ip
          ansible_user: ubuntu
          ansible_ssh_private_key_file: "~/.ssh/your-key.pem"
          nagios_admin_user: nagiosadmin
          nagios_admin_password: "YourSecurePassword123!"  # Change this!
```

### 2.3 Test Connectivity

```bash
ansible all -m ping
```

All hosts should return `pong`.

### 2.4 Deploy Configuration

#### Option A: Deploy Everything (Recommended)

```bash
ansible-playbook playbooks/site.yml
```

#### Option B: Deploy Step by Step

```bash
# 1. Common configuration for all servers
ansible-playbook playbooks/common.yml

# 2. Database server setup
ansible-playbook playbooks/database.yml

# 3. Application server setup
ansible-playbook playbooks/application.yml

# 4. Nagios monitoring setup
ansible-playbook playbooks/nagios.yml
```

### 2.5 Verify Deployment

```bash
# Check application server
ansible app_servers -a "systemctl status pm2-wardrobe"

# Check database server
ansible db_servers -a "systemctl status mongod"

# Check Nagios server
ansible monitoring_servers -a "systemctl status nagios"
```

## Phase 3: Application Deployment

### 3.1 Copy Application Code to Server

```bash
# From your local machine
scp -i ~/.ssh/your-key.pem -r ../../backend/* ubuntu@<app-server-ip>:/opt/digital-wardrobe/
```

Or use Ansible:

```bash
ansible app_servers -m copy -a "src=../../backend dest=/opt/digital-wardrobe owner=wardrobe group=wardrobe mode=0755"
```

### 3.2 Install Application Dependencies

```bash
ansible app_servers -m shell -a "cd /opt/digital-wardrobe && npm install" -become-user wardrobe
```

### 3.3 Build Application

```bash
ansible app_servers -m shell -a "cd /opt/digital-wardrobe && npm run build" -become-user wardrobe
```

### 3.4 Start Application

```bash
ansible app_servers -m shell -a "cd /opt/digital-wardrobe && pm2 start ecosystem.config.js && pm2 save" -become-user wardrobe
```

## Phase 4: Verification

### 4.1 Access Application

Open browser: `http://<app-server-ip>:3000`

### 4.2 Access Nagios

Open browser: `http://<nagios-server-ip>/nagios`
- Username: `nagiosadmin`
- Password: (from inventory file)

### 4.3 Verify Monitoring

In Nagios web interface, check:
- All hosts show as "UP" (green)
- All services show as "OK" (green)
- Application HTTP check is passing

## Post-Deployment Tasks

1. **Change Default Passwords**
   - Nagios admin password
   - MongoDB root password (if configured)

2. **Configure DNS** (Optional)
   - Point domain to application server IP
   - Update Nginx configuration with domain name

3. **SSL/TLS Setup** (Optional)
   - Install Let's Encrypt certificate
   - Configure HTTPS in Nginx

4. **Backup Configuration**
   - Document all IPs and credentials
   - Save Terraform state file securely
   - Backup Ansible inventory

## Troubleshooting

### Application Not Accessible

```bash
# Check if application is running
ssh -i ~/.ssh/your-key.pem ubuntu@<app-server-ip>
pm2 list
pm2 logs

# Check Nginx
sudo systemctl status nginx
sudo nginx -t
```

### Database Connection Issues

```bash
# Check MongoDB status
ssh -i ~/.ssh/your-key.pem ubuntu@<db-server-ip>
sudo systemctl status mongod
sudo mongosh --eval "db.adminCommand('ping')"
```

### Nagios Not Showing Hosts

```bash
# Check Nagios configuration
ssh -i ~/.ssh/your-key.pem ubuntu@<nagios-server-ip>
sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

# Check NRPE connectivity
/usr/local/nagios/libexec/check_nrpe -H <app-server-ip>
```

## Maintenance

### Update Application

```bash
# Pull latest code
ansible app_servers -m git -a "repo=your-repo-url dest=/opt/digital-wardrobe version=main"

# Rebuild and restart
ansible app_servers -m shell -a "cd /opt/digital-wardrobe && npm install && npm run build && pm2 restart all" -become-user wardrobe
```

### Update Infrastructure

```bash
cd terraform
terraform plan
terraform apply
```

### Update Ansible Configuration

```bash
cd ansible
ansible-playbook playbooks/site.yml
```

## Cleanup

To completely remove all infrastructure:

```bash
cd terraform
terraform destroy
```

**Warning**: This permanently deletes all resources and data!

---

For detailed information, refer to the main [README.md](README.md).

