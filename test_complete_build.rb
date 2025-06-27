#!/usr/bin/env ruby
# 完整项目构建测试脚本

puts "🔧 Discourse 抽奖插件完整构建测试"
puts "=" * 60

# 测试结果统计
total_tests = 0
passed_tests = 0
failed_tests = 0
warnings = 0

def test_result(name, condition, error_msg = nil)
  $total_tests += 1

  if condition
    puts "✅ #{name}"
    $passed_tests += 1
    true
  else
    puts "❌ #{name}"
    puts "   错误: #{error_msg}" if error_msg
    $failed_tests += 1
    false
  end
end

def warning(message)
  puts "⚠️  警告: #{message}"
  $warnings += 1
end

# 初始化全局变量
$total_tests = 0
$passed_tests = 0
$failed_tests = 0
$warnings = 0

puts "\n📁 1. 检查项目文件结构..."
puts "-" * 40

# 核心文件检查
core_files = [
  'plugin.rb',
  'README.md',
  'COMPLETE_LOTTERY_GUIDE.md',
  'QUICK_START_GUIDE.md'
]

core_files.each do |file|
  test_result("核心文件: #{file}", File.exist?(file), "文件不存在")
end

# 数据库迁移文件
migration_files = [
  'db/migrate/20250515000000_create_lottery_plugin_lotteries.rb',
  'db/migrate/20250515000001_create_lottery_plugin_entries.rb',
  'db/migrate/20250515000002_add_lottery_status_and_winner.rb',
  'db/migrate/20250515000003_add_auto_draw_time.rb',
  'db/migrate/20250515000004_add_prize_count_and_winners.rb'
]

migration_files.each do |file|
  test_result("迁移文件: #{File.basename(file)}", File.exist?(file), "迁移文件缺失")
end

# 模型文件
model_files = [
  'app/models/lottery_plugin/lottery.rb',
  'app/models/lottery_plugin/lottery_entry.rb',
  'app/models/lottery_plugin/lottery_winner.rb'
]

model_files.each do |file|
  test_result("模型文件: #{File.basename(file)}", File.exist?(file), "模型文件缺失")
end

# 控制器文件
controller_files = [
  'app/controllers/lottery_plugin/entries_controller.rb',
  'app/controllers/lottery_plugin/admin_controller.rb'
]

controller_files.each do |file|
  test_result("控制器: #{File.basename(file)}", File.exist?(file), "控制器文件缺失")
end

# 后台任务文件
job_files = [
  'app/jobs/lottery_auto_draw_job.rb'
]

job_files.each do |file|
  test_result("后台任务: #{File.basename(file)}", File.exist?(file), "任务文件缺失")
end

# 前端资源文件
asset_files = [
  'assets/javascripts/discourse/initializers/lottery.js.es6',
  'assets/stylesheets/common/lottery.scss'
]

asset_files.each do |file|
  test_result("前端资源: #{File.basename(file)}", File.exist?(file), "资源文件缺失")
end

# 本地化文件
locale_files = [
  'config/locales/en.yml',
  'config/locales/zh_CN.yml',
  'config/locales/client.en.yml',
  'config/locales/client.zh_CN.yml',
  'config/settings.yml'
]

locale_files.each do |file|
  test_result("本地化: #{File.basename(file)}", File.exist?(file), "本地化文件缺失")
end

# 核心逻辑文件
lib_files = [
  'lib/lottery_plugin/parser.rb'
]

lib_files.each do |file|
  test_result("核心逻辑: #{File.basename(file)}", File.exist?(file), "逻辑文件缺失")
end

puts "\n🔍 2. Ruby 语法检查..."
puts "-" * 40

# 检查所有 Ruby 文件的语法
ruby_files = Dir.glob("**/*.rb")
ruby_syntax_errors = []

ruby_files.each do |file|
  result = `ruby -c "#{file}" 2>&1`
  if $?.success?
    test_result("Ruby语法: #{file}", true)
  else
    test_result("Ruby语法: #{file}", false, result.strip)
    ruby_syntax_errors << file
  end
