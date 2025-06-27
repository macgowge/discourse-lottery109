# Discourse 抽奖插件

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![版本: 1.0.9](https://img.shields.io/badge/version-1.0.9-blue.svg)](https://github.com/truman1998/discourse-lottery)
[![Discourse 版本: 2.8.0.beta10+](https://img.shields.io/badge/Discourse-2.8.0.beta10%2B-brightgreen.svg)](https://www.discourse.org/)

一个功能完整、专业级的 Discourse 抽奖插件，支持多种抽奖模式和自动化管理。包含手动/自动开奖、多奖品支持、定时功能、排名系统等高级特性。

## ✨ 功能特性

### 🎯 核心功能
- 🎁 **灵活的抽奖创建** - 支持各种参数配置
- 👥 **用户参与系统** - 积分消耗与防重复参与
- 🎲 **多种开奖方式** - 手动开奖 + 定时自动开奖
- 🏆 **多奖品支持** - 支持多个获奖者和排名系统
- ⏰ **智能定时功能** - 精确的自动开奖和倒计时
- 📊 **完整状态管理** - 活跃、已完成、已取消状态

### 🎨 用户体验
- 🌍 **多语言支持** - 中英文界面
- 📱 **响应式设计** - 适配各种设备
- 🎨 **优雅界面** - 现代化设计风格
- ⚡ **实时更新** - 动态倒计时和状态显示

### 🔧 管理功能
- 🛠️ **管理员控制** - 完整的后台管理功能
- 📈 **数据统计** - 详细的抽奖数据记录
- 🔐 **权限管理** - 精细的操作权限控制
- 🚀 **API 接口** - 完整的管理 API

## 🚀 快速开始

### 基本用法
```
[lottery title="我的抽奖" prize="iPhone 15" cost="100" max="50"]
```

### 多奖品抽奖
```
[lottery title="三重大奖" prize="现金红包" count="3" cost="100"]
```

### 定时自动开奖
```
[lottery title="晚间抽奖" prize="MacBook" auto_draw="2024-12-25 20:00"]
```

### 限时多奖品抽奖
```
[lottery title="2小时限时十重奖" prize="礼品" count="10" auto_draw="2h"]
```

## 📚 完整文档

- **[🚀 快速入门指南](QUICK_START_GUIDE.md)** - 5分钟快速上手
- **[📖 完整使用指南](COMPLETE_LOTTERY_GUIDE.md)** - 详细功能说明
- **[🛠️ 部署指南](DEPLOYMENT_GUIDE.md)** - 安装和部署说明
- **[⏰ 定时开奖功能](AUTO_DRAW_GUIDE.md)** - 自动开奖详解
- **[🏆 多奖品功能](MULTIPLE_PRIZES_GUIDE.md)** - 多获奖者系统

## 🎯 支持的参数

| 参数 | 说明 | 示例 |
|------|------|------|
| `title` | 抽奖标题 | `title="新年抽奖"` |
| `prize` | 奖品名称 | `prize="iPhone 15"` |
| `cost` | 参与积分 | `cost="100"` |
| `max` | 最大人数 | `max="50"` |
| `count` | 奖品个数 | `count="3"` |
| `auto_draw` | 自动开奖 | `auto_draw="2h"` |

## 工作原理 (简要概述)

1.  **创建抽奖**: 用户在帖子中使用抽奖语法创建抽奖，支持多种参数配置
2.  **智能解析**: 插件自动解析抽奖参数，创建抽奖记录和互动界面
3.  **用户参与**: 用户点击参与按钮，系统处理积分扣除和参与记录
4.  **状态管理**: 实时更新参与人数、倒计时等状态信息
5.  **开奖处理**: 支持手动开奖和定时自动开奖，智能选择获奖者
6.  **结果展示**: 显示获奖者信息，支持单个或多个获奖者排名展示

### 🎲 开奖流程
- **手动开奖**: 管理员点击开奖按钮，立即随机选择获奖者
- **自动开奖**: 到达设定时间后，系统后台自动执行开奖
- **多奖品开奖**: 同时选择多个获奖者，按排名显示结果
- **状态更新**: 开奖后更新抽奖状态，记录获奖信息

## 安装步骤

1.  **访问您的 Discourse 服务器**: 通过 SSH 登录到您的 Discourse 服务器。
2.  **导航到插件目录**: `cd /var/discourse/plugins` (或您特定的 Discourse 插件路径)。
3.  **克隆仓库 (如果尚未克隆)**:
    ```bash
    git clone [https://github.com/truman1998/discourse-lottery.git](https://github.com/truman1998/discourse-lottery.git)
    ```
    如果您已经克隆了，请确保更新到最新版本。
4.  **重建您的 Discourse 应用**:
    ```bash
    cd /var/discourse
    ./launcher rebuild app
    ```
5.  **启用插件**: 在您的 Discourse 管理设置中，找到“抽奖”并确保“启用抽奖插件”已被勾选。

## 配置

- **站点设置**:
    - `lottery_enabled`: 在全站范围内启用或禁用抽奖插件。(位于 管理 -> 设置 -> 插件)

## 开发说明

- **模型 (Models)**:
    - `LotteryPlugin::Lottery`: 存储抽奖详情 (帖子, 奖品, 消耗, 最大参与人数)。
    - `LotteryPlugin::LotteryEntry`: 记录用户参与情况。
- **控制器 (Controller)**:
    - `LotteryPlugin::EntriesController`: 处理用户参与抽奖的请求。
- **前端 (Frontend)**:
    - `lottery.js.es6`: 管理抽奖框的互动元素。
    - `lottery.scss`: 为抽奖框提供样式。
- **本地化 (Localization)**:
    - `en.yml`, `zh_CN.yml` (服务器端) 和 `client.en.yml`, `client.zh_CN.yml` (客户端) 为 UI 元素提供翻译。

## 问题排查

- **"Oops" 页面**: 如果安装或更新后看到 "Oops" 页面，请检查服务器上的 `/var/discourse/shared/standalone/log/rails/production.log` (或通过 `./launcher enter app` 进入容器后查看 `log/production.log` 或 `log/unicorn.stderr.log`) 以获取详细的 Ruby 错误信息。常见原因包括：
    - 插件文件中的 Ruby 语法错误或 `NameError` (例如，类或模块名称不正确)。
    - 文件缺失或命名不正确 (特别是迁移文件、模型或本地化文件)。
    - 数据库迁移问题 (尽管您的日志显示迁移已运行)。
    - `parser.rb` 逻辑中的问题。
- **按钮不出现/不工作**: 检查浏览器的开发者控制台是否有 JavaScript 错误。确保插件的 JavaScript 和 CSS 资源已正确加载。

## 贡献

欢迎提交贡献、报告问题和提出功能请求！请随时查看 [issues 页面](https://github.com/truman1998/discourse-lottery/issues)。

## 许可证

该插件根据 [MIT 许可证](https://opensource.org/licenses/MIT) 的条款作为开源软件提供。
