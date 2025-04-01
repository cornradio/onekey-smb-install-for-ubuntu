#!/bin/bash

# Update package list
sudo apt update

# Install Samba
sudo apt install samba -y

# Prompt user to enter the shared directory path
read -p "Please enter the path of the directory to be shared: " shared_dir

# Prompt user to enter the username
read -p "Please enter the Samba username (must be an existing system user): " username

# Prompt user to enter the password (encrypted)
read -s -p "Please enter the Samba password: " password
echo

# Backup Samba configuration file
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

# Remove existing [shared_folder] configuration section
sudo sed -i '/\[shared_folder\]/,/^\s*$/d' /etc/samba/smb.conf

# Add shared information to Samba configuration file
cat << EOF | sudo tee -a /etc/samba/smb.conf > /dev/null
[shared_folder]
   comment = Shared Folder
   path = $shared_dir
   browsable = yes
   read only = no
   guest ok = no
   valid users = $username
   create mask = 0750
   directory mask = 0750
EOF

# Set Samba user password
(echo "$password"; echo "$password") | sudo smbpasswd -s -a $username

# Restart Samba service
sudo systemctl restart smbd nmbd

# Open firewall ports
sudo ufw allow samba

# Get the current server IP address
ip_address=$(hostname -I | awk '{print $1}')

# Output access instructions
echo "Samba share has been securely configured."
echo "You can access the shared directory from other devices on the same network using smb://$ip_address (macOS) or \\\\$ip_address (Windows)."
echo "Username: $username"
echo "Please use the previously entered password to access."
