#!/bin/bash
#
# Oracle 12c 安装前环境准备工作脚本
# 服务器: C7.9-172.16.48.171-Hive210
# Oracle 版本: 12.2.0.1
# 创建时间: 2026-03-26
#

set -e  # 遇到错误立即退出

#-------------------------------------------------------------------------------
# 颜色定义
#-------------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

#-------------------------------------------------------------------------------
# 日志函数
#-------------------------------------------------------------------------------
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

#-------------------------------------------------------------------------------
# 检查是否为 root 用户
#-------------------------------------------------------------------------------
check_root() {
    log_step "检查用户权限..."
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用 root 用户执行此脚本"
        exit 1
    fi
    log_info "当前用户: root"
}

#-------------------------------------------------------------------------------
# 系统信息检查
#-------------------------------------------------------------------------------
check_system_info() {
    log_step "检查系统信息..."
    echo ""
    echo "=== 系统信息 ==="
    echo "主机名: $(hostname)"
    echo "IP 地址: $(hostname -I | awk '{print $1}')"
    echo "操作系统: $(cat /etc/redhat-release)"
    echo "内核版本: $(uname -r)"
    echo "架构: $(uname -m)"
    echo "CPU 核心数: $(nproc)"
    echo "总内存: $(free -h | grep Mem | awk '{print $2}')"
    echo "可用内存: $(free -h | grep Mem | awk '{print $7}')"
    echo "交换空间: $(free -h | grep Swap | awk '{print $2}')"
    echo ""
}

#-------------------------------------------------------------------------------
# 检查磁盘空间
#-------------------------------------------------------------------------------
check_disk_space() {
    log_step "检查磁盘空间..."
    echo ""
    echo "=== 磁盘使用情况 ==="
    df -h

    echo ""
    echo "=== 磁盘空间检查 ==="

    # 检查根分区空间（至少需要 8GB）
    root_space=$(df -BG / | tail -1 | awk '{print $4}' | sed 's/G//')
    if [ "$root_space" -lt 8 ]; then
        log_warn "根分区可用空间不足 8GB，当前: ${root_space}G"
    else
        log_info "根分区空间充足: ${root_space}G"
    fi

    # 检查 /data2 分区（如果存在）
    if [ -d /data2 ]; then
        data2_space=$(df -BG /data2 | tail -1 | awk '{print $4}' | sed 's/G//')
        if [ "$data2_space" -lt 50 ]; then
            log_warn "/data2 分区空间不足 50GB，当前: ${data2_space}G"
        else
            log_info "/data2 分区空间充足: ${data2_space}G"
        fi
    fi
    echo ""
}

#-------------------------------------------------------------------------------
# 检查内存要求
#-------------------------------------------------------------------------------
check_memory() {
    log_step "检查内存配置..."
    echo ""
    echo "=== 内存要求检查 ==="

    total_mem=$(free -m | grep Mem | awk '{print $2}')
    swap_mem=$(free -m | grep Swap | awk '{print $2}')

    log_info "物理内存: ${total_mem}MB"
    log_info "交换空间: ${swap_mem}MB"

    # 最小内存要求 2GB
    if [ "$total_mem" -lt 2048 ]; then
        log_error "物理内存不足，至少需要 2GB，当前: ${total_mem}MB"
        return 1
    fi

    # Swap 要求
    if [ "$total_mem" -le 2048 ]; then
        required_swap=1536
    elif [ "$total_mem" -le 16384 ]; then
        required_swap=$total_mem
    else
        required_swap=16384
    fi

    if [ "$swap_mem" -lt "$required_swap" ]; then
        log_warn "交换空间建议至少 ${required_swap}MB，当前: ${swap_mem}MB"
    else
        log_info "交换空间配置合理"
    fi
    echo ""
}

#-------------------------------------------------------------------------------
# 检查并创建用户和组
#-------------------------------------------------------------------------------
check_create_user_group() {
    log_step "检查 Oracle 用户和组..."
    echo ""

    # 检查 oinstall 组
    if grep -q ^oinstall: /etc/group; then
        log_info "oinstall 组已存在"
    else
        log_info "创建 oinstall 组..."
        groupadd oinstall
    fi

    # 检查 dba 组
    if grep -q ^dba: /etc/group; then
        log_info "dba 组已存在"
    else
        log_info "创建 dba 组..."
        groupadd dba
    fi

    # 检查 oper 组
    if grep -q ^oper: /etc/group; then
        log_info "oper 组已存在"
    else
        log_info "创建 oper 组..."
        groupadd oper
    fi

    # 检查 oracle 用户
    if id -u oracle > /dev/null 2>&1; then
        log_info "oracle 用户已存在"
        oracle_user=$(id oracle)
        echo "  $oracle_user"
    else
        log_info "创建 oracle 用户..."
        useradd -g oinstall -G dba,oper oracle
        passwd oracle
        log_info "oracle 用户创建成功"
    fi

    # 验证用户组
    echo ""
    echo "=== Oracle 用户组信息 ==="
    id oracle
    groups oracle
    echo ""
}

