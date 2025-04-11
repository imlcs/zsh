#########################################################################
# File Name: hardware.sh
# Author: Charles
# Created Time: 2025-04-11 17:38:40
#########################################################################

#!/bin/bash

# 定义颜色变量
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 获取当前日期和时间
current_date=$(date "+%Y年%m月%d日 %A %H:%M:%S")
# 获取主机名
hostname=$(hostname)

# 获取操作系统及版本信息
get_os_info() {
    echo -e "${YELLOW}操作系统及版本信息:${NC}"
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo -e "${GREEN}操作系统: $NAME${NC}"
        echo -e "${GREEN}版本: $PRETTY_NAME${NC}"
    else
        echo -e "${RED}无法获取操作系统及版本信息${NC}"
    fi
}

# 获取主板信息
get_pm_info() {
    echo -e "${YELLOW}主板信息:${NC}"
    dmidecode -t 1 | grep -E "Manufacturer|Product Name|Serial Number"
}

# 获取CPU信息
get_cpu() {
    echo -e "${YELLOW}CPU信息:${NC}"
    cpu_info=$(lscpu | grep -E 'Model name|Socket|Core|Thread|CPU MHz|Architecture' | awk '/CPU MHz/{$NF=sprintf("%.2f GHz",$NF/1000)} 1')
    echo "$cpu_info" | while IFS= read -r line; do
        echo -e "${GREEN}$line${NC}"
    done
    echo -e "${GREEN}物理CPU个数：$(echo "$cpu_info" | grep -oP 'Socket\(s\):\s*\K\d+')"${NC}
}

# 获取内存信息
get_mem() {
    echo -e "${YELLOW}内存信息:${NC}"
    dmidecode_output=$(dmidecode -t memory)

    # 计算总内存，正确处理MB和GB单位
    total_memory=$(echo "$dmidecode_output" | grep -A 10 "Memory Device" | grep "Size:" | grep -v "No Module Installed" | awk '{
        if ($3 == "MB") total += $2 / 1024
        else if ($3 == "GB") total += $2
    } END {printf "%.2f GiB", total}')
    echo -e "${GREEN}当前总内存: $total_memory${NC}"

    # 提取内存槽位总数
    total_slots=$(echo "$dmidecode_output" | grep "Number Of Devices" | awk '{print $NF}')
    echo -e "${GREEN}内存槽位总数: $total_slots${NC}"

    # 提取已安装的内存模块数量
    installed_memory=$(echo "$dmidecode_output" | grep -v Volatile | grep -c "Size: [0-9]")
    echo -e "${GREEN}已安装的内存模块数量: $installed_memory${NC}"

    # 计算未使用的槽位数量
    unused_slots=$((total_slots - installed_memory))
    if [ "$unused_slots" -lt 0 ]; then
        unused_slots=0
    fi
    echo -e "${GREEN}未使用的槽位数量: $unused_slots${NC}"

    # 提取每根内存的详细信息
    echo -e "${GREEN}已安装内存的详细信息：${NC}"
    echo "$dmidecode_output" | grep -A 32 "Memory Device" | head -22 | grep -E -w "Manufacturer|Type:|Size|Speed|Part Number" | sed '/No Module Installed/d'
}

# 获取磁盘信息
get_disk() {
    echo -e "${YELLOW}磁盘信息:${NC}"
    #lsblk -d -o NAME,TYPE,SIZE | grep -v loop
    /usr/bin/df -hT | egrep -v "tmpfs|overlay2|containers"
}

# 获取物理网卡信息
get_nic_info() {
    echo -e "${YELLOW}物理网卡信息:${NC}"
    # 获取物理网卡信息，过滤掉虚拟网卡（如docker网卡）
    nic_info=$(ip -o link show | awk -F': ' '{print $2}' | grep -E '^(eth|ens|enp)')
    while IFS= read -r line; do
        echo -e "${GREEN}网卡名称: $line${NC}"
        if ip -o link show $line | grep -q "state UP"; then
            echo -e "${GREEN}状态: 已连接${NC}"
        else
            echo -e "${RED}状态: 未连接${NC}"
        fi
    done <<< "$nic_info"
}

# 定义获取显卡信息的函数
get_gpu_info() {
    echo -e "${YELLOW}GPU信息:${NC}"
    if command -v nvidia-smi &> /dev/null; then
        # 获取显卡型号
        gpu_model=$(nvidia-smi -L | head -n 1 | grep -oP 'GPU 0: \K.*(?= \()')

        # 获取显卡数量
        gpu_count=$(nvidia-smi -L | wc -l)

        # 获取显存信息（单位：MB）
        memory_total_mb=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -n 1)

        # 获取默认功率（单位：W）
        power_limit_w=$(nvidia-smi --query-gpu=power.limit --format=csv,noheader,nounits | head -n 1)

        # 将显存从 MB 转换为 GB（使用十进制方式）
        memory_total_gb=$(echo "scale=2; $memory_total_mb / 1000" | bc)

        # 输出汇总信息
        echo -e "${GREEN}GPU Model: $gpu_model${NC}"
        echo -e "${GREEN}GPU Count: $gpu_count${NC}"
        echo -e "${GREEN}Memory Total (GB): $memory_total_gb${NC}"
        echo -e "${GREEN}Power Limit (W): $power_limit_w${NC}"
    else
        echo -e "${RED}无GPU信息${NC}"
    fi
}

# 主函数
main() {
    echo -e "${YELLOW}==================== 服务器硬件信息报告 ====================${NC}"
    echo -e "${YELLOW}日期: $current_date${NC}"
    echo -e "${YELLOW}主机名: $hostname${NC}"
    echo -e "${YELLOW}============================================================${NC}"
    get_os_info
    get_pm_info
    get_cpu
    get_mem
    get_disk
    get_nic_info
    get_gpu_info
}

# 执行主函数并将输出保存到文件
main 
