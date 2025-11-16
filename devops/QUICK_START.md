# Quick Start Guide

## Prerequisites Check

Run these commands to verify prerequisites:

```bash
# Check Terraform
terraform version  # Should be >= 1.2.0

# Check Ansible
ansible --version  # Should be >= 2.9

# Check AWS CLI
aws --version

# Check AWS credentials
aws sts get-caller-identity
```

## 5-Minute Deployment

### 1. Configure Terraform (2 minutes)

```bash
cd devops/terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 2. Deploy Infrastructure (2 minutes)

```bash
terraform init
terraform apply -auto-approve
```

Save the output IPs!

### 3. Configure Ansible (1 minute)

```bash
cd ../ansible
# Edit inventory/hosts.yml with the IPs from step 2
```

### 4. Deploy Configuration (2 minutes)

```bash
ansible-playbook playbooks/site.yml
```

### 5. Access Services

- App: `http://<app-ip>:3000`
- Nagios: `http://<nagios-ip>/nagios` (user: nagiosadmin)

## Common Commands

```bash
# Check infrastructure status
cd terraform && terraform show

# Test Ansible connectivity
cd ansible && ansible all -m ping

# View application logs
ansible app_servers -a "pm2 logs" -become-user wardrobe

# Check Nagios status
ansible monitoring_servers -a "systemctl status nagios"
```

## Troubleshooting

**Can't connect via SSH?**
- Check security group allows port 22
- Verify key pair name matches
- Test: `ssh -i ~/.ssh/key.pem ubuntu@<ip>`

**Ansible fails?**
- Check inventory file syntax
- Verify SSH connectivity
- Run with `-vvv` for verbose output

**Application not accessible?**
- Check PM2: `pm2 list`
- Check Nginx: `systemctl status nginx`
- Check firewall: `ufw status`

For detailed help, see [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)

