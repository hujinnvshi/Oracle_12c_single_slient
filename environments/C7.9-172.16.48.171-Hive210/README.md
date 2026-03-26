# Oracle 12c 安装准备文档

**服务器**: C7.9-172.16.48.171-Hive210
**Oracle 版本**: 12.2.0.1
**创建时间**: 2026-03-26

---

## 📋 文档清单

本目录包含以下安装准备文档：

| 文件名 | 类型 | 说明 |
|--------|------|------|
| `01_pre_install_check.sh` | Shell 脚本 | 自动化环境检查和配置脚本 |
| `02_pre_install_report.md` | Markdown | 手工环境检查记录表 |
| `README.md` | Markdown | 本文档，快速参考指南 |

---

## 🚀 快速开始

### 方法一：自动化脚本（推荐）

```bash
# 1. 上传脚本到服务器
scp 01_pre_install_check.sh root@172.16.48.171:/tmp/

# 2. 登录服务器
ssh root@172.16.48.171

# 3. 赋予执行权限
chmod +x /tmp/01_pre_install_check.sh

# 4. 执行脚本
cd /tmp
./01_pre_install_check.sh

# 5. 查看生成的报告
cat /tmp/oracle_pre_install_report_*.txt
```

### 方法二：手工检查

1. 打开 `02_pre_install_report.md`
2. 按照检查清单逐项检查
3. 记录检查结果和发现的问题
4. 根据报告解决问题

---

## ✅ 关键检查项

### 必须通过的检查项（红色警告）

| 检查项 | 要求 | 检查命令 |
|--------|------|----------|
| **内存** | ≥ 2GB | `free -h` |
| **磁盘空间** | ≥ 50GB | `df -h` |
| **操作系统** | CentOS 7.x / RHEL 7.x | `cat /etc/redhat-release` |
| **架构** | x86_64 | `uname -m` |
| **oracle 用户** | 必须存在 | `id oracle` |

### 推荐配置项（黄色警告）

| 检查项 | 推荐值 | 检查命令 |
|--------|--------|----------|
| **物理内存** | ≥ 4GB | `free -h` |
| **交换空间** | ≥ 4GB | `free -h` |
| **CPU** | ≥ 2 核心 | `nproc` |
| **磁盘空间** | ≥ 100GB | `df -h` |

---

## 🛠️ 快速修复命令

### 1. 创建用户和组

```bash
groupadd oinstall
groupadd dba
groupadd oper
useradd -g oinstall -G dba,oper oracle
passwd oracle
```

### 2. 创建目录

```bash
mkdir -p /data2/u01/app/oracle
mkdir -p /data2/u01/app/oraInventory
mkdir -p /data2/u01/app/oracle/oradata
mkdir -p /data2/u01/app/oracle/fast_recovery_area
mkdir -p /home/oracle/response_files

chown -R oracle:oinstall /data2/u01/app/oracle
chown -R oracle:oinstall /data2/u01/app/oraInventory
chmod -R 775 /data2/u01/app/oracle
chmod -R 775 /data2/u01/app/oraInventory
```

### 3. 配置内核参数

```bash
cat >> /etc/sysctl.conf << 'EOF'
fs.file-max = 6815744
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
fs.aio-max-nr = 1048576
net.ipv4.ip_local_port_range = 9000 65500
EOF

sysctl -p
```

### 4. 配置用户限制

```bash
cat >> /etc/security/limits.conf << 'EOF'
oracle soft nproc 2047
oracle hard nproc 16384
oracle soft nofile 1024
oracle hard nofile 65536
oracle soft stack 10240
oracle hard stack 32768
EOF

echo "session required pam_limits.so" >> /etc/pam.d/login
```

### 5. 安装依赖包

```bash
yum install -y binutils compat-libcap1 compat-libstdc++-33 \
  gcc gcc-c++ glibc glibc-devel ksh libaio libaio-devel \
  libgcc libstdc++ libstdc++-devel libXext libXtst libX11 \
  libXau libxcb libXi make sysstat unixODBC unixODBC-devel
```

### 6. 关闭 SELinux

```bash
# 临时关闭
setenforce 0

# 永久关闭（编辑 /etc/selinux/config）
sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
```

