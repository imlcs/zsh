#########################################################################
# File Name: mysql_back.sh
# Author: Charles
# Created Time: 2025-10-29 03:02:56
#########################################################################

#!/bin/bash
set -u
set -e

# MySQL数据库分库备份脚本
# 功能：自动备份所有数据库（可排除系统库），按日期压缩存储，并自动清理旧备份

# 配置参数
MYSQL_USER="root"                    # MySQL用户名
MYSQL_PASS="3qMtilEi0BU38YCp"           # MySQL密码
MYSQL_SOCKET="127.0.0.1"       # MySQL socket文件路径
BACKUP_BASE_DIR="./db"    # 备份文件存储基础目录
KEEP_DAYS=10                         # 备份保留天数
DATE_FORMAT=$(date +%Y-%m-%d)        # 日期格式
OLD_DATE=$(date +%Y-%m-%d -d "-${KEEP_DAYS} days")

# 排除的系统数据库（不需要备份的库）
EXCLUDE_DB="information_schema|performance_schema|mysql|sys"

# 创建备份目录
[ -d "${BACKUP_BASE_DIR}/${DATE_FORMAT}" ] || mkdir -p "${BACKUP_BASE_DIR}/${DATE_FORMAT}"

# 设置MySQL连接命令
MYSQL_CMD="mysql -u${MYSQL_USER} -p${MYSQL_PASS} -h ${MYSQL_SOCKET}"
MYSQLDUMP_CMD="mysqldump -u${MYSQL_USER} -p${MYSQL_PASS} -h ${MYSQL_SOCKET}"

# 获取需要备份的数据库列表
echo "$(date +'%Y-%m-%d %H:%M:%S') 开始获取数据库列表..."
DATABASES=$(${MYSQL_CMD} -e "SHOW DATABASES;" 2>/dev/null | grep -Ev "Database|${EXCLUDE_DB}")

if [ $? -ne 0 ]; then
    echo "错误：无法连接MySQL数据库，请检查用户名、密码和socket配置"
    exit 1
fi

# 开始备份流程
echo "$(date +'%Y-%m-%d %H:%M:%S') 找到需要备份的数据库："
echo "${DATABASES}"

# 循环备份每个数据库
for DB in ${DATABASES}; do
    echo "$(date +'%Y-%m-%d %H:%M:%S') 正在备份数据库: ${DB}"

    # 使用mysqldump备份，添加常用参数确保备份一致性[1,8](@ref)
    ${MYSQLDUMP_CMD} --routines --triggers ${DB} 2>/dev/null | gzip > "${BACKUP_BASE_DIR}/${DATE_FORMAT}/${DB}.sql.gz"

    # 检查备份是否成功
    if [ $? -eq 0 ]; then
        BACKUP_SIZE=$(du -h "${BACKUP_BASE_DIR}/${DATE_FORMAT}/${DB}.sql.gz" | cut -f1)
        echo "$(date +'%Y-%m-%d %H:%M:%S') 数据库 ${DB} 备份成功，文件大小: ${BACKUP_SIZE}"

        # 记录备份日志[1](@ref)
        logger "MySQL备份: ${DB} 已成功备份 - ${DATE_FORMAT}"
    else
        echo "$(date +'%Y-%m-%d %H:%M:%S') 错误：数据库 ${DB} 备份失败"
    fi
done

# 清理过期备份
echo "$(date +'%Y-%m-%d %H:%M:%S') 正在清理 ${KEEP_DAYS} 天前的旧备份..."
if [ -d "${BACKUP_BASE_DIR}/${OLD_DATE}" ]; then
    rm -rf "${BACKUP_BASE_DIR}/${OLD_DATE}"
    echo "$(date +'%Y-%m-%d %H:%M:%S') 已清理过期备份: ${BACKUP_BASE_DIR}/${OLD_DATE}"
fi

# 显示备份结果
echo "$(date +'%Y-%m-%d %H:%M:%S') 备份完成！"
echo "备份文件保存在: ${BACKUP_BASE_DIR}/${DATE_FORMAT}/"
ls -lh "${BACKUP_BASE_DIR}/${DATE_FORMAT}/"
