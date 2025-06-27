# 🛠️ 数据库迁移故障排除指南

## 🔍 问题诊断

如果遇到数据库迁移失败，请按以下步骤排查：

### **1. 查看详细错误日志**

```bash
# 查看 Discourse 日志
./launcher logs app

# 或者进入容器查看
./launcher enter app
tail -f /var/www/discourse/log/production.log
```

### **2. 检查数据库连接**

```bash
# 进入容器
./launcher enter app

# 测试数据库连接
cd /var/www/discourse
bundle exec rails console
> ActiveRecord::Base.connection.execute("SELECT 1")
```

### **3. 手动运行迁移**

```bash
# 进入容器
./launcher enter app
cd /var/www/discourse

# 查看待执行的迁移
bundle exec rake db:migrate:status

# 手动运行特定迁移
bundle exec rake db:migrate:up VERSION=20250515000000
```

## 🔧 常见问题解决方案

### **问题1: ActiveRecord 版本不兼容**

**症状**: `uninitialized constant ActiveRecord::Migration::6.1`

**解决方案**: 已修复，使用不指定版本的迁移类

### **问题2: 表已存在**

**症状**: `relation "lottery_plugin_lotteries" already exists`

**解决方案**:
```bash
# 进入数据库
./launcher enter app
cd /var/www/discourse
bundle exec rails dbconsole

# 检查表是否存在
\dt lottery_plugin_*

# 如果存在，删除表
DROP TABLE IF EXISTS lottery_plugin_winners;
DROP TABLE IF EXISTS lottery_plugin_entries;
DROP TABLE IF EXISTS lottery_plugin_lotteries;

# 退出数据库
\q

# 重新运行迁移
bundle exec rake db:migrate
```

### **问题3: 权限不足**

**症状**: `permission denied` 或 `access denied`

**解决方案**:
```bash
# 检查数据库用户权限
./launcher enter app
cd /var/www/discourse
bundle exec rails dbconsole

# 检查当前用户
SELECT current_user;

# 检查权限
\du
```

### **问题4: 索引名称过长**

**症状**: `Index name 'xxx' is too long; the limit is 63 characters`

**解决方案**: ✅ 已修复
- 所有索引名称已缩短到 63 字符以内
- 使用自定义索引名称避免 PostgreSQL 限制

### **问题5: 索引创建失败**

**症状**: `index already exists` 或 `duplicate key`

**解决方案**:
```sql
-- 删除可能存在的索引
DROP INDEX IF EXISTS idx_lottery_post_id;
DROP INDEX IF EXISTS idx_entry_user_lottery;
-- 然后重新运行迁移
```

## 🚀 推荐的部署流程

### **方案A: 标准部署（推荐）**

```bash
# 1. 备份数据库
./launcher enter app
cd /var/www/discourse
bundle exec rake db:backup

# 2. 复制插件
cp -r /path/to/discourse-lottery /var/discourse/plugins/

# 3. 重建容器
./launcher rebuild app
```

### **方案B: 手动迁移部署**

```bash
# 1. 复制插件（不重建）
cp -r /path/to/discourse-lottery /var/discourse/plugins/

# 2. 进入容器
./launcher enter app
cd /var/www/discourse

# 3. 手动运行迁移
bundle exec rake db:migrate

# 4. 预编译资源
bundle exec rake assets:precompile

# 5. 重启服务
sv restart unicorn
```

### **方案C: 分步骤部署**

如果一次性迁移失败，可以分步骤：

```bash
# 1. 只创建基础表
bundle exec rake db:migrate:up VERSION=20250515000000

# 2. 检查表是否创建成功
bundle exec rails console
> LotteryPlugin::Lottery.connection.table_exists?('lottery_plugin_lotteries')

# 3. 如果成功，继续其他步骤
```

## 📋 迁移文件说明

### **新的统一迁移文件**

我们已经将所有迁移合并为一个文件：
- `20250515000000_create_lottery_plugin_tables.rb`

**包含的表结构**:
- `lottery_plugin_lotteries` - 抽奖主表
- `lottery_plugin_entries` - 参与记录表
- `lottery_plugin_winners` - 获奖者表

**包含的索引**:
- 主键索引
- 外键索引
- 唯一性约束索引
- 查询优化索引

## ⚠️ 注意事项

1. **备份数据**: 在任何迁移前都要备份数据库
2. **测试环境**: 建议先在测试环境验证
3. **权限检查**: 确保数据库用户有足够权限
4. **版本兼容**: 确认 Discourse 版本兼容性

## 🆘 紧急恢复

如果迁移导致严重问题：

```bash
# 1. 停止服务
./launcher stop app

# 2. 恢复数据库备份
./launcher enter app
# 恢复备份文件

# 3. 移除插件
rm -rf /var/discourse/plugins/discourse-lottery

# 4. 重启服务
./launcher start app
```

## 📞 获取帮助

如果问题仍然存在：

1. 收集完整的错误日志
2. 记录 Discourse 版本信息
3. 记录数据库版本信息
4. 提供迁移执行的具体步骤

---

**记住：数据安全第一，迁移前务必备份！** 🔒
