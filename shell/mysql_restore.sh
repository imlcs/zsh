#########################################################################
# File Name: rstore.sh
# Author: Charles
# Created Time: 2025-10-29 11:29:43
#########################################################################

#!/bin/bash
# set -u
# set -e

# MySQL数据库分库恢复脚本
# 功能：根据分库备份文件恢复数据库，支持单库、多库或全部恢复

# 配置参数（需要与备份脚本保持一致）
MYSQL_USER="root"                    # MySQL用户名
MYSQL_PASS="3qMtilEi0BU38YCp"           # MySQL密码
MYSQL_SOCKET="127.0.0.1"       # MySQL socket文件路径
BACKUP_BASE_DIR="./db"    # 备份文件存储基础目录

# 设置MySQL连接命令
MYSQL_CMD="mysql -u${MYSQL_USER} -p${MYSQL_PASS} -h ${MYSQL_SOCKET}"

# 显示使用说明
show_usage() {
    echo "用法: $0 [选项]"
    echo "选项:"
    echo "  -d, --date DATE        指定备份日期（格式: YYYY-MM-DD），默认为最新备份"
    echo "  -db, --database DB     指定要恢复的数据库名称（多个数据库用逗号分隔）"
    echo "  -a, --all              恢复该日期下的所有数据库"
    echo "  -l, --list             列出可用的备份日期和数据库"
    echo "  -h, --help             显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 -l                                 # 列出所有备份"
    echo "  $0 -d 2023-10-25 -db mydb            # 恢复指定日期的单个数据库"
    echo "  $0 -d 2023-10-25 -db db1,db2         # 恢复指定日期的多个数据库"
    echo "  $0 -d 2023-10-25 -a                  # 恢复指定日期的所有数据库"
    echo "  $0 -a                                # 恢复最新备份的所有数据库"
}

# 列出可用的备份
list_backups() {
    echo "可用的备份日期:"
    echo "=================="
    if [ -d "$BACKUP_BASE_DIR" ]; then
        find "$BACKUP_BASE_DIR" -maxdepth 1 -type d -name "202*-*-*" | sort -r | while read dir; do
            date=$(basename "$dir")
            count=$(ls "$dir"/*.sql.gz 2>/dev/null | wc -l)
            if [ $count -gt 0 ]; then
                echo "日期: $date, 数据库数量: $count"
                # 显示该日期下的数据库列表
                ls "$dir"/*.sql.gz 2>/dev/null | xargs -n 1 basename | sed 's/.sql.gz//' | sort | uniq | while read db; do
                    echo "  - $db"
                done
                echo ""
            fi
        done
    else
        echo "错误: 备份目录不存在: $BACKUP_BASE_DIR"
        exit 1
    fi
}

# 获取最新备份日期
get_latest_backup_date() {
    if [ -d "$BACKUP_BASE_DIR" ]; then
        find "$BACKUP_BASE_DIR" -maxdepth 1 -type d -name "202*-*-*" | sort -r | head -1 | xargs basename
    else
        echo ""
    fi
}

# 恢复单个数据库
restore_database() {
    local backup_date=$1
    local db_name=$2
    local backup_file="${BACKUP_BASE_DIR}/${backup_date}/${db_name}.sql.gz"

    if [ ! -f "$backup_file" ]; then
        echo "错误: 备份文件不存在: $backup_file"
        return 1
    fi

    echo "$(date +'%Y-%m-%d %H:%M:%S') 开始恢复数据库: $db_name"

    # 检查数据库是否存在，如果存在则删除（根据需求调整）
    # 注意：这会删除现有数据库，请谨慎操作
    $MYSQL_CMD -e "DROP DATABASE IF EXISTS \`$db_name\`" 2>/dev/null
    $MYSQL_CMD -e "CREATE DATABASE \`$db_name\`" 2>/dev/null

    # 使用zcat解压并恢复数据库
    if zcat "$backup_file" | $MYSQL_CMD $db_name 2>/dev/null; then
        echo "$(date +'%Y-%m-%d %H:%M:%S') 数据库 $db_name 恢复成功"

        # 验证恢复结果
        if $MYSQL_CMD -e "USE \`$db_name\`; SHOW TABLES;" 2>/dev/null | grep -q "."; then
            table_count=$($MYSQL_CMD -N -e "USE \`$db_name\`; SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$db_name';" 2>/dev/null)
            echo "$(date +'%Y-%m-%d %H:%M:%S') 验证成功: $db_name 包含 $table_count 个表"
        else
            echo "警告: 数据库 $db_name 恢复后未检测到表"
        fi
    else
        echo "错误: 数据库 $db_name 恢复失败"
        return 1
    fi
}

# 主逻辑
main() {
    local backup_date=""
    local databases=""
    local restore_all=false
    local list_only=false

    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--date)
                backup_date="$2"
                shift 2
                ;;
            -db|--database)
                databases="$2"
                shift 2
                ;;
            -a|--all)
                restore_all=true
                shift
                ;;
            -l|--list)
                list_only=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                echo "错误: 未知参数 $1"
                show_usage
                exit 1
                ;;
        esac
    done

    # 列出备份
    if [ "$list_only" = true ]; then
        list_backups
        exit 0
    fi

    # 确定备份日期
    if [ -z "$backup_date" ]; then
        backup_date=$(get_latest_backup_date)
        if [ -z "$backup_date" ]; then
            echo "错误: 未找到任何备份文件"
            exit 1
        fi
        echo "使用最新备份日期: $backup_date"
    fi

    # 检查备份目录是否存在
    if [ ! -d "${BACKUP_BASE_DIR}/${backup_date}" ]; then
        echo "错误: 指定日期的备份不存在: ${BACKUP_BASE_DIR}/${backup_date}"
        exit 1
    fi

    # 确定要恢复的数据库
    if [ "$restore_all" = true ]; then
        # 恢复所有数据库
        databases=$(ls "${BACKUP_BASE_DIR}/${backup_date}"/*.sql.gz 2>/dev/null | xargs -n 1 basename | sed 's/.sql.gz//' | sort | uniq)
        if [ -z "$databases" ]; then
            echo "错误: 未找到可恢复的数据库"
            exit 1
        fi
    elif [ -z "$databases" ]; then
        echo "错误: 请指定要恢复的数据库或使用 --all 选项"
        show_usage
        exit 1
    else
        # 将逗号分隔的数据库转换为空格分隔
        databases=$(echo "$databases" | tr ',' ' ')
    fi

    # 确认操作（防止误操作）
    echo "即将恢复以下数据库:"
    for db in $databases; do
        echo "  - $db"
    done
    echo "备份日期: $backup_date"
    echo ""
    read -p "此操作将覆盖现有数据库！确认继续？(y/N): " confirm

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "操作已取消"
        exit 0
    fi

    # 开始恢复
    echo "$(date +'%Y-%m-%d %H:%M:%S') 开始数据库恢复流程..."

    for db in $databases; do
        if ! restore_database "$backup_date" "$db"; then
            echo "错误: 数据库 $db 恢复失败，继续下一个数据库..."
        fi
        echo ""
    done

    echo "$(date +'%Y-%m-%d %H:%M:%S') 数据库恢复流程完成！"
}

# 运行主函数
main "$@"
