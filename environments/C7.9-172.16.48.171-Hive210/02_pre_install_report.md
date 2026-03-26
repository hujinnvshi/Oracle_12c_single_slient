# Oracle 12c 安装前环境检查报告

**服务器标识**: C7.9-172.16.48.171-Hive210
**Oracle 版本**: 12.2.0.1
**检查日期**: 2026-03-26
**执行人**: __________

---

## 一、服务器基础信息

| 项目 | 内容 | 状态 |
|------|------|------|
| **主机名** | | ⬜ 通过 |
| **IP 地址** | 172.16.48.171 | ⬜ 通过 |
| **操作系统** | CentOS 7.9 / RHEL 7.x | ⬜ 通过 |
| **内核版本** | | ⬜ 通过 |
| **系统架构** | x86_64 | ⬜ 通过 |
| **CPU 核心数** | | ⬜ 通过 |

---

## 二、硬件配置检查

| 项目 | 要求 | 实际值 | 状态 |
|------|------|--------|------|
| **物理内存** | ≥ 2GB | ___ MB | ⬜ ⬜ |
| **可用内存** | ≥ 1GB | ___ MB | ⬜ ⬜ |
| **交换空间** | ≥ 2GB | ___ MB | ⬜ ⬜ |
| **磁盘空间(/)** | ≥ 8GB | ___ GB | ⬜ ⬜ |
| **磁盘空间(/data)** | ≥ 50GB | ___ GB | ⬜ ⬜ |

**备注**: _______________________________________________

---

## 三、用户和组检查

| 项目 | 状态 | 说明 |
|------|------|------|
| **oinstall 组** | ⬜ 已创建 / ⬜ 已存在 | GID: _____ |
| **dba 组** | ⬜ 已创建 / ⬜ 已存在 | GID: _____ |
| **oper 组** | ⬜ 已创建 / ⬜ 已存在 | GID: _____ |
| **oracle 用户** | ⬜ 已创建 / ⬜ 已存在 | UID: _____ |
| **用户组验证** | ⬜ 通过 | groups oracle |

**Oracle 用户信息**:
```
(执行: id oracle)
```

---

## 四、目录结构检查

| 目录路径 | 状态 | 权限 | 所有者 |
|----------|------|------|--------|
| `/data/u01/app/oracle` | ⬜ 已创建 | | |
| `/data/u01/app/oraInventory` | ⬜ 已创建 | | |
| `/data/u01/app/oracle/oradata` | ⬜ 已创建 | | |
| `/data/u01/app/oracle/fast_recovery_area` | ⬜ 已创建 | | |
| `/home/oracle/response_files` | ⬜ 已创建 | | |

**验证命令**:
```bash
ls -la /data/u01/app/
```

---

## 五、内核参数检查

| 参数 | 要求 | 当前值 | 状态 |
|------|------|--------|------|
| **fs.file-max** | 6815744 | | ⬜ ⬜ |
| **kernel.shmmax** | 68719476736 | | ⬜ ⬜ |
| **kernel.shmall** | 4294967296 | | ⬜ ⬜ |
| **kernel.shmmni** | 4096 | | ⬜ ⬜ |
| **kernel.sem** | 250 32000 100 128 | | ⬜ ⬜ |
| **fs.aio-max-nr** | 1048576 | | ⬜ ⬜ |

**验证命令**:
```bash
sysctl -a | grep -E "file-max|shmmax|shmall|shmmni|sem|aio-max-nr"
```

**配置文件**: ⬜ `/etc/sysctl.conf` 已修改
**使生效**: ⬜ 已执行 `sysctl -p`

---

## 六、用户限制检查

| 限制项 | 软限制 | 硬限制 | 状态 |
|--------|--------|--------|------|
| **max user processes** | 2047 | 16384 | ⬜ ⬜ |
| **open files** | 1024 | 65536 | ⬜ ⬜ |
| **stack size** | 10240 | 32768 | ⬜ ⬜ |

**验证命令**:
```bash
su - oracle
ulimit -a
```

**配置文件**: ⬜ `/etc/security/limits.conf` 已修改
**配置文件**: ⬜ `/etc/pam.d/login` 已修改

---

## 七、依赖包检查

| 包名 | 状态 | 版本 |
|------|------|------|
| **binutils** | ⬜ ⬜ | |
| **compat-libcap1** | ⬜ ⬜ | |
| **compat-libstdc++-33** | ⬜ ⬜ | |
| **gcc** | ⬜ ⬜ | |
| **gcc-c++** | ⬜ ⬜ | |
| **glibc** | ⬜ ⬜ | |
| **glibc-devel** | ⬜ ⬜ | |
| **ksh** | ⬜ ⬜ | |
| **libaio** | ⬜ ⬜ | |
| **libaio-devel** | ⬜ ⬜ | |
| **libgcc** | ⬜ ⬜ | |
| **libstdc++** | ⬜ ⬜ | |
| **libstdc++-devel** | ⬜ ⬜ | |
| **libXext** | ⬜ ⬜ | |
| **libXtst** | ⬜ ⬜ | |
| **libX11** | ⬜ ⬜ | |
| **libXau** | ⬜ ⬜ | |
| **libxcb** | ⬜ ⬜ | |
| **libXi** | ⬜ ⬜ | |
| **make** | ⬜ ⬜ | |
| **sysstat** | ⬜ ⬜ | |
| **unixODBC** | ⬜ ⬜ | |
| **unixODBC-devel** | ⬜ ⬜ | |

