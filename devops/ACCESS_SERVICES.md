# How to Access Your Services

## Application Server

**URL:** `http://65.2.142.108:3000`

**IP Address:** `65.2.142.108`

**Port:** `3000`

### Access the Application

Open in your browser:
```
http://65.2.142.108:3000
```

### Check Application Status

**Via SSH:**
```bash
ssh -i /home/sduse/.ssh/devops.pem ubuntu@65.2.142.108
pm2 list
pm2 logs
```

**Via Ansible:**
```bash
cd /mnt/c/Users/sduse/Downloads/Python/devops/ansible
ansible app_servers -i inventory/hosts.yml -a "pm2 list"
ansible app_servers -i inventory/hosts.yml -a "systemctl status nginx"
```

### Check if Application is Running

```bash
# Test HTTP endpoint
curl http://65.2.142.108:3000

# Or check from browser
# Open: http://65.2.142.108:3000
```

## Nagios Monitoring

**URL:** `http://13.201.19.105/nagios`

**IP Address:** `13.201.19.105`

**Credentials:**
- Username: `nagiosadmin`
- Password: `changeme123`

### Access Nagios

Open in your browser:
```
http://13.201.19.105/nagios
```

### Check Nagios Status

```bash
# Via SSH
ssh -i /home/sduse/.ssh/devops.pem ubuntu@13.201.19.105
systemctl status nagios
systemctl status apache2

# Via Ansible
ansible monitoring_servers -i inventory/hosts.yml -a "systemctl status nagios"
```

## Database Server

**IP Address:** `3.110.124.162` (Private: `172.31.5.189`)

**MongoDB Connection String:**
```
mongodb://172.31.5.189:27017/Digital_Wardrobe
```

### Check Database Status

```bash
# Via SSH
ssh -i /home/sduse/.ssh/devops.pem ubuntu@3.110.124.162
systemctl status mongod
mongosh --eval "db.adminCommand('ping')"

# Via Ansible
ansible db_servers -i inventory/hosts.yml -a "systemctl status mongod"
```

## Quick Status Check

Run this to check all services:

```bash
cd /mnt/c/Users/sduse/Downloads/Python/devops/ansible

# Check all services
ansible all -i inventory/hosts.yml -a "hostname"
ansible app_servers -i inventory/hosts.yml -a "pm2 list"
ansible db_servers -i inventory/hosts.yml -a "systemctl status mongod"
ansible monitoring_servers -i inventory/hosts.yml -a "systemctl status nagios"
```

## Service Summary

| Service | URL | IP Address | Status Check |
|---------|-----|------------|--------------|
| **Application** | http://65.2.142.108:3000 | 65.2.142.108 | `curl http://65.2.142.108:3000` |
| **Nagios** | http://13.201.19.105/nagios | 13.201.19.105 | `curl http://13.201.19.105/nagios` |
| **Database** | Internal only | 3.110.124.162 | `systemctl status mongod` |

## Troubleshooting

### Application Not Accessible

1. **Check if PM2 is running:**
   ```bash
   ssh -i /home/sduse/.ssh/devops.pem ubuntu@65.2.142.108 "pm2 list"
   ```

2. **Check Nginx:**
   ```bash
   ssh -i /home/sduse/.ssh/devops.pem ubuntu@65.2.142.108 "systemctl status nginx"
   ```

3. **Check firewall:**
   ```bash
   ssh -i /home/sduse/.ssh/devops.pem ubuntu@65.2.142.108 "ufw status"
   ```

4. **View application logs:**
   ```bash
   ssh -i /home/sduse/.ssh/devops.pem ubuntu@65.2.142.108 "pm2 logs"
   ```

### If Application Code Not Deployed

The Ansible playbooks set up the infrastructure, but you may need to deploy your application code:

```bash
# SSH into app server
ssh -i /home/sduse/.ssh/devops.pem ubuntu@65.2.142.108

# Navigate to app directory
cd /opt/digital-wardrobe

# If code not there, you may need to:
# 1. Clone your repository
# 2. Install dependencies: npm install
# 3. Build: npm run build
# 4. Start: pm2 start ecosystem.config.js
```

## Get All IPs from Terraform

```bash
cd /mnt/c/Users/sduse/Downloads/Python/devops/terraform
terraform output
```

This will show all your service IPs and connection strings.

