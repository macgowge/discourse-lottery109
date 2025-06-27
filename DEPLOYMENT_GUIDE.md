# 🎯 Discourse 抽奖插件部署指南

## ✅ 测试结果总结

您的插件已通过所有本地测试：
- ✅ 文件结构完整
- ✅ Ruby 语法正确
- ✅ JavaScript 语法正确
- ✅ YAML 配置正确
- ✅ 资源文件兼容
- ✅ 使用了正确的 Discourse API

## 🚀 部署步骤

### 方法一：直接部署到生产环境

1. **上传插件到服务器**
   ```bash
   # 在您的 Discourse 服务器上
   cd /var/discourse/plugins
   git clone https://github.com/your-username/discourse-lottery.git
   # 或者直接复制文件夹
   ```

2. **重建 Discourse**
   ```bash
   cd /var/discourse
   ./launcher rebuild app
   ```

3. **启用插件**
   - 访问管理面板 → 设置 → 插件
   - 找到 "抽奖插件" 并启用
   - 保存设置

### 方法二：使用 Git 部署

1. **推送到 Git 仓库**
   ```bash
   cd /Users/robert/code/cfpages/discourse-lottery
   git add .
   git commit -m "修复资源预编译问题"
   git push origin main
   ```

2. **在服务器上克隆**
   ```bash
   cd /var/discourse/plugins
   git clone https://github.com/your-username/discourse-lottery.git
   ```

## 🔧 修复的问题

我们已经修复了以下导致构建失败的问题：

1. **I18n 导入问题** ✅
   - 从 `import I18n from "I18n"` 
   - 改为 `import I18n from "discourse-i18n"`

2. **插件头部格式** ✅
   - 移除了多余的缩进空格
   - 确保正确的插件元数据格式

3. **代码缩进** ✅
   - 修复了整个 plugin.rb 文件的缩进
   - 使用标准的 Ruby 缩进规范

4. **站点设置配置** ✅
   - 添加了 `config/settings.yml` 文件
   - 正确定义了 `lottery_enabled` 设置

5. **现代化 require 语句** ✅
   - 将 `require_dependency` 改为 `require_relative`

## 🎮 使用方法

插件部署成功后：

1. **创建抽奖**
   - 在帖子中添加文本 `[在此创建抽奖]`
   - 系统会自动创建一个示例抽奖

2. **自定义抽奖**
   - 修改 `lib/lottery_plugin/parser.rb` 中的解析逻辑
   - 支持自定义奖品、积分消耗、参与人数限制

3. **用户参与**
   - 用户点击 "参与抽奖" 按钮
   - 系统自动处理积分扣除和参与记录

## 🛠️ 故障排除

如果仍然遇到构建问题：

1. **检查日志**
   ```bash
   ./launcher logs app
   ```

2. **进入容器调试**
   ```bash
   ./launcher enter app
   cd /var/www/discourse
   bundle exec rake assets:precompile
   ```

3. **常见问题**
   - 确保 Discourse 版本 >= 2.8.0.beta10
   - 检查插件文件权限
   - 确保没有语法错误

## 📞 支持

如果遇到问题，请检查：
- Discourse 版本兼容性
- 服务器资源（内存、磁盘空间）
- 网络连接
- 文件权限

---

🎉 **恭喜！您的插件现在应该可以成功构建和运行了！**