**验证命令**:
```bash
rpm -q binutils compat-libcap1 compat-libstdc++-33 gcc gcc-c++ glibc glibc-devel ksh libaio libaio-devel libgcc libstdc++ libstdc++-devel libXext libXtst libX11 libXau libxcb libXi make sysstat unixODBC unixODBC-devel
```

---

## 八、安全设置检查

| 项目 | 当前状态 | 建议 |
|------|----------|------|
| **SELinux** | ⬜ Enforcing / ⬜ Permissive / ⬜ Disabled | 建议 Permissive 或 Disabled |
| **防火墙** | ⬜ 运行中 / ⬜ 已停止 | 需开放 1521, 5500 端口 |

**SELinux 修改命令**:
```bash
# 临时关闭
setenforce 0

# 永久关闭（编辑 /etc/selinux/config）
SELINUX=permissive
```

**防火墙开放端口**:
```bash
firewall-cmd --zone=public --add-port=1521/tcp --permanent
firewall-cmd --zone=public --add-port=5500/tcp --permanent
firewall-cmd --reload
```

---

## 九、主机名和 DNS 检查

| 项目 | 内容 | 状态 |
|------|------|------|
| **主机名** | | ⬜ 已设置 |
| **FQDN** | | ⬜ 正确 |
| **/etc/hosts** | ⬜ 已配置 | |

**/etc/hosts 配置示例**:
```
127.0.0.1   localhost localhost.localdomain
172.16.48.171  hive210.example.com  hive210
```

---

## 十、环境变量配置

| 变量 | 值 | 状态 |
|------|-----|------|
| **ORACLE_BASE** | /data/u01/app/oracle | ⬜ 已配置 |
| **ORACLE_HOME** | /data/u01/app/oracle/product/12.2.0.1/dbhome_1 | ⬜ 已配置 |
| **ORACLE_SID** | hive210 | ⬜ 已配置 |
| **ORACLE_UNQNAME** | hive210 | ⬜ 已配置 |
| **NLS_LANG** | SIMPLIFIED CHINESE_CHINA.AL32UTF8 | ⬜ 已配置 |

**验证命令**:
```bash
su - oracle
echo $ORACLE_HOME
echo $ORACLE_SID
```

---

## 十一、安装文件准备

| 项目 | 路径 | 状态 | 说明 |
|------|------|------|------|
| **Oracle 安装包** | | ⬜ 已上传 | V839960-01.zip |
| **安装介质目录** | | ⬜ 已解压 | |
| **响应文件** | /home/oracle/response_files/ | ⬜ 已配置 | db_install.rsp, dbca.rsp, netca.rsp |

**响应文件检查**:
```bash
ls -lh /home/oracle/response_files/
```

---

## 十二、整体检查结论

| 检查项 | 通过 | 不通过 | 备注 |
|--------|------|--------|------|
| **硬件配置** | ⬜ | ⬜ | |
| **操作系统** | ⬜ | ⬜ | |
| **用户组** | ⬜ | ⬜ | |
| **目录结构** | ⬜ | ⬜ | |
| **内核参数** | ⬜ | ⬜ | |
| **用户限制** | ⬜ | ⬜ | |
| **依赖包** | ⬜ | ⬜ | |
| **安全设置** | ⬜ | ⬜ | |
| **网络配置** | ⬜ | ⬜ | |
| **环境变量** | ⬜ | ⬜ | |
| **安装文件** | ⬜ | ⬜ | |

**总体评估**:
⬜ **通过** - 可以开始安装
⬜ **条件通过** - 有小问题，但不影响安装
⬜ **不通过** - 需要先解决相关问题

---

## 十三、问题和解决方案

### 发现的问题

1.
   - **描述**:
   - **影响**:
   - **解决方案**:
   - **状态**: ⬜ 已解决 / ⬜ 待处理

2.
   - **描述**:
   - **影响**:
   - **解决方案**:
   - **状态**: ⬜ 已解决 / ⬜ 待处理

---

## 十四、执行记录

### 执行的命令

```bash
# 1. 用户组创建
# 2. 目录创建
# 3. 权限设置
# 4. 内核参数配置
# 5. 环境变量配置
```

### 执行时间

| 步骤 | 开始时间 | 结束时间 | 执行人 | 状态 |
|------|----------|----------|--------|------|
| **用户组创建** | | | | ⬜ |
| **目录创建** | | | | ⬜ |
| **权限设置** | | | | ⬜ |
| **内核参数** | | | | ⬜ |
| **依赖包安装** | | | | ⬜ |
| **环境变量** | | | | ⬜ |

---

## 十五、检查人员签字

| 角色 | 姓名 | 签字 | 日期 |
|------|------|------|------|
| **执行人** | | | |
| **审核人** | | | |
| **批准人** | | | |

---

## 十六、后续步骤

1. ⬜ 所有检查项通过后，开始 Oracle 软件安装
2. ⬜ 执行数据库软件静默安装
3. ⬜ 配置监听器
4. ⬜ 创建数据库
5. ⬜ 验证安装结果

---

**报告版本**: 1.0
**最后更新**: 2026-03-26
