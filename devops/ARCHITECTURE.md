# Digital Wardrobe Application - Infrastructure Architecture

## Overview

This document describes the infrastructure architecture for the Digital Wardrobe Application, deployed using Infrastructure as Code (IaC) principles with Terraform, Ansible, and Nagios.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        AWS Cloud                             │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Internet Gateway                          │  │
│  └──────────────────────────────────────────────────────┘  │
│                          │                                   │
│                          │                                   │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              VPC (Default)                            │  │
│  │                                                       │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐ │  │
│  │  │   App Server │  │  DB Server  │  │ Nagios     │ │  │
│  │  │   (EC2)      │  │   (EC2)     │  │ Server     │ │  │
│  │  │              │  │             │  │ (EC2)      │ │  │
│  │  │ Node.js      │  │ MongoDB     │  │ Nagios     │ │  │
│  │  │ Nginx        │  │ 7.0         │  │ Core       │ │  │
│  │  │ PM2          │  │             │  │ Apache     │ │  │
│  │  │ Port: 3000   │  │ Port: 27017│  │ Port: 80   │ │  │
│  │  └──────┬───────┘  └──────┬──────┘  └─────┬──────┘ │  │
│  │         │                  │               │         │  │
│  │         └──────────────────┴───────────────┘         │  │
│  │                    Security Groups                     │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              S3 Bucket                                 │  │
│  │         (File Storage)                                 │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              IAM Roles & Policies                      │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. Application Server

**Purpose**: Hosts the Digital Wardrobe Node.js application

**Specifications**:
- **Instance Type**: t3.micro (configurable)
- **OS**: Ubuntu 22.04 LTS
- **Runtime**: Node.js 20.x
- **Process Manager**: PM2
- **Web Server**: Nginx (reverse proxy)
- **Port**: 3000 (internal), 80/443 (external via Nginx)

**Components**:
- Next.js application server
- API endpoints
- File upload handling
- Background removal service integration

**Security**:
- Security group allows:
  - SSH (port 22) from anywhere
  - HTTP (port 80) from anywhere
  - HTTPS (port 443) from anywhere
  - Application port (3000) from anywhere
  - NRPE (port 5666) from Nagios server only

**IAM Role**:
- S3 read/write access for file storage

### 2. Database Server

**Purpose**: Hosts MongoDB database for application data

**Specifications**:
- **Instance Type**: t3.micro (configurable)
- **OS**: Ubuntu 22.04 LTS
- **Database**: MongoDB 7.0
- **Port**: 27017

**Components**:
- MongoDB server
- Database: Digital_Wardrobe
- Collections: Users, Clothing Items, Outfits, etc.

**Security**:
- Security group allows:
  - SSH (port 22) from anywhere
  - MongoDB (port 27017) from App Server only
  - NRPE (port 5666) from Nagios server only

**Data Storage**:
- Data directory: `/data/db`
- Log directory: `/var/log/mongodb`

### 3. Nagios Monitoring Server

**Purpose**: Monitors infrastructure and application health

**Specifications**:
- **Instance Type**: t3.micro (configurable)
- **OS**: Ubuntu 22.04 LTS
- **Monitoring**: Nagios Core 4.4.6
- **Web Interface**: Apache + PHP
- **Port**: 80 (HTTP), 443 (HTTPS)

**Components**:
- Nagios Core
- Nagios Plugins
- NRPE (for remote checks)
- Apache web server
- PHP

**Security**:
- Security group allows:
  - SSH (port 22) from anywhere
  - HTTP (port 80) from anywhere
  - HTTPS (port 443) from anywhere

**Monitoring Capabilities**:
- Host availability (PING)
- Service status (HTTP, MongoDB, SSH)
- System resources (CPU, memory, disk)
- Process monitoring (Node.js, MongoDB)
- Custom application health checks

### 4. S3 Bucket

**Purpose**: Stores uploaded clothing images and processed files

**Specifications**:
- **Storage Class**: Standard
- **Versioning**: Enabled
- **Public Access**: Limited to uploads folder

**Configuration**:
- Bucket policy allows public read access to `/uploads/*`
- IAM role grants application server read/write access

### 5. Security Groups

**App Server Security Group**:
- Inbound: SSH (22), HTTP (80), HTTPS (443), App (3000), NRPE (5666 from Nagios)
- Outbound: All traffic

**DB Server Security Group**:
- Inbound: SSH (22), MongoDB (27017 from App), NRPE (5666 from Nagios)
- Outbound: All traffic

**Nagios Security Group**:
- Inbound: SSH (22), HTTP (80), HTTPS (443)
- Outbound: All traffic

## Network Flow

1. **User Request Flow**:
   ```
   Internet → App Server (Nginx) → Node.js App (Port 3000) → MongoDB (if needed)
   ```

2. **File Upload Flow**:
   ```
   User → App Server → S3 Bucket (via IAM role)
   ```

3. **Monitoring Flow**:
   ```
   Nagios Server → NRPE Agents (on App & DB servers) → System Metrics
   ```

## Deployment Flow

1. **Terraform** provisions infrastructure:
   - Creates EC2 instances
   - Configures security groups
   - Sets up S3 bucket
   - Creates IAM roles

2. **Ansible** configures servers:
   - Installs system packages
   - Configures MongoDB
   - Deploys application
   - Sets up Nagios
   - Configures NRPE agents

3. **Nagios** starts monitoring:
   - Discovers hosts
   - Executes checks
   - Sends alerts (if configured)

## Scalability Considerations

### Horizontal Scaling
- Application servers can be added behind a load balancer
- MongoDB can be configured as a replica set
- Multiple Nagios servers for redundancy

### Vertical Scaling
- Instance types can be upgraded (t3.small, t3.medium, etc.)
- Database can be moved to managed service (DocumentDB)

### High Availability
- Multi-AZ deployment
- Database replication
- Load balancer for application servers
- Backup and disaster recovery

## Security Best Practices

1. **Network Security**:
   - Security groups restrict access
   - MongoDB only accessible from app server
   - NRPE only accessible from Nagios server

2. **Access Control**:
   - SSH key-based authentication
   - IAM roles for AWS resource access
   - Nagios web interface password protected

3. **Data Protection**:
   - S3 versioning enabled
   - Regular backups (to be implemented)
   - Encrypted connections (HTTPS to be configured)

4. **Monitoring**:
   - Continuous health monitoring
   - Alerting on critical issues
   - Log aggregation (to be implemented)

## Cost Optimization

- **Instance Types**: Using t3.micro for cost efficiency
- **Storage**: S3 standard storage with lifecycle policies (to be configured)
- **Reserved Instances**: Consider for production workloads
- **Auto Scaling**: Implement for variable workloads

## Future Enhancements

1. **Load Balancer**: Application Load Balancer for multiple app servers
2. **CDN**: CloudFront for static content delivery
3. **Containerization**: Docker and ECS/EKS for container orchestration
4. **CI/CD**: GitHub Actions or GitLab CI for automated deployments
5. **Logging**: CloudWatch Logs or ELK stack
6. **Backup**: Automated database backups to S3
7. **SSL/TLS**: Let's Encrypt certificates for HTTPS

---

This architecture provides a solid foundation for the Digital Wardrobe Application with room for growth and enhancement.

