#!/bin/bash
# Check what services are actually running

echo "========================================"
echo "Checking Running Services"
echo "========================================"
echo ""

echo "Application Server (65.2.142.108):"
echo "-----------------------------------"
ansible app_servers -i inventory/hosts.yml -a "pm2 list" 2>/dev/null
ansible app_servers -i inventory/hosts.yml -a "systemctl status nginx --no-pager -l" 2>/dev/null | head -10
ansible app_servers -i inventory/hosts.yml -a "netstat -tlnp | grep :3000" 2>/dev/null
echo ""

echo "Nagios Server (13.201.19.105):"
echo "--------------------------------"
ansible monitoring_servers -i inventory/hosts.yml -a "systemctl status nagios --no-pager -l" 2>/dev/null | head -10
ansible monitoring_servers -i inventory/hosts.yml -a "systemctl status apache2 --no-pager -l" 2>/dev/null | head -10
ansible monitoring_servers -i inventory/hosts.yml -a "netstat -tlnp | grep :80" 2>/dev/null
echo ""

echo "Database Server (3.110.124.162):"
echo "---------------------------------"
ansible db_servers -i inventory/hosts.yml -a "systemctl status mongod --no-pager -l" 2>/dev/null | head -10
echo ""

echo "Testing HTTP endpoints:"
echo "--------------------------------"
echo -n "Application (port 3000): "
curl -s -o /dev/null -w "%{http_code}\n" http://65.2.142.108:3000 || echo "Not accessible"

echo -n "Nagios (port 80): "
curl -s -o /dev/null -w "%{http_code}\n" http://13.201.19.105/nagios || echo "Not accessible"

echo ""
echo "========================================"

