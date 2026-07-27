#!/bin/bash
# This script runs automatically on the EC2 instance's FIRST boot (as root).
# Terraform passes it to AWS via the instance's "user data".
# Note: this is Linux bash (it runs ON the instance), not PowerShell.

# Install and start the nginx web server.
dnf install -y nginx
systemctl enable --now nginx

# Replace the default nginx page with our own.
cat > /usr/share/nginx/html/index.html <<'HTML'
<!DOCTYPE html>
<html>
  <head><title>Hello from Terraform</title></head>
  <body style="font-family: sans-serif; text-align: center; margin-top: 15vh;">
    <h1>Hello from Terraform!</h1>
    <p>This page is served by nginx on an EC2 instance that Terraform built.</p>
    <p>S3 bucket for this project: <code>${bucket_name}</code></p>
  </body>
</html>
HTML
