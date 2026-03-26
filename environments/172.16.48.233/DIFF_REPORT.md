# 配置文件差异对比报告

**服务器**: 172.16.48.233
**Oracle 版本**: 12.2.0.1
**生成时间**: 2026-03-26

## 一、db_install.rsp 差异

### 🔧 修改的参数

| 参数名 | 原始值 | 修改后值 | 说明 |
|--------|--------|----------|------|
| `oracle.install.option` | *空* | `INSTALL_DB_SWONLY` | 仅安装数据库软件 |
| `UNIX_GROUP_NAME` | *空* | `oinstall` | Unix 组名 |
| `INVENTORY_LOCATION` | *空* | `/data2/u01/app/oraInventory` | Inventory 目录 |
| `ORACLE_HOME` | *空* | `/data2/u01/app/oracle/product/12.2.0.1/dbhome_1` | Oracle 主目录 |
| `ORACLE_BASE` | *空* | `/data2/u01/app/oracle` | Oracle 基础目录 |
| `oracle.install.db.InstallEdition` | *空* | `EE` | 企业版 |
| `oracle.install.db.OSDBA_GROUP` | *空* | `dba` | DBA 组 |
| `oracle.install.db.OSOPER_GROUP` | *空* | `oper` | OPERATOR 组 |
| `oracle.install.db.OSBACKUPDBA_GROUP` | *空* | `dba` | 备份 DBA 组 |
| `oracle.install.db.OSDGDBA_GROUP` | *空* | `dba` | Data Guard DBA 组 |
| `oracle.install.db.OSKMDBA_GROUP` | *空* | `dba` | 密钥管理 DBA 组 |
| `oracle.install.db.OSRACDBA_GROUP` | *空* | `dba` | RAC DBA 组 |
| `oracle.install.db.config.starterdb.characterSet` | *空* | `ZHS16GBK` | 字符集 |
| `oracle.install.db.config.starterdb.memoryOption` | *空* | `true` | 启用内存配置 |
| `oracle.install.db.config.starterdb.memoryLimit` | *空* | `2048` | 内存限制 (MB) |

**修改参数总数**: 15 个

---

## 二、dbca.rsp 差异

### 🔧 修改的参数

| 参数名 | 原始值 | 修改后值 | 说明 |
|--------|--------|----------|------|
| `gdbName` | *空* | `or122` | 全局数据库名 |
| `sid` | *空* | `or122` | 数据库实例名 |
| `databaseConfigType` | *空* | `SI` | 单实例数据库 |
| `policyManaged` | *空* | `FALSE` | 非策略管理 |
| `createServerPool` | *空* | `FALSE` | 不创建服务器池 |
| `templateName` | *空* | `General_Purpose.dbc` | 通用模板 |
| `emConfiguration` | *空* | `NONE` | 不配置 EM |
| `datafileDestination` | *空* | `/data2/u01/app/oracle/oradata` | 数据文件位置 |
| `recoveryAreaDestination` | *空* | `/data2/u01/app/oracle/fast_recovery_area` | 恢复区位置 |
| `characterSet` | *空* | `ZHS16GBK` | 字符集 |
| `sampleSchema` | *空* | `TRUE` | 创建示例方案 |
| `totalMemory` | *空* | `2048` | 分配内存 (MB) |

**修改参数总数**: 12 个

---

## 三、netca.rsp 差异

### ✅ 无修改

netca.rsp 使用默认配置，**无需修改**。默认配置包括：
- 监听器名称: `LISTENER`
- 监听端口: `1521`
- 协议: `TCP`
- 安装类型: `typical`

---

## 四、关键配置总结

### 📍 路径配置

| 类型 | 配置值 |
|------|--------|
| **Oracle Base** | `/data2/u01/app/oracle` |
| **Oracle Home** | `/data2/u01/app/oracle/product/12.2.0.1/dbhome_1` |
| **Inventory** | `/data2/u01/app/oraInventory` |
| **数据文件** | `/data2/u01/app/oracle/oradata` |
| **恢复区** | `/data2/u01/app/oracle/fast_recovery_area` |

### 🎯 数据库配置

| 参数 | 配置值 |
|------|--------|
| **数据库名** | `or122` |
| **全局数据库名** | `or122` |
| **字符集** | `ZHS16GBK` (中文简体) |
| **内存分配** | `2048 MB` (2 GB) |
| **示例方案** | 启用 |
| **企业版** | 是 |
| **单实例** | 是 |

### 👥 操作系统组

| 组类型 | 配置值 |
|--------|--------|
| **oinstall** | Oracle 所有者组 |
| **dba** | SYSDBA 权限组 |
| **oper** | SYSOPER 权限组 |

---

## 五、重要说明

### ⚠️ 需要注意的配置

1. **字符集选择**
   - 当前: `ZHS16GBK` (中文简体)
   - 建议: 如需支持多语言，考虑 `AL32UTF8`

2. **内存配置**
   - 当前: `2048 MB` (2 GB)
   - 建议: 根据服务器实际内存调整
   - 开发环境: 1-2 GB
   - 生产环境: 根据实际需求配置

3. **示例方案**
   - 当前: 启用 (`TRUE`)
   - 说明: 会创建示例用户和表，用于学习和测试
   - 生产环境建议: 禁用

4. **Enterprise Manager**
   - 当前: 不配置 (`NONE`)
   - 说明: 减少资源占用，如需管理界面可配置为 `DBEXPRESS`

### 🔐 密码配置

**注意**: 响应文件中未配置以下密码，需要安装时设置：
- SYS 密码
- SYSTEM 密码
- PDBADMIN 密码（如创建容器数据库）

---

## 六、验证方法

### 使用 diff 命令验证

```bash
# 对比 db_install.rsp
diff rsp_templates/12.2.0.1/db_install.rsp \
  environments/172.16.48.233/db_install.rsp

# 对比 dbca.rsp
diff rsp_templates/12.2.0.1/dbca.rsp \
  environments/172.16.48.233/dbca.rsp

# 对比 netca.rsp
diff rsp_templates/12.2.0.1/netca.rsp \
  environments/172.16.48.233/netca.rsp
```

### 使用 Git 验证

```bash
# 查看修改的文件
cd "D:/Oracle 12c/code"
git diff rsp_templates/12.2.0.1/db_install.rsp \
  environments/172.16.48.233/db_install.rsp
```

---

## 七、配置文件位置

| 类型 | 路径 |
|------|------|
| **原始模板** | `rsp_templates/12.2.0.1/` |
| **修改后配置** | `environments/172.16.48.233/` |
| **修改说明** | `environments/172.16.48.233/CHANGES.md` |
| **差异报告** | `environments/172.16.48.233/DIFF_REPORT.md` |

---

**报告生成时间**: 2026-03-26
**配置状态**: ✅ 已完成
**Git 提交**: ✅ 已提交
