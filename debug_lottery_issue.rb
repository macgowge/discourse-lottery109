#!/usr/bin/env ruby
# 抽奖问题调试脚本

puts "🔍 Discourse 抽奖插件问题调试"
puts "=" * 50

# 检查插件文件
puts "\n📁 1. 检查插件文件..."
required_files = [
  'plugin.rb',
  'assets/javascripts/discourse/initializers/lottery.js.es6',
  'lib/lottery_plugin/parser.rb',
  'config/settings.yml'
]

required_files.each do |file|
  if File.exist?(file)
    puts "✅ #{file}"
  else
    puts "❌ #{file} - 缺失"
  end
end

# 检查 plugin.rb 配置
puts "\n🔧 2. 检查插件配置..."
if File.exist?('plugin.rb')
  plugin_content = File.read('plugin.rb')
  
  checks = [
    ['enabled_site_setting', '站点设置配置'],
    ['after_initialize', '初始化配置'],
    ['lottery_plugin/parser', '解析器加载'],
    ['add_to_serializer', '序列化器配置']
  ]
  
  checks.each do |check, desc|
    if plugin_content.include?(check)
      puts "✅ #{desc}"
    else
      puts "❌ #{desc} - 缺失"
    end
  end
end

# 检查解析器
puts "\n📝 3. 检查解析器..."
if File.exist?('lib/lottery_plugin/parser.rb')
  parser_content = File.read('lib/lottery_plugin/parser.rb')
  
  if parser_content.include?('[在此创建抽奖]')
    puts "✅ 简单触发文本支持"
  else
    puts "❌ 简单触发文本缺失"
  end
  
  if parser_content.include?('parse_lottery_params')
    puts "✅ 参数解析功能"
  else
    puts "❌ 参数解析功能缺失"
  end
end

# 检查前端初始化器
puts "\n🎨 4. 检查前端初始化器..."
if File.exist?('assets/javascripts/discourse/initializers/lottery.js.es6')
  js_content = File.read('assets/javascripts/discourse/initializers/lottery.js.es6')
  
  checks = [
    ['apiInitializer', 'API 初始化器'],
    ['decorateCookedElement', '元素装饰器'],
    ['lottery-box', '抽奖容器'],
    ['lottery_data', '数据序列化']
  ]
  
  checks.each do |check, desc|
    if js_content.include?(check)
      puts "✅ #{desc}"
    else
      puts "❌ #{desc} - 可能缺失"
    end
  end
end

# 检查站点设置
puts "\n⚙️ 5. 检查站点设置..."
if File.exist?('config/settings.yml')
  settings_content = File.read('config/settings.yml')
  
  if settings_content.include?('lottery_enabled')
    puts "✅ lottery_enabled 设置已定义"
  else
    puts "❌ lottery_enabled 设置缺失"
  end
end

puts "\n" + "=" * 50
puts "🛠️ 故障排除建议："
puts "=" * 50

puts "\n📋 如果抽奖没有显示，请检查："
puts "1. 插件是否在管理面板中启用"
puts "2. lottery_enabled 设置是否为 true"
puts "3. 是否在主题的第一个帖子中创建"
puts "4. 语法是否完全正确"
puts "5. 浏览器是否有 JavaScript 错误"

puts "\n🔧 调试步骤："
puts "1. 先尝试简单语法: [在此创建抽奖]"
puts "2. 检查浏览器控制台错误"
puts "3. 查看服务器日志"
puts "4. 确认插件文件完整"

puts "\n📞 如果问题仍然存在："
puts "1. 提供浏览器控制台错误信息"
puts "2. 提供服务器日志相关信息"
puts "3. 确认 Discourse 版本和插件版本"

puts "\n🎯 常见解决方案："
puts "- 重启 Discourse: ./launcher restart app"
puts "- 清除浏览器缓存"
puts "- 检查用户权限"
puts "- 确认积分系统正常"

puts "\n" + "=" * 50
