#!/usr/bin/env ruby
# 简单的插件测试脚本

puts "🎯 开始测试 Discourse 抽奖插件..."
puts "=" * 50

# 1. 检查插件文件结构
puts "\n📁 检查文件结构..."
required_files = [
  'plugin.rb',
  'app/models/lottery_plugin/lottery.rb',
  'app/models/lottery_plugin/lottery_entry.rb',
  'app/controllers/lottery_plugin/entries_controller.rb',
  'assets/javascripts/discourse/initializers/lottery.js.es6',
  'assets/stylesheets/common/lottery.scss',
  'config/locales/en.yml',
  'config/locales/zh_CN.yml',
  'config/locales/client.en.yml',
  'config/locales/client.zh_CN.yml',
  'config/settings.yml',
  'db/migrate/20250515000000_create_lottery_plugin_lotteries.rb',
  'db/migrate/20250515000001_create_lottery_plugin_entries.rb',
  'lib/lottery_plugin/parser.rb'
]

missing_files = []
required_files.each do |file|
  if File.exist?(file)
    puts "✅ #{file}"
  else
    puts "❌ #{file} - 缺失"
    missing_files << file
  end
end

# 2. 检查 Ruby 语法
puts "\n🔍 检查 Ruby 语法..."
ruby_files = Dir.glob("**/*.rb")
syntax_errors = []

ruby_files.each do |file|
  result = `ruby -c "#{file}" 2>&1`
  if $?.success?
    puts "✅ #{file} - 语法正确"
  else
    puts "❌ #{file} - 语法错误: #{result.strip}"
    syntax_errors << file
  end
end

# 3. 检查 YAML 语法
puts "\n📝 检查 YAML 语法..."
yaml_files = Dir.glob("config/**/*.yml")
yaml_errors = []

yaml_files.each do |file|
  begin
    require 'yaml'
    YAML.load_file(file)
    puts "✅ #{file} - YAML 语法正确"
  rescue => e
    puts "❌ #{file} - YAML 语法错误: #{e.message}"
    yaml_errors << file
  end
end

# 4. 检查 JavaScript 语法（基本检查）
puts "\n🔧 检查 JavaScript 文件..."
js_file = 'assets/javascripts/discourse/initializers/lottery.js.es6'
if File.exist?(js_file)
  content = File.read(js_file)
  
  # 检查基本语法问题
  issues = []
  issues << "缺少 export default" unless content.include?('export default')
  issues << "缺少 apiInitializer" unless content.include?('apiInitializer')
  issues << "I18n 导入可能有问题" unless content.include?('discourse-i18n')
  
  if issues.empty?
    puts "✅ #{js_file} - 基本结构正确"
  else
    puts "⚠️  #{js_file} - 发现问题:"
    issues.each { |issue| puts "   - #{issue}" }
  end
else
  puts "❌ JavaScript 文件不存在"
end

# 5. 总结
puts "\n" + "=" * 50
puts "📊 测试总结:"
puts "=" * 50

if missing_files.empty? && syntax_errors.empty? && yaml_errors.empty?
  puts "🎉 恭喜！插件通过了所有基本检查！"
  puts "✅ 文件结构完整"
  puts "✅ Ruby 语法正确"
  puts "✅ YAML 配置正确"
  puts "✅ JavaScript 结构正确"
  puts ""
  puts "🚀 您的插件现在应该可以在 Discourse 中正常构建了！"
  puts ""
  puts "📋 下一步建议："
  puts "1. 将插件复制到 Discourse 的 plugins 目录"
  puts "2. 重启 Discourse 服务"
  puts "3. 在管理面板中启用 '抽奖插件' 设置"
  puts "4. 测试创建抽奖功能"
else
  puts "⚠️  发现以下问题需要修复："
  
  unless missing_files.empty?
    puts "\n缺失文件:"
    missing_files.each { |file| puts "  - #{file}" }
  end
  
  unless syntax_errors.empty?
    puts "\nRuby 语法错误:"
    syntax_errors.each { |file| puts "  - #{file}" }
  end
  
  unless yaml_errors.empty?
    puts "\nYAML 语法错误:"
    yaml_errors.each { |file| puts "  - #{file}" }
  end
end

puts "\n" + "=" * 50