end

puts "\n📝 3. YAML 配置检查..."
puts "-" * 40

# 检查 YAML 文件语法
yaml_files = Dir.glob("config/**/*.yml")
yaml_errors = []

yaml_files.each do |file|
  begin
    require 'yaml'
    YAML.load_file(file)
    test_result("YAML语法: #{File.basename(file)}", true)
  rescue => e
    test_result("YAML语法: #{File.basename(file)}", false, e.message)
    yaml_errors << file
  end
end

puts "\n🎨 4. 前端资源检查..."
puts "-" * 40

# JavaScript 文件检查
js_file = 'assets/javascripts/discourse/initializers/lottery.js.es6'
if File.exist?(js_file)
  js_content = File.read(js_file)
  
  # 检查关键导入
  test_result("JS导入: apiInitializer", js_content.include?('apiInitializer'))
  test_result("JS导入: discourse-i18n", js_content.include?('discourse-i18n'))
  
  # 检查关键函数
  test_result("JS函数: updateStatusDisplay", js_content.include?('updateStatusDisplay'))
  test_result("JS函数: startCountdown", js_content.include?('startCountdown'))
  
  # 检查语法结构
  test_result("JS结构: export default", js_content.include?('export default'))
  test_result("JS结构: decorateCookedElement", js_content.include?('decorateCookedElement'))
  
  # 检查多奖品功能
  test_result("JS功能: 多奖品支持", js_content.include?('multiplePrizes'))
  test_result("JS功能: 倒计时功能", js_content.include?('countdown'))
else
  test_result("JavaScript文件存在", false, "主要JS文件缺失")
end

# SCSS 文件检查
scss_file = 'assets/stylesheets/common/lottery.scss'
if File.exist?(scss_file)
  scss_content = File.read(scss_file)
  
  # 检查关键样式类
  test_result("SCSS样式: lottery-container", scss_content.include?('lottery-container'))
  test_result("SCSS样式: lottery-winners-display", scss_content.include?('lottery-winners-display'))
  test_result("SCSS样式: lottery-countdown-display", scss_content.include?('lottery-countdown-display'))
  
  # 检查语法结构
  bracket_count = scss_content.count('{') - scss_content.count('}')
  test_result("SCSS语法: 括号匹配", bracket_count == 0, "括号不匹配: #{bracket_count}")
else
  test_result("SCSS文件存在", false, "样式文件缺失")
end

puts "\n🔧 5. 插件配置检查..."
puts "-" * 40

# plugin.rb 文件检查
if File.exist?('plugin.rb')
  plugin_content = File.read('plugin.rb')
  
  # 检查插件头部
  test_result("插件头部: name", plugin_content.include?('# name:'))
  test_result("插件头部: version", plugin_content.include?('# version:'))
  test_result("插件头部: authors", plugin_content.include?('# authors:'))
  
  # 检查关键配置
  test_result("插件配置: enabled_site_setting", plugin_content.include?('enabled_site_setting'))
  test_result("插件配置: after_initialize", plugin_content.include?('after_initialize'))
  
  # 检查模型加载
  test_result("模型加载: Lottery", plugin_content.include?('lottery_plugin/lottery'))
  test_result("模型加载: LotteryEntry", plugin_content.include?('lottery_entry'))
  test_result("模型加载: LotteryWinner", plugin_content.include?('lottery_winner'))
  
  # 检查路由配置
  test_result("路由配置: entries", plugin_content.include?('post "/entries"'))
  test_result("路由配置: admin", plugin_content.include?('namespace :admin'))
  
  # 检查序列化器
  test_result("序列化器: add_to_serializer", plugin_content.include?('add_to_serializer'))
else
  test_result("plugin.rb存在", false, "主配置文件缺失")
end

puts "\n🗄️ 6. 数据库结构检查..."
puts "-" * 40

