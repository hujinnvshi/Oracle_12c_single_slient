# 服务器配置规划 - 172.16.48.233

Oracle 12.2.0.1 静默安装配置路径规划

## 一、服务器基础信息

- **服务器IP**: 172.16.48.233
- **Oracle 版本**: 12.2.0.1
- **部署方式**: 静默安装
- **部署时间**: 2026-03-26
- **数据库名称**: or122
- **全局数据库名**: or122
- **字符集**: ZHS16GBK（中文简体）
- **存储方案**: 单磁盘（/data2/u01）

## 二、配置文件路径规划

### 2.1 本地配置文件路径（项目仓库）

```
environments/172.16.48.233/
├── CONFIG.md              # 本配置规划文档
├── db_install.rsp        # 数据库安装响应文件
├── dbca.rsp              # 数据库配置响应文件
└── netca.rsp             # 网络配置响应文件
```

### 2.2 服务器端路径规划

#### 方案A：标准路径（推荐）

```
# Oracle 基础目录
/data2/u01/app/oracle/

# Oracle 软件
/data2/u01/app/oracle/product/12.2.0.1/dbhome_1

# Oracle Inventory
/data2/u01/app/oraInventory

# 数据库文件
/data2/u01/app/oracle/oradata/

# 快速恢复区
/data2/u01/app/oracle/fast_recovery_area/

# 诊断文件
/data2/u01/app/oracle/diag/

# 网络配置文件
/data2/u01/app/oracle/product/12.2.0.1/dbhome_1/network/admin/
```

#### 方案B：分离存储（如果有多块磁盘）

```
# Oracle 软件（系统盘）
/u01/app/oracle/product/12.2.0.1/dbhome_1

# 数据库文件（数据盘）
/oradata/orcl/

# 快速恢复区（备份盘）
/backup/fast_recovery_area/

# 归档日志（归档盘）
/archivelog/
```

## 三、配置文件部署位置

### 3.1 RSP 文件存放位置

```bash
# 在服务器上创建配置目录
mkdir -p /home/oracle/response_files
chown oracle:oinstall /home/oracle/response_files
chmod 755 /home/oracle/response_files

# 将 RSP 文件上传到此目录
# db_install.rsp
# dbca.rsp
# netca.rsp
```

### 3.2 安装日志路径

```bash
# 安装日志
/tmp/silent_install_$(date +%Y%m%d).log

# 数据库创建日志
/tmp/dbca_create_$(date +%Y%m%d).log

# 网络配置日志
/tmp/netca_config_$(date +%Y%m%d).log
```

## 四、环境变量配置

```bash
# 用户环境变量 ~/.bash_profile
export ORACLE_BASE=/data2/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/12.2.0.1/dbhome_1
export ORACLE_SID=or122
export PATH=$ORACLE_HOME/bin:$PATH

# 系统语言：中文 UTF-8
export LANG=zh_CN.UTF-8
# 数据库字符集：中文 + AL32UTF8（不乱码、最标准）
export NLS_LANG="SIMPLIFIED CHINESE_CHINA".AL32UTF8

# 数据库文件路径
export ORACLE_DATA_HOME=/data2/u01/app/oracle/oradata
export ORACLE_RECOVERY_HOME=/data2/u01/app/oracle/fast_recovery_area

```

## 五、静默安装命令路径

### 5.1 数据库软件安装

```bash
cd /path/to/database/response
./runInstaller -silent -responseFile /home/oracle/db_install.rsp \
  -ignorePrereq -waitforcompletion \
  2>&1 | tee /tmp/silent_install_$(date +%Y%m%d).log
```

### 5.3 监听器配置

```bash
$ORACLE_HOME/bin/netca /silent /responsefile /home/oracle/netca.rsp \
  2>&1 | tee /tmp/netca_config_$(date +%Y%m%d).log
```

### 5.2 数据库创建

```bash
$ORACLE_HOME/bin/dbca -silent -createDatabase \
  -responseFile /home/oracle/dbca.rsp \
  2>&1 | tee /tmp/dbca_create_$(date +%Y%m%d).log
```



## 六、目录权限要求

```bash
# 创建基础目录
mkdir -p /data2/u01/app/oracle
mkdir -p /data2/u01/app/oraInventory

# 设置所有权
chown -R oracle:oinstall /data2/u01/app/oracle
chown -R oracle:oinstall /data2/u01/app/oraInventory

# 设置权限
chmod -R 775 /data2/u01/app/oracle
chmod -R 775 /data2/u01/app/oraInventory
```

## 七、配置文件复制命令

```bash
# 从模板复制到服务器配置目录
cp rsp_templates/12.2.0.1/db_install.rsp environments/172.16.48.233/
cp rsp_templates/12.2.0.1/dbca.rsp environments/172.16.48.233/
cp rsp_templates/12.2.0.1/netca.rsp environments/172.16.48.233/
```

## 八、RSP 文件关键参数配置

### 8.1 db_install.rsp 关键参数

```bash
# 安装选项
oracle.install.option=INSTALL_DB_SWONLY

# 主机名
ORACLE_HOSTNAME=172.16.48.233

# Unix 组名
UNIX_GROUP_NAME=oinstall

# Inventory 目录
INVENTORY_LOCATION=/data2/u01/app/oraInventory

# 语言选择
SELECTED_LANGUAGES=en,zh_CN

# Oracle 主目录
ORACLE_HOME=/data2/u01/app/oracle/product/12.2.0.1/dbhome_1

# Oracle 基础目录
ORACLE_BASE=/data2/u01/app/oracle

# 版本
ORACLE_SID=or122

# 跳过软件更新
DECLINE_SECURITY_UPDATES=true
```

### 8.2 dbca.rsp 关键参数

```bash
# 数据库名称
GDBNAME=or122
SID=or122

# 字符集
CHARACTERSET=ZHS16GBK

# 数据文件位置
DATAFILEDESTINATION=/data2/u01/app/oracle/oradata

# 恢复区位置
RECOVERYAREADESTINATION=/data2/u01/app/oracle/fast_recovery_area

# 内存配置
TOTALMEMORY=2048  # 根据实际内存调整（单位：MB）

# 示例方案（可选）
sampleSchema=true
```

### 8.3 netca.rsp 关键参数

```bash
# 监听器配置通常使用默认值即可
# 监听端口默认为 1521
```

## 九、注意事项

1. **磁盘空间要求**:
   - 软件安装: 至少 8GB
   - 数据库文件: 根据实际需求
   - 快速恢复区: 至少与数据库文件大小相同

2. **内存要求**:
   - 最小: 2GB
   - 推荐: 4GB 以上

3. **SWAP 要求**:
   - 1-2GB RAM: 1.5倍 RAM
   - 2-16GB RAM: 与 RAM 相同
   - 16GB 以上: 16GB

4. **系统参数**:
   - kernel.shmmax >= 物理内存一半
   - kernel.shmall >= shmmax / 页面大小
   - fs.file-max >= 512 * 进程数
