# 环境配置文件

本目录存放各个环境的 Oracle 静默安装配置文件。

## 目录结构

```
environments/
├── 172.16.48.233/      # 服务器特定配置
│   ├── CONFIG.md      # 服务器配置规划文档
│   ├── init.sh        # 初始化脚本
│   ├── db_install.rsp # 数据库安装配置
│   ├── dbca.rsp       # 数据库配置
│   └── netca.rsp      # 网络配置
├── dev/               # 开发环境（按需创建）
├── test/              # 测试环境（按需创建）
└── prod/              # 生产环境（按需创建）
```

## 使用说明

### 服务器特定配置

每个服务器目录下会包含：
- `CONFIG.md` - 该服务器的完整配置规划文档
- `init.sh` - 配置文件初始化脚本
- `db_install.rsp` - 数据库安装配置
- `dbca.rsp` - 数据库配置
- `netca.rsp` - 网络配置

### 创建新服务器配置

1. 为新服务器创建目录（如 `environments/新服务器IP/`）
2. 复制对应版本的模板文件：
   ```bash
   cp rsp_templates/12.2.0.1/*.rsp environments/新服务器IP/
   ```
3. 参考现有服务器配置创建 CONFIG.md 和 init.sh

## 环境差异

每个环境需要修改的关键参数：
- 数据库名称 (ORACLE_SID)
- 数据存储路径
- 内存配置
- 字符集设置
- 端口配置