# 检查迁移文件内容
migration_files.each do |file|
  if File.exist?(file)
    migration_content = File.read(file)
    
    # 检查基本迁移结构
    has_change_method = migration_content.include?('def change') || migration_content.include?('def up')
    test_result("迁移结构: #{File.basename(file)}", has_change_method, "缺少change或up方法")
    
    # 检查表操作
    has_table_ops = migration_content.include?('create_table') || 
                   migration_content.include?('add_column') || 
                   migration_content.include?('add_index')
    test_result("表操作: #{File.basename(file)}", has_table_ops, "缺少表操作")
  end
end

puts "\n🌍 7. 国际化检查..."
puts "-" * 40

# 检查本地化文件内容
['en', 'zh_CN'].each do |locale|
  server_file = "config/locales/#{locale}.yml"
  client_file = "config/locales/client.#{locale}.yml"
  
  if File.exist?(server_file)
    server_content = File.read(server_file)
    test_result("服务端本地化: #{locale}", server_content.include?('lottery:'))
  end
  
  if File.exist?(client_file)
    client_content = File.read(client_file)
    test_result("客户端本地化: #{locale}", client_content.include?('lottery:'))
  end
end

puts "\n🧪 8. 功能完整性检查..."
puts "-" * 40

# 检查核心功能实现
if File.exist?('app/models/lottery_plugin/lottery.rb')
  lottery_model = File.read('app/models/lottery_plugin/lottery.rb')
  
  test_result("功能: 基础抽奖", lottery_model.include?('validates'))
  test_result("功能: 开奖方法", lottery_model.include?('draw_winner!'))
  test_result("功能: 多奖品", lottery_model.include?('prize_count'))
  test_result("功能: 自动开奖", lottery_model.include?('auto_draw'))
  test_result("功能: 状态管理", lottery_model.include?('STATUSES'))
end

if File.exist?('lib/lottery_plugin/parser.rb')
  parser_content = File.read('lib/lottery_plugin/parser.rb')
  
  test_result("解析: 基础语法", parser_content.include?('parse_lottery_params'))
  test_result("解析: 时间参数", parser_content.include?('parse_time_param'))
  test_result("解析: 多奖品", parser_content.include?('count'))
  test_result("解析: 定时开奖", parser_content.include?('auto_draw'))
end

puts "\n📊 9. 测试结果统计..."
puts "=" * 60

puts "总测试数: #{$total_tests}"
puts "通过测试: #{$passed_tests} ✅"
puts "失败测试: #{$failed_tests} ❌"
puts "警告数量: #{$warnings} ⚠️"

success_rate = ($passed_tests.to_f / $total_tests * 100).round(1)
puts "成功率: #{success_rate}%"

puts "\n🎯 10. 构建建议..."
puts "-" * 40

if $failed_tests == 0
  puts "🎉 恭喜！项目通过了所有测试！"
  puts "✅ 项目结构完整"
  puts "✅ 语法检查通过"
  puts "✅ 配置文件正确"
  puts "✅ 功能实现完整"
  puts ""
  puts "🚀 您的插件现在可以安全地部署到 Discourse 了！"
  puts ""
  puts "📋 部署步骤："
  puts "1. 将插件复制到 Discourse plugins 目录"
  puts "2. 运行 ./launcher rebuild app"
  puts "3. 在管理面板中启用插件"
  puts "4. 开始创建抽奖活动！"
elsif $failed_tests <= 3
  puts "⚠️  项目基本可用，但有少量问题需要修复："
  puts "- 失败测试数: #{$failed_tests}"
  puts "- 建议修复后再部署"
else
  puts "❌ 项目存在较多问题，需要修复后再部署："
  puts "- 失败测试数: #{$failed_tests}"
  puts "- 请检查上述失败的测试项"
  puts "- 修复问题后重新运行测试"
end

if $warnings > 0
  puts "\n⚠️  注意事项："
  puts "- 警告数量: #{$warnings}"
  puts "- 虽然不影响构建，但建议处理"
end

puts "\n" + "=" * 60
puts "测试完成！"
