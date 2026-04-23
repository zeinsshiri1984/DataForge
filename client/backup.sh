#!/bin/bash

# 定义变量，生成: Host_IP_Date 格式目录
Date=$(date +%F-%H-%M)
Host=$(hostname)
Ip=$(hostname -I | awk '{print $1}')
Backup_Dir="/backup/${Host}_${Ip}_${Date}"

# 创建本地临时备份目录
mkdir -p $Backup_Dir

# 打包重要数据(以备份 /etc/hosts 和 /etc/passwd 为例)
tar zcf $Backup_Dir/sys_config_${Date}.tar.gz /etc/hosts /etc/passwd &>/dev/null

# 生成 MD5 校验指纹写入 md5.log 中，用于数据一致性校验校验
md5sum $Backup_Dir/*.tar.gz > $Backup_Dir/md5.log

# 推送到备份服务器
rsync -az $Backup_Dir rsync_backup@172.16.1.41::backup --password-file=/etc/rsync.passwd
# 不指定密码, 交互式下载备份服务器数据
# rsync -avz rsync_backup@10.0.41::backup/<path> ./

# 清理本地过期数据 (保留7天)
find /backup/ -mindepth 1 -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \;