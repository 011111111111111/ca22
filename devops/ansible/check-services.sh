#!/bin/bash
# Quick script to check all services

echo "========================================"
echo "Service Status Check"
echo "========================================"
echo ""

echo "Application Server (65.2.142.108):"
echo "  URL: http://65.2.142.108:3000"
echo "  Testing..."
curl -s -o /dev/null -w "  HTTP Status: %{http_code}\n" http://65.2.142.108:3000 || echo "  ⚠ Not accessible"
echo ""

echo "Nagios Server (13.201.19.105):"
echo "  URL: http://13.201.19.105/nagios"
echo "  Testing..."
curl -s -o /dev/null -w "  HTTP Status: %{http_code}\n" http://13.201.19.105/nagios || echo "  ⚠ Not accessible"
echo ""

echo "Checking services via Ansible..."
echo ""

echo "Application Server Status:"
ansible app_servers -i inventory/hosts.yml -a "pm2 list" 2>/dev/null || echo "  ⚠ Could not connect"

echo ""
echo "Database Server Status:"
ansible db_servers -i inventory/hosts.yml -a "systemctl status mongod --no-pager" 2>/dev/null || echo "  ⚠ Could not connect"

echo ""
echo "Nagios Server Status:"
ansible monitoring_servers -i inventory/hosts.yml -a "systemctl status nagios --no-pager" 2>/dev/null || echo "  ⚠ Could not connect"

echo ""
echo "========================================"
echo "Quick Access:"
echo "  Application: http://65.2.142.108:3000"
echo "  Nagios:      http://13.201.19.105/nagios"
echo "========================================"

