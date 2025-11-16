# PowerShell script to update Ansible inventory from Terraform outputs
# This script reads Terraform outputs and updates the inventory file

$terraformDir = "..\terraform"
$inventoryFile = "inventory\hosts.yml"

Write-Host "Updating Ansible inventory from Terraform outputs..." -ForegroundColor Cyan

# Change to terraform directory and get outputs
Push-Location $terraformDir
try {
    $outputs = terraform output -json | ConvertFrom-Json
    
    $appIp = $outputs.app_instance_public_ip.value
    $dbIp = $outputs.db_instance_public_ip.value
    $nagiosIp = $outputs.nagios_instance_public_ip.value
    
    Write-Host "Found IPs:" -ForegroundColor Green
    Write-Host "  App Server:    $appIp" -ForegroundColor Yellow
    Write-Host "  DB Server:     $dbIp" -ForegroundColor Yellow
    Write-Host "  Nagios Server: $nagiosIp" -ForegroundColor Yellow
} finally {
    Pop-Location
}

# Get SSH key path (default or from user)
$sshKey = Read-Host "Enter SSH key path (default: ~/.ssh/devops.pem)"
if ([string]::IsNullOrWhiteSpace($sshKey)) {
    $sshKey = "~/.ssh/devops.pem"
}

# Get Nagios admin password
$nagiosPassword = Read-Host "Enter Nagios admin password (default: changeme123)"
if ([string]::IsNullOrWhiteSpace($nagiosPassword)) {
    $nagiosPassword = "changeme123"
}

# Create inventory content
$inventoryContent = @"
---
all:
  children:
    app_servers:
      hosts:
        app_server:
          ansible_host: $appIp
          ansible_user: ubuntu
          ansible_ssh_private_key_file: $sshKey
          app_port: 3000
          node_version: "20.x"
    
    db_servers:
      hosts:
        db_server:
          ansible_host: $dbIp
          ansible_user: ubuntu
          ansible_ssh_private_key_file: $sshKey
          mongodb_version: "7.0"
          mongodb_port: 27017
    
    monitoring_servers:
      hosts:
        nagios_server:
          ansible_host: $nagiosIp
          ansible_user: ubuntu
          ansible_ssh_private_key_file: $sshKey
          nagios_admin_user: nagiosadmin
          nagios_admin_password: "$nagiosPassword"
"@

# Write to inventory file
$inventoryContent | Out-File -FilePath $inventoryFile -Encoding utf8 -NoNewline

Write-Host "`n✓ Inventory file updated: $inventoryFile" -ForegroundColor Green
Write-Host "`nYou can now run Ansible playbooks:" -ForegroundColor Cyan
Write-Host "  ansible-playbook playbooks/site.yml" -ForegroundColor Yellow

