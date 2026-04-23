# #!/bin/bash

dnf install -y rsync tar findutils

# 配置免密推送凭证, 为了让推送脚本完全自动化运行，不用人工输密码
echo "123456" > /etc/rsync.passwd  # 创建密码文件
chmod 600 /etc/rsync.passwd        # 安全加固

# 把自动化脚本放到合适位置
cp ./backup.sh /server/scripts/backup.sh
chmod +x /server/scripts/backup.sh

# 每天凌晨 3:00 执行备份
echo "00 03 * * * /bin/bash /server/scripts/backup.sh &>/dev/null" >> /var/spool/cron/root

echo "客户端部署完成！"