#-------------------------------------------------------------------------------
# 检查并创建目录
#-------------------------------------------------------------------------------
check_create_directories() {
    log_step "检查并创建 Oracle 目录..."
    echo ""

    # 基础目录
    ORACLE_BASE="/data2/u01/app/oracle"
    ORACLE_INVENTORY="/data2/u01/app/oraInventory"

    # 创建目录
    mkdir -p $ORACLE_BASE
    mkdir -p $ORACLE_INVENTORY
    mkdir -p $ORACLE_BASE/oradata
    mkdir -p $ORACLE_BASE/fast_recovery_area
    mkdir -p /home/oracle/response_files

    log_info "目录创建完成"
    echo ""
    echo "=== 创建的目录 ==="
    echo "Oracle Base: $ORACLE_BASE"
    echo "Oracle Inventory: $ORACLE_INVENTORY"
    echo "数据文件目录: $ORACLE_BASE/oradata"
    echo "恢复区目录: $ORACLE_BASE/fast_recovery_area"
    echo "响应文件目录: /home/oracle/response_files"
    echo ""

    # 设置权限
    log_step "设置目录权限..."
    chown -R oracle:oinstall /data2/u01/app/oracle
    chown -R oracle:oinstall /data2/u01/app/oraInventory
    chown -R oracle:oinstall /home/oracle/response_files

    chmod -R 775 /data2/u01/app/oracle
    chmod -R 775 /data2/u01/app/oraInventory
    chmod -R 755 /home/oracle/response_files

    log_info "权限设置完成"
    echo ""
}

#-------------------------------------------------------------------------------
# 检查并配置内核参数
#-------------------------------------------------------------------------------
check_kernel_params() {
    log_step "检查内核参数..."
    echo ""

    KERNEL_CONF="/etc/sysctl.conf"

    # 备份原配置
    if [ ! -f "${KERNEL_CONF}.bak" ]; then
        cp $KERNEL_CONF ${KERNEL_CONF}.bak
        log_info "已备份原配置到 ${KERNEL_CONF}.bak"
    fi

    echo ""
    echo "=== 当前内核参数 ==="
    echo "fs.file-max: $(sysctl fs.file-max | awk '{print $3}')"
    echo "kernel.shmmax: $(sysctl kernel.shmmax | awk '{print $3}')"
    echo "kernel.shmall: $(sysctl kernel.shmall | awk '{print $3}')"
    echo "kernel.shmmni: $(sysctl kernel.shmmni | awk '{print $3}')"
    echo "kernel.sem: $(sysctl kernel.sem | awk '{print $3}')"
    echo "fs.aio-max-nr: $(sysctl fs.aio-max-nr | awk '{print $3}')"
    echo ""

    # 检查是否需要添加参数
    log_step "检查并添加 Oracle 内核参数..."

    cat >> $KERNEL_CONF << 'EOF'

# Oracle 12c 内核参数
fs.file-max = 6815744
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
fs.aio-max-nr = 1048576
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
EOF

    log_info "内核参数已添加到 $KERNEL_CONF"
    log_warn "请执行 'sysctl -p' 使参数生效"
    echo ""
}

#-------------------------------------------------------------------------------
# 检查并配置用户限制
#-------------------------------------------------------------------------------
check_limits_conf() {
    log_step "检查用户限制..."
    echo ""

    LIMITS_CONF="/etc/security/limits.conf"

    # 备份原配置
    if [ ! -f "${LIMITS_CONF}.bak" ]; then
        cp $LIMITS_CONF ${LIMITS_CONF}.bak
        log_info "已备份原配置到 ${LIMITS_CONF}.bak"
    fi

    # 检查是否已配置
    if grep -q "oracle.*soft.*nofile" $LIMITS_CONF; then
        log_info "Oracle 用户限制已配置"
    else
        cat >> $LIMITS_CONF << 'EOF'

# Oracle 用户限制
oracle soft nproc 2047
oracle hard nproc 16384
oracle soft nofile 1024
oracle hard nofile 65536
oracle soft stack 10240
oracle hard stack 32768
EOF
        log_info "用户限制已添加到 $LIMITS_CONF"
    fi
    echo ""
}

