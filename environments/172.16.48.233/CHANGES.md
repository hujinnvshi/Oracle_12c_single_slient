# 配置文件修改摘要

**服务器**: 172.16.48.233
**Oracle 版本**: 12.2.0.1
**修改时间**: 2026-03-26

## 一、db_install.rsp 修改内容

### 基础配置
- `oracle.install.option` = `INSTALL_DB_SWONLY`
- `UNIX_GROUP_NAME` = `oinstall`
- `INVENTORY_LOCATION` = `/data2/u01/app/oraInventory`
- `ORACLE_HOME` = `/data2/u01/app/oracle/product/12.2.0.1/dbhome_1`
- `ORACLE_BASE` = `/data2/u01/app/oracle`
- `oracle.install.db.InstallEdition` = `EE` (Enterprise Edition)

### 操作系统组
- `oracle.install.db.OSDBA_GROUP` = `dba`
- `oracle.install.db.OSOPER_GROUP` = `oper`
- `oracle.install.db.OSBACKUPDBA_GROUP` = `dba`
- `oracle.install.db.OSDGDBA_GROUP` = `dba`
- `oracle.install.db.OSKMDBA_GROUP` = `dba`
- `oracle.install.db.OSRACDBA_GROUP` = `dba`

### 数据库配置（可选，用于安装时创建数据库）
- `oracle.install.db.config.starterdb.characterSet` = `ZHS16GBK`
- `oracle.install.db.config.starterdb.memoryOption` = `true`
- `oracle.install.db.config.starterdb.memoryLimit` = `2048` (MB)

## 二、dbca.rsp 修改内容

### 数据库基本信息
- `gdbName` = `or122`
- `sid` = `or122`
- `databaseConfigType` = `SI` (Single Instance)
- `policyManaged` = `FALSE`
- `createServerPool` = `FALSE`
- `templateName` = `General_Purpose.dbc`

### 存储配置
- `datafileDestination` = `/data2/u01/app/oracle/oradata`
- `recoveryAreaDestination` = `/data2/u01/app/oracle/fast_recovery_area`
- `characterSet` = `ZHS16GBK`

### 内存配置
- `totalMemory` = `2048` (MB) - 根据服务器实际内存调整

### 其他配置
- `sampleSchema` = `TRUE` (创建示例方案)
- `emConfiguration` = `NONE` (不配置 Enterprise Manager)

## 三、netca.rsp 配置

使用默认配置，无需修改：
- 监听器名称: `LISTENER`
- 监听端口: `1521`
- 协议: `TCP`
- 命名方法: `TNSNAMES`, `ONAMES`, `HOSTNAME`

## 四、环境变量配置

需要在 oracle 用户的 `~/.bash_profile` 中设置：

```bash
export ORACLE_BASE=/data2/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/12.2.0.1/dbhome_1
export ORACLE_SID=or122
export PATH=$ORACLE_HOME/bin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
```

## 五、服务器目录创建

在服务器上执行以下命令创建所需目录：

```bash
# 创建基础目录
mkdir -p /data2/u01/app/oracle
mkdir -p /data2/u01/app/oraInventory
mkdir -p /data2/u01/app/oracle/oradata
mkdir -p /data2/u01/app/oracle/fast_recovery_area

# 设置所有权
chown -R oracle:oinstall /data2/u01/app/oracle
chown -R oracle:oinstall /data2/u01/app/oraInventory

# 设置权限
chmod -R 775 /data2/u01/app/oracle
chmod -R 775 /data2/u01/app/oraInventory
```

## 六、重要提示

### ⚠️ 密码配置
- **SYS 密码**: 需要在安装时手动设置或通过响应文件配置
- **SYSTEM 密码**: 需要在安装时手动设置或通过响应文件配置
- **PDBADMIN 密码**: 如果创建容器数据库，需要设置 PDB 管理员密码

### ⚠️ 内存配置
- `totalMemory=2048` 表示分配 2GB 内存给 Oracle
- 根据服务器实际内存调整此值
- 建议: 开发环境 1-2GB，生产环境根据实际需求配置

### ⚠️ 字符集配置
- 已配置为 `ZHS16GBK`（中文简体）
- 如需支持多语言，建议使用 `AL32UTF8`

### ⚠️ 静默安装命令

#### 1. 安装数据库软件
```bash
./runInstaller -silent -responseFile /home/oracle/response_files/db_install.rsp \
  -ignorePrereq -waitforcompletion
```

#### 2. 配置监听器
```bash
$ORACLE_HOME/bin/netca /silent /responsefile /home/oracle/response_files/netca.rsp
```

#### 3. 创建数据库
```bash
$ORACLE_HOME/bin/dbca -silent -createDatabase \
  -responseFile /home/oracle/response_files/dbca.rsp
```

## 七、配置文件对比

原始模板位置: `rsp_templates/12.2.0.1/`
修改后配置位置: `environments/172.16.48.233/`

可以使用以下命令对比差异：
```bash
diff rsp_templates/12.2.0.1/db_install.rsp environments/172.16.48.233/db_install.rsp
diff rsp_templates/12.2.0.1/dbca.rsp environments/172.16.48.233/dbca.rsp
diff rsp_templates/12.2.0.1/netca.rsp environments/172.16.48.233/netca.rsp
```
