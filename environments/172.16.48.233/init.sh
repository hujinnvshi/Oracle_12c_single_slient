#!/bin/bash
#
# 初始化 Oracle 12.2.0.1 配置文件
# 服务器: 172.16.48.233
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEMPLATE_DIR="$PROJECT_ROOT/rsp_templates/12.2.0.1"

echo "========================================"
echo "Oracle 12.2.0.1 配置文件初始化"
echo "服务器: 172.16.48.233"
echo "========================================"
echo ""

# 检查模板文件是否存在
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "错误: 模板目录不存在: $TEMPLATE_DIR"
    exit 1
fi

# 复制模板文件
echo "正在复制模板文件..."
cp "$TEMPLATE_DIR/db_install.rsp" "$SCRIPT_DIR/"
cp "$TEMPLATE_DIR/dbca.rsp" "$SCRIPT_DIR/"
cp "$TEMPLATE_DIR/netca.rsp" "$SCRIPT_DIR/"

echo "✓ 已复制以下文件到 $SCRIPT_DIR/:"
echo "  - db_install.rsp"
echo "  - dbca.rsp"
echo "  - netca.rsp"
echo ""

echo "下一步操作:"
echo "1. 编辑配置文件，修改以下关键参数:"
echo "   - ORACLE_HOSTNAME=172.16.48.233"
echo "   - ORACLE_BASE=/data2/u01/app/oracle"
echo "   - ORACLE_HOME=/data2/u01/app/oracle/product/12.2.0.1/dbhome_1"
echo "   - ORACLE_SID=or122"
echo "   - ORACLE_CHARACTERSET=ZHS16GBK"
echo "   - 数据库内存等参数"
echo ""
echo "2. 将配置文件上传到服务器:"
echo "   scp db_install.rsp oracle@172.16.48.233:/home/oracle/response_files/"
echo "   scp dbca.rsp oracle@172.16.48.233:/home/oracle/response_files/"
echo "   scp netca.rsp oracle@172.16.48.233:/home/oracle/response_files/"
echo ""
echo "3. 在服务器上执行静默安装"
echo ""
