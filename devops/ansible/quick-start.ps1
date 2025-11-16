# Quick Start Script for Ansible Deployment
# This script automates the entire Ansible setup process

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Ansible Quick Start" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "playbooks\site.yml")) {
    Write-Host "Error: Please run this from the ansible directory" -ForegroundColor Red
    exit 1
}

# Step 1: Update inventory
Write-Host "Step 1: Updating inventory from Terraform..." -ForegroundColor Yellow
if (Test-Path "update-inventory-from-terraform.ps1") {
    & .\update-inventory-from-terraform.ps1
} else {
    Write-Host "Warning: update script not found. Please update inventory manually." -ForegroundColor Yellow
    Write-Host "See RUN_ANSIBLE.md for instructions." -ForegroundColor Yellow
    exit 1
}

Write-Host "`nStep 2: Testing connectivity..." -ForegroundColor Yellow
ansible all -m ping

if ($LASTEXITCODE -ne 0) {
    Write-Host "`nConnection test failed!" -ForegroundColor Red
    Write-Host "Please check:" -ForegroundColor Yellow
    Write-Host "  1. SSH key path is correct" -ForegroundColor Yellow
    Write-Host "  2. IP addresses are correct" -ForegroundColor Yellow
    Write-Host "  3. Security groups allow SSH (port 22)" -ForegroundColor Yellow
    Write-Host "  4. Instances are running (wait a few minutes after Terraform)" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n✓ All hosts are reachable!" -ForegroundColor Green

# Step 3: Ask if user wants to proceed
Write-Host "`nStep 3: Ready to deploy!" -ForegroundColor Yellow
$confirm = Read-Host "Do you want to run the full deployment now? (yes/no)"

if ($confirm -ne "yes") {
    Write-Host "`nYou can run the deployment manually with:" -ForegroundColor Cyan
    Write-Host "  ansible-playbook playbooks/site.yml" -ForegroundColor Yellow
    exit 0
}

Write-Host "`nStep 4: Running full deployment..." -ForegroundColor Yellow
Write-Host "This may take 10-15 minutes..." -ForegroundColor Yellow
Write-Host ""

ansible-playbook playbooks/site.yml

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✓ Deployment completed successfully!" -ForegroundColor Green
    Write-Host "`nNext steps:" -ForegroundColor Cyan
    Write-Host "  1. Get IP addresses: cd ..\terraform && terraform output" -ForegroundColor Yellow
    Write-Host "  2. Access application: http://<app-ip>:3000" -ForegroundColor Yellow
    Write-Host "  3. Access Nagios: http://<nagios-ip>/nagios" -ForegroundColor Yellow
} else {
    Write-Host "`n✗ Deployment failed!" -ForegroundColor Red
    Write-Host "Check the error messages above for details." -ForegroundColor Yellow
    Write-Host "Run with -vvv for more details: ansible-playbook playbooks/site.yml -vvv" -ForegroundColor Yellow
}