#-------------------------------------------------------------------------------
# 检查并配置 pam
#-------------------------------------------------------------------------------
check_pam_login() {
    log_step "检查 PAM 配置..."
    echo ""

    PAM_FILE="/etc/pam.d/login"

    if grep -q "pam_limits.so" $PAM_FILE; then
        log_info "PAM 配置已存在"
    else
        echo "session required pam_limits.so" >> $PAM_FILE
        log_info "PAM 配置已添加到 $PAM_FILE"
    fi
    echo ""
}

#-------------------------------------------------------------------------------
# 检查并安装依赖包
#-------------------------------------------------------------------------------
check_install_packages() {
    log_step "检查 Oracle 依赖包..."
    echo ""

    # Oracle 12c RHEL7 依赖包列表
    PACKAGES=(
        "binutils"
        "compat-libcap1"
        "compat-libstdc++-33"
        "gcc"
        "gcc-c++"
        "glibc"
        "glibc-devel"
        "ksh"
        "libaio"
        "libaio-devel"
        "libgcc"
        "libstdc++"
        "libstdc++-devel"
        "libXext"
        "libXtst"
        "libX11"
        "libXau"
        "libxcb"
        "libXi"
        "make"
        "sysstat"
        "unixODBC"
        "unixODBC-devel"
    )

    echo "=== 检查依赖包 ==="
    for pkg in "${PACKAGES[@]}"; do
        if rpm -q $pkg > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} $pkg"
        else
            echo -e "${RED}✗${NC} $pkg (未安装)"
            MISSING_PACKAGES+=($pkg)
        fi
    done
    echo ""

    if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
        log_warn "发现 ${#MISSING_PACKAGES[@]} 个缺失的包"
        log_info "安装命令: yum install -y ${MISSING_PACKAGES[*]}"
        read -p "是否现在安装? (y/n): " install_now
        if [ "$install_now" = "y" ]; then
            yum install -y ${MISSING_PACKAGES[*]}
        fi
    else
        log_info "所有依赖包已安装"
    fi
    echo ""
}

#-------------------------------------------------------------------------------
# 检查防火墙和 SELinux
#-------------------------------------------------------------------------------
check_security_settings() {
    log_step "检查安全设置..."
    echo ""

    # SELinux
    echo "=== SELinux 状态 ==="
    selinux_status=$(getenforce)
    echo "SELinux: $selinux_status"

    if [ "$selinux_status" = "Enforcing" ]; then
        log_warn "SELinux 处于 Enforcing 模式，可能影响 Oracle 安装"
        log_info "建议临时关闭: setenforce 0"
    fi
    echo ""

    # 防火墙
    echo "=== 防火墙状态 ==="
    if systemctl is-active --quiet firewalld; then
        log_info "防火墙正在运行"
        echo "Oracle 端口: 1521 (监听器), 5500 (EM Express)"
        echo "开放端口命令示例:"
        echo "  firewall-cmd --zone=public --add-port=1521/tcp --permanent"
        echo "  firewall-cmd --zone=public --add-port=5500/tcp --permanent"
        echo "  firewall-cmd --reload"
    else
        log_info "防火墙未运行"
    fi
    echo ""
}

#-------------------------------------------------------------------------------
# 检查主机名和 hosts 文件
#-------------------------------------------------------------------------------
check_hostname() {
    log_step "检查主机名配置..."
    echo ""

    echo "=== 主机名配置 ==="
    echo "主机名: $(hostname)"
    echo "FQDN: $(hostname -f)"

    echo ""
    echo "=== /etc/hosts 内容 ==="
    grep -v "^#" /etc/hosts | grep -v "^$"

    # 检查是否包含本机
    if grep -q "$(hostname)" /etc/hosts; then
        log_info "主机名已在 hosts 文件中"
    else
        log_warn "主机名未在 hosts 文件中"
        local_ip=$(hostname -I | awk '{print $1}')
        local_hostname=$(hostname)
        log_info "建议添加: $local_ip $local_hostname"
    fi
    echo ""
}

