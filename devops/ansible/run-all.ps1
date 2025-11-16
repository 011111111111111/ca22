# Complete Ansible deployment script for Windows
# This script runs all Ansible playbooks in the correct order

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Ansible Complete Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
if (-not (Test-Path "playbooks\site.yml")) {
    Write-Host "Error: Please run this from the ansible directory" -ForegroundColor Red
    exit 1
}

# Check if inventory exists
if (-not (Test-Path "inventory\hosts.yml")) {
    Write-Host "Error: inventory\hosts.yml not found" -ForegroundColor Red
    Write-Host "Please run update-inventory-from-terraform.ps1 first" -ForegroundColor Yellow
    exit 1
}

# Step 1: Update inventory (if script exists)
if (Test-Path "update-inventory-from-terraform.ps1") {
    Write-Host "Step 1: Updating inventory from Terraform..." -ForegroundColor Yellow
    & .\update-inventory-from-terraform.ps1
    Write-Host ""
}

# Step 2: Test connectivity
Write-Host "Step 2: Testing connectivity to all hosts..." -ForegroundColor Yellow
ansible all -m ping

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "✗ Connection test failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please check:" -ForegroundColor Yellow
    Write-Host "  1. SSH key path is correct in inventory\hosts.yml" -ForegroundColor Yellow
    Write-Host "  2. IP addresses are correct (run: cd ..\terraform && terraform output)" -ForegroundColor Yellow
    Write-Host "  3. Security groups allow SSH (port 22)" -ForegroundColor Yellow
    Write-Host "  4. Instances are running (wait 2-3 minutes after Terraform)" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "✓ All hosts are reachable!" -ForegroundColor Green
Write-Host ""

# Step 3: Run deployment
Write-Host "Step 3: Running complete deployment..." -ForegroundColor Yellow
Write-Host "This will run all playbooks in order:" -ForegroundColor Cyan
Write-Host "  1. common.yml - Base configuration" -ForegroundColor Gray
Write-Host "  2. database.yml - MongoDB setup" -ForegroundColor Gray
Write-Host "  3. application.yml - Application deployment" -ForegroundColor Gray
Write-Host "  4. nagios.yml - Monitoring setup" -ForegroundColor Gray
Write-Host ""
Write-Host "This may take 10-15 minutes..." -ForegroundColor Yellow
Write-Host ""

# Run the main playbook
ansible-playbook playbooks\site.yml

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "✓ Deployment Completed Successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Get service IPs:" -ForegroundColor Yellow
    Write-Host "   cd ..\terraform && terraform output" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Access services:" -ForegroundColor Yellow
    Write-Host "   - Application: http://<app-ip>:3000" -ForegroundColor Gray
    Write-Host "   - Nagios: http://<nagios-ip>/nagios" -ForegroundColor Gray
    Write-Host "     Username: nagiosadmin" -ForegroundColor Gray
    Write-Host "     Password: (check inventory\hosts.yml)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Verify services:" -ForegroundColor Yellow
    Write-Host "   ansible app_servers -a 'pm2 list'" -ForegroundColor Gray
    Write-Host "   ansible db_servers -a 'systemctl status mongod'" -ForegroundColor Gray
    Write-Host "   ansible monitoring_servers -a 'systemctl status nagios'" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "✗ Deployment Failed!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Check the error messages above." -ForegroundColor Yellow
    Write-Host "Run with verbose output for details:" -ForegroundColor Yellow
    Write-Host "  ansible-playbook playbooks\site.yml -vvv" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

