#!/bin/bash

# 生成当天的日期变量，用于命名日志文件
Date=$(date +%F)
LogFile="/backup/check_${Date}.log"

# 批量校验客户端推过来的 md5.log
# 路径匹配规则 /backup/*_*_*/ 代表匹配带有"主机名_IP_时间"格式的目录
# md5sum -c 会读取文件里面的路径并和对应的文件做哈希比对，并将结果输出到当天的日志文件中
md5sum -c /backup/*_*_*/*.log > $LogFile

# 判断校验结果并发送邮件
# 如果有被篡改或损坏的文件，md5sum 会输出 FAILED
Fail_Count=$(grep -c -i "FAILED" $LogFile)

if [ $Fail_Count -ge 1 ]; then
    mail -s "【警告】$Date 备份校验失败！存在篡改或丢失" 2532437535@qq.com < $LogFile
else
    mail -s "【正常】$Date 全网备份数据一致性校验成功" 2532437535@qq.com < $LogFile
fi

# 服务端清理过期数据 (保留 180 天); 限制深度，防止将 /backup 根目录误删
find /backup/ -mindepth 1 -maxdepth 1 -type d -mtime +180 -exec rm -rf {} \;