#-------------------------------------------------------------------------------
# 生成环境变量文件
#-------------------------------------------------------------------------------
create_env_file() {
    log_step "生成环境变量文件..."
    echo ""

    ENV_FILE="/home/oracle/.bash_profile"

    # 备份原文件
    if [ ! -f "${ENV_FILE}.bak" ]; then
        cp $ENV_FILE ${ENV_FILE}.bak
        log_info "已备份原环境变量到 ${ENV_FILE}.bak"
    fi

    cat > $ENV_FILE << 'EOF'

# Oracle Environment
export ORACLE_BASE=/data2/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/12.2.0.1/dbhome_1
export ORACLE_SID=hive210
export ORACLE_UNQNAME=hive210

# 系统语言：中文 UTF-8
export LANG=zh_CN.UTF-8
# 数据库字符集：中文 + AL32UTF8（不乱码、最标准）
export NLS_LANG="SIMPLIFIED CHINESE_CHINA".AL32UTF8

# 数据库文件路径
export ORACLE_DATA_HOME=/data2/u01/app/oracle/oradata
export ORACLE_RECOVERY_HOME=/data2/u01/app/oracle/fast_recovery_area

# Path
export PATH=$ORACLE_HOME/bin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib

# SQL*Plus 格式
export SQLPATH=$ORACLE_HOME/sqlplus/admin

# 编辑器
export EDITOR=vi

# 别名
alias sqlplus='rlwrap sqlplus'
alias rman='rlwrap rman'
alias lsnrctl='rlwrap lsnrctl'

EOF

    chown oracle:oinstall $ENV_FILE
    log_info "环境变量文件已生成: $ENV_FILE"
    echo ""
}

#-------------------------------------------------------------------------------
# 生成检查报告
#-------------------------------------------------------------------------------
generate_report() {
    log_step "生成环境检查报告..."
    echo ""

    REPORT_FILE="/tmp/oracle_pre_install_report_$(date +%Y%m%d_%H%M%S).txt"

    cat > $REPORT_FILE << EOF
================================================================================
Oracle 12c 安装前环境检查报告
================================================================================

服务器信息:
  主机名: $(hostname)
  IP 地址: $(hostname -I | awk '{print $1}')
  操作系统: $(cat /etc/redhat-release)
  内核版本: $(uname -r)
  架构: $(uname -m)
  检查时间: $(date)

硬件信息:
  CPU 核心: $(nproc)
  总内存: $(free -h | grep Mem | awk '{print $2}')
  可用内存: $(free -h | grep Mem | awk '{print $7}')
  交换空间: $(free -h | grep Swap | awk '{print $2}')

磁盘信息:
$(df -h)

用户信息:
$(id oracle)

配置文件:
  内核参数: /etc/sysctl.conf
  用户限制: /etc/security/limits.conf
  PAM 配置: /etc/pam.d/login
  环境变量: /home/oracle/.bash_profile

下一步操作:
  1. 执行 'sysctl -p' 使内核参数生效
  2. 重新登录或 'source ~/.bash_profile' 使环境变量生效
  3. 上传 Oracle 安装文件和响应文件
  4. 执行静默安装

================================================================================
EOF

    log_info "检查报告已生成: $REPORT_FILE"
    cat $REPORT_FILE
    echo ""
}

#-------------------------------------------------------------------------------
# 主函数
#-------------------------------------------------------------------------------
main() {
    echo ""
    echo "================================================================================"
    echo "  Oracle 12c 安装前环境准备工作"
    echo "  服务器: C7.9-172.16.48.171-Hive210"
    echo "================================================================================"
    echo ""

    check_root
    check_system_info
    check_disk_space
    check_memory
    check_create_user_group
    check_create_directories
    check_kernel_params
    check_limits_conf
    check_pam_login
    check_install_packages
    check_security_settings
    check_hostname
    create_env_file
    generate_report

    echo ""
    echo "================================================================================"
    echo -e "${GREEN}环境准备工作完成！${NC}"
    echo "================================================================================"
    echo ""
    echo "重要提示:"
    echo "  1. 执行 'sysctl -p' 使内核参数生效"
    echo "  2. 使用 oracle 用户重新登录: 'su - oracle'"
    echo "  3. 验证环境变量: 'echo \$ORACLE_HOME'"
    echo "  4. 检查用户限制: 'ulimit -a'"
    echo ""
    echo "下一步: 上传 Oracle 安装文件和响应文件到 /home/oracle/response_files/"
    echo ""
}

# 执行主函数
main
