#!/bin/bash

# 更新软件包列表
sudo apt update

# 安装 Samba
sudo apt install samba -y

# 提示用户输入共享目录
read -p "请输入要共享的目录路径: " shared_dir

# 提示用户输入用户名
read -p "请输入 Samba 用户的用户名(必须是系统中存在的用户): " username

# 提示用户输入密码（加密）
read -s -p "请输入 Samba 用户的密码: " password
echo

# 备份 Samba 配置文件
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

# 移除原有的 [shared_folder] 配置部分
sudo sed -i '/\[shared_folder\]/,/^\s*$/d' /etc/samba/smb.conf

# 向 Samba 配置文件添加共享信息
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

# 设置 Samba 用户密码
(echo "$password"; echo "$password") | sudo smbpasswd -s -a $username

# 重启 Samba 服务
sudo systemctl restart smbd nmbd

# 开放防火墙端口
sudo ufw allow samba

# 获取当前服务器的 IP 地址
ip_address=$(hostname -I | awk '{print $1}')

# 输出访问说明
echo "Samba 共享已安全配置完成。"
echo "你可以在同一网络的其他设备上，通过文件管理器访问 smb://$ip_address （ios） \\$ip_address (win)来访问共享目录。"
echo "用户名: $username"
echo "请使用之前输入的密码进行访问。"
    