### 7. 配置防火墙

```bash
# 开放 Oracle 端口
firewall-cmd --zone=public --add-port=1521/tcp --permanent
firewall-cmd --zone=public --add-port=5500/tcp --permanent
firewall-cmd --reload
```

---

## 🔧 环境变量配置

编辑 `/home/oracle/.bash_profile`:

```bash
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

# 别名
alias sqlplus='rlwrap sqlplus'
alias rman='rlwrap rman'
alias lsnrctl='rlwrap lsnrctl'
```

使环境变量生效：

```bash
su - oracle
source ~/.bash_profile
```

---

## 📊 验证检查

### 验证用户和组

```bash
id oracle
groups oracle
```

### 验证目录权限

```bash
ls -la /data2/u01/app/
```

### 验证内核参数

```bash
sysctl -a | grep -E "file-max|shmmax|shmall|sem|aio-max-nr"
```

### 验证用户限制

```bash
su - oracle
ulimit -a
```

### 验证环境变量

```bash
su - oracle
echo $ORACLE_HOME
echo $ORACLE_SID
echo $PATH
```

---

## ⚠️ 常见问题

### 问题 1: 内存不足

**症状**: `total_mem < 2048MB`

**解决方案**:
- 增加物理内存
- 或增加交换空间: `dd if=/dev/zero of=/swapfile bs=1G count=4`

### 问题 2: 磁盘空间不足

**症状**: `df -h` 显示可用空间 < 50GB

**解决方案**:
- 清理不必要的文件
- 或挂载额外的数据盘

### 问题 3: 依赖包缺失

**症状**: 脚本报错缺少某些包

**解决方案**:
```bash
yum install -y <缺失的包名>
```

### 问题 4: 权限问题

**症状**: `Permission denied`

**解决方案**:
```bash
# 使用 oracle 用户执行
su - oracle
# 或使用 root 用户并设置正确的权限
chown -R oracle:oinstall /data2/u01/app/oracle
```

---

## 📝 检查清单

在开始安装前，请确认以下所有项目：

- [ ] 硬件配置满足要求（内存 ≥ 2GB，磁盘 ≥ 50GB）
- [ ] 操作系统版本正确（CentOS 7.x / RHEL 7.x）
- [ ] oracle 用户和组已创建
- [ ] 所需目录已创建并设置正确权限
- [ ] 内核参数已配置并生效（sysctl -p）
- [ ] 用户限制已配置
- [ ] 所有依赖包已安装
- [ ] SELinux 已设置为 Permissive 或 Disabled
- [ ] 防火墙已配置（或已关闭）
- [ ] 主机名已正确配置
- [ ] /etc/hosts 文件已配置
- [ ] oracle 用户环境变量已配置
- [ ] Oracle 安装文件已上传
- [ ] 响应文件已配置并上传到 /home/oracle/response_files/

---

## 🎯 下一步操作

环境准备完成后，按照以下步骤进行安装：

### 1. 上传安装文件

```bash
# 上传 Oracle 安装包
scp oracle_12c_V839960-01.zip oracle@172.16.48.171:/home/oracle/

# 上传响应文件
scp db_install.rsp dbca.rsp netca.rsp oracle@172.16.48.233:/home/oracle/response_files/
```

### 2. 解压安装文件

```bash
su - oracle
cd /home/oracle
unzip oracle_12c_V839960-01.zip
```

### 3. 执行静默安装

```bash
cd database
./runInstaller -silent -responseFile /home/oracle/response_files/db_install.rsp \
  -ignorePrereq -waitforcompletion
```

### 4. 配置监听器

```bash
$ORACLE_HOME/bin/netca /silent /responsefile /home/oracle/response_files/netca.rsp
```

### 5. 创建数据库

```bash
$ORACLE_HOME/bin/dbca -silent -createDatabase \
  -responseFile /home/oracle/response_files/dbca.rsp
```

---

## 📞 支持

如有问题，请查阅：
- Oracle 官方文档: https://docs.oracle.com
- 本项目文档: `../../README.md`

---

**文档版本**: 1.0
**最后更新**: 2026-03-26
