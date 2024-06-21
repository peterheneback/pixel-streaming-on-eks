#!/bin/sh

# Determine external ip address
if [ -z "$EXTERNAL_IP" ]; then
    EXTERNAL_IP=$(curl -s https://checkip.amazonaws.com/)
fi

# Get internal ip address from eth0
if [ -z "$INTERNAL_IP" ]; then
    INTERNAL_IP=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
fi

USER=$(aws secretsmanager get-secret-value --secret-id pixel/ice/user --query "SecretString" --output text)
PASSWORD=$(aws secretsmanager get-secret-value --secret-id pixel/ice/password --query "SecretString" --output text)

sed -e "s/USERCREDS/${USER}:${PASSWORD}/" -i /etc/turnserver.conf
turnserver --log-file=stdout --external-ip="$EXTERNAL_IP" --listening-ip="$INTERNAL_IP" 
