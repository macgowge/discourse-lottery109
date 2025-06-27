# 📚 Discourse 抽奖插件文档索引

## 📖 用户文档

### 🚀 快速开始
- **[快速入门指南](QUICK_START_GUIDE.md)** - 5分钟快速上手，包含常用模板
- **[完整使用指南](COMPLETE_LOTTERY_GUIDE.md)** - 详细的功能说明和使用方法

### 🎯 功能指南
- **[基础使用指南](USAGE_GUIDE.md)** - 基本抽奖创建和参与
- **[开奖完整指南](LOTTERY_DRAW_GUIDE.md)** - 手动开奖流程详解
- **[定时开奖功能](AUTO_DRAW_GUIDE.md)** - 自动开奖和倒计时功能
- **[多奖品功能](MULTIPLE_PRIZES_GUIDE.md)** - 多获奖者和排名系统

## 🔧 技术文档

### 📦 安装部署
- **[部署指南](DEPLOYMENT_GUIDE.md)** - 完整的安装和部署说明
- **[README](README.md)** - 项目概述和基本信息

### 🧪 测试文档
- **[插件测试](test_plugin.rb)** - 基础功能测试脚本
- **[资源测试](test_assets.rb)** - 前端资源兼容性测试
- **[定时功能测试](test_auto_draw.rb)** - 自动开奖功能测试
- **[多奖品测试](test_multiple_prizes.rb)** - 多奖品功能测试

## 📋 参考资料

### 🎮 使用示例

#### 基础抽奖
```
[lottery title="每日福利" prize="100积分" cost="0" max="20"]
```

#### 付费抽奖
```
[lottery title="iPhone抽奖" prize="iPhone 15 Pro" cost="500" max="50"]
```

#### 多奖品抽奖
```
[lottery title="三重大奖" prize="现金红包" count="3" cost="100"]
```

#### 定时抽奖
```
[lottery title="晚间抽奖" prize="MacBook" auto_draw="2024-12-25 20:00"]
```

#### 限时多奖品
```
[lottery title="2小时限时抽奖" prize="礼品" count="5" auto_draw="2h"]
```

### 🔧 参数速查

| 参数 | 别名 | 说明 | 示例 | 默认值 |
|------|------|------|------|--------|
| `title` | `name` | 抽奖标题 | `title="新年抽奖"` | "社区抽奖" |
| `prize` | `reward` | 奖品名称 | `prize="iPhone 15"` | "神秘奖品" |
| `cost` | `points` | 参与积分 | `cost="100"` | 0 |
| `max` | `limit` | 最大人数 | `max="50"` | 无限制 |
| `count` | `winners` | 奖品个数 | `count="3"` | 1 |
| `auto_draw` | `draw_at` | 自动开奖 | `auto_draw="2h"` | 无 |

### ⏰ 时间格式

| 格式 | 说明 | 示例 |
|------|------|------|
| `Ns` | N秒后 | `30s`, `300s` |
| `Nm` | N分钟后 | `5m`, `30m` |
| `Nh` | N小时后 | `1h`, `24h` |
| `Nd` | N天后 | `1d`, `7d` |
| `YYYY-MM-DD HH:MM` | 绝对时间 | `2024-12-25 20:00` |
| `YYYY-MM-DD` | 日期 | `2024-12-25` |

## 🎯 功能特性

### ✅ 已实现功能
- 🎁 灵活的抽奖创建
- 👥 用户参与系统
- 🎲 手动开奖功能
- ⏰ 定时自动开奖
- 🏆 多奖品支持
- 📊 排名系统
- 🌍 多语言支持
- 📱 响应式设计
- 🔧 管理员控制
- 📈 完整状态管理

### 🚀 计划功能
- 📧 获奖者邮件通知
- 📊 抽奖统计报告
- 🎁 奖品分类管理
- 📱 移动端APP支持
- 🔔 实时推送通知

## 🛠️ 开发信息

### 📁 项目结构
```
discourse-lottery/
├── app/
│   ├── controllers/          # 控制器
│   ├── models/              # 数据模型
│   └── jobs/                # 后台任务
├── assets/
│   ├── javascripts/         # 前端JS
│   └── stylesheets/         # 样式文件
├── config/
│   └── locales/             # 多语言文件
├── db/
│   └── migrate/             # 数据库迁移
├── lib/                     # 核心逻辑
└── docs/                    # 文档文件
```

### 🔧 技术栈
- **后端**: Ruby on Rails
- **前端**: JavaScript ES6
- **样式**: SCSS
- **数据库**: PostgreSQL
- **任务队列**: Discourse Jobs

## 📞 支持与反馈

### 🆘 获取帮助
1. 查看相关文档
2. 搜索已知问题
3. 提交新的 Issue
4. 联系技术支持

### 🤝 贡献指南
- 欢迎提交 Pull Request
- 报告 Bug 和问题
- 提出功能建议
- 改进文档

---

**选择合适的文档开始您的抽奖之旅！** 🎉
