# Oracle 12c Single Silent

Oracle 12c 单实例静默安装项目

## 项目说明

本项目用于 Oracle 12c 数据库的单实例静默安装部署。

## 版本信息

### Oracle 12c Release 1 (12.1.0.2) 安装包

- **Oracle 版本**: 12.1.0.2
- **安装包**: V46095-01
- **文件清单**:
  - `Oracle 12.1.0.2-V46095-01_1of2.zip` (文件1)
  - `Oracle 12.1.0.2-V46095-01_2of2.zip` (文件2)

### Oracle 12c Release 2 (12.2.0.1) 安装包

- **Oracle Database 12c Release 2 (12.2.0.1)**
  - **安装包**: V839960-01
  - **文件**: `oracle 12c V839960-01.zip`
  - **说明**: Oracle Database 12.2.0.1 基础安装软件 (Linux x86-64)

- **Oracle Grid Infrastructure 12c Release 2 (12.2.0.1)**
  - **安装包**: V840012-01
  - **文件**: `oracle 12c V840012-01.zip`
  - **说明**: Oracle Grid Infrastructure 12.2.0.1.0 (Linux x86-64)
  - **用途**: 用于 Oracle RAC 和集群安装
  - **大小**: 约 2.8 GB

## 项目结构

```
.
├── rsp_templates/          # RSP 模板文件
│   ├── 12.1.0.2/          # Oracle 12.1.0.2 版本模板
│   │   ├── db_install.rsp # 数据库安装响应文件模板
│   │   ├── dbca.rsp       # 数据库配置助手响应文件模板
│   │   └── netca.rsp      # 网络配置助手响应文件模板
│   └── 12.2.0.1/          # Oracle 12.2.0.1 版本模板
│       ├── db_install.rsp # 数据库安装响应文件模板
│       ├── dbca.rsp       # 数据库配置助手响应文件模板
│       └── netca.rsp      # 网络配置助手响应文件模板
├── environments/          # 环境配置文件
│   ├── dev/              # 开发环境
│   ├── test/             # 测试环境
│   └── prod/             # 生产环境
└── README.md             # 项目说明文档
```

### 目录说明

- **rsp_templates/**: 存放各版本的 RSP 响应文件模板
- **environments/**: 存放各个环境的实际配置文件
- **README.md**: 项目文档

## 使用方法

待补充...

## 许可证

待补充...
