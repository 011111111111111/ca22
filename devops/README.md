# Digital Wardrobe Application - DevOps Infrastructure

This directory contains the complete DevOps infrastructure setup for the Digital Wardrobe Application using Terraform, Ansible, and Nagios.

## Project Structure

```
devops/
├── terraform/          # Infrastructure as Code (IaC)
│   ├── main.tf         # Main Terraform configuration
│   ├── variables.tf    # Variable definitions
│   ├── outputs.tf      # Output values
│   └── terraform.tfvars.example
├── ansible/            # Configuration Management
│   ├── inventory/      # Host inventory
│   ├── playbooks/      # Ansible playbooks
│   ├── roles/          # Reusable roles
│   ├── templates/      # Configuration templates
│   └── ansible.cfg     # Ansible configuration
└── nagios/             # Monitoring configuration
    └── README.md       # Nagios documentation
```

## Prerequisites

1. **AWS Account** with appropriate credentials
2. **Terraform** >= 1.2.0 installed
3. **Ansible** >= 2.9 installed
4. **AWS CLI** configured with credentials
5. **SSH Key Pair** in AWS EC2
6. **Python 3** with pip

## Infrastructure Components

### Terraform Provisions:
- **Application Server** (EC2 instance) - Runs Node.js application
- **Database Server** (EC2 instance) - Runs MongoDB
- **Nagios Server** (EC2 instance) - Monitoring and alerting
- **S3 Bucket** - File storage for uploaded images
- **Security Groups** - Network access control
- **IAM Roles** - S3 access permissions

### Ansible Configures:
- System packages and dependencies
- MongoDB installation and configuration
- Node.js and application deployment
- Nginx reverse proxy
- Nagios monitoring setup
- NRPE agents on all servers

### Nagios Monitors:
- Application uptime and health
- System resources (CPU, memory, disk)
- Service availability (HTTP, MongoDB, SSH)
- Network connectivity

## Deployment Steps

### Step 1: Configure Terraform Variables

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

Update `terraform.tfvars` with:
- `aws_region` - Your AWS region
- `key_name` - Your EC2 key pair name
- Other variables as needed

### Step 2: Initialize and Apply Terraform

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

After successful deployment, note the output values:
- Application server IP
- Database server IP
- Nagios server IP
- S3 bucket name

### Step 3: Update Ansible Inventory

```bash
cd ../ansible
```

Edit `inventory/hosts.yml` and replace placeholders:
- `{{ app_public_ip }}` - Application server public IP
- `{{ db_public_ip }}` - Database server public IP
- `{{ nagios_public_ip }}` - Nagios server public IP
- Update SSH key path: `~/.ssh/your-key.pem`

### Step 4: Run Ansible Playbooks

```bash
# Deploy everything
ansible-playbook playbooks/site.yml

# Or deploy individually:
ansible-playbook playbooks/common.yml
ansible-playbook playbooks/database.yml
ansible-playbook playbooks/application.yml
ansible-playbook playbooks/nagios.yml
```

### Step 5: Access Services

- **Application**: `http://<app-server-ip>:3000`
- **Nagios Web UI**: `http://<nagios-server-ip>/nagios`
  - Username: `nagiosadmin`
  - Password: (set in inventory/hosts.yml)

## Configuration Details

### Application Server
- **OS**: Ubuntu 22.04 LTS
- **Runtime**: Node.js 20.x
- **Process Manager**: PM2
- **Reverse Proxy**: Nginx
- **Port**: 3000

### Database Server
- **OS**: Ubuntu 22.04 LTS
- **Database**: MongoDB 7.0
- **Port**: 27017

### Nagios Server
- **OS**: Ubuntu 22.04 LTS
- **Web Interface**: Apache + PHP
- **Port**: 80 (HTTP)

## Monitoring

Nagios monitors the following:

### Application Server Checks:
- PING (network connectivity)
- SSH service
- HTTP endpoint (port 3000)
- Node.js process status
- CPU usage
- Memory usage
- Disk space
- System load

### Database Server Checks:
- PING (network connectivity)
- SSH service
- MongoDB service (port 27017)
- CPU usage
- Memory usage
- Disk space
- System load

## Troubleshooting

### Terraform Issues
- Verify AWS credentials: `aws sts get-caller-identity`
- Check key pair exists in AWS: `aws ec2 describe-key-pairs`
- Review security group rules

### Ansible Issues
- Test SSH connectivity: `ssh -i ~/.ssh/your-key.pem ubuntu@<server-ip>`
- Check inventory file syntax: `ansible-inventory --list`
- Run with verbose output: `ansible-playbook -vvv playbooks/site.yml`

### Nagios Issues
- Check Nagios service: `systemctl status nagios`
- Validate configuration: `/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg`
- Check NRPE connectivity: `/usr/local/nagios/libexec/check_nrpe -H <host-ip>`

## Security Considerations

1. **SSH Keys**: Use strong SSH keys and restrict access
2. **Security Groups**: Limit access to necessary IPs only
3. **Nagios Password**: Change default password immediately
4. **Firewall**: Configure UFW rules appropriately
5. **S3 Bucket**: Review bucket policies and access controls

## Cleanup

To destroy all infrastructure:

```bash
cd terraform
terraform destroy
```

**Warning**: This will delete all resources including data!

## Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [Nagios Core Documentation](https://assets.nagios.com/downloads/nagioscore/docs/nagioscore/4/en/)

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review log files on respective servers
3. Verify configuration files syntax

---

**Note**: This is a course submission project. Ensure all credentials and sensitive information are properly secured and not committed to version control.

