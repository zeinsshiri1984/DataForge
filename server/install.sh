# #!/bin/bash

dnf install -y rsync mailx findutils

# 脚本存放位置
mkdir -p server/scripts

# Rsync 守护进程配置导入
cat ./rsyncd.conf > /etc/rsyncd.conf

# 创建启动rsync的虚拟用户
useradd -M -s /sbin/nologin rsync
# id rsync      # 查看用户id信息

# 创建 backup 目录
mkdir /backup
chown -R rsync.rsync /backup # 修改所属, 授权rsync用户读写权限
# ll -d /backup

# 创建租户密码文件(格式：用户名:密码)
echo "rsync_backup:123456" > /etc/rsync.passwd
# 安全加固
chmod 600 /etc/rsync.passwd

# 启动服务并加入开机自启
systemctl start rsyncd
systemctl enable rsyncd

# 看下873端口正常不
# ss -tnulp # netstat -tnulp

# 导入邮件配置
cat ./mail.rc >> /etc/mail.rc

# 校验与清理脚本导入
cat ./check.sh > /server/scripts/check.sh
chmod +x /server/scripts/check.sh

# 每天凌晨 7:00 执行校验 (预留 4 个小时给所有客户端上传)
echo "00 07 * * * /bin/bash /server/scripts/check.sh &>/dev/null" >> /var/spool/cron/root

echo "服务端部署完成！请使用命令：ss -tnulp | grep 873 检查端口。"