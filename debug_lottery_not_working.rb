#!/usr/bin/env ruby
# 调试抽奖不工作的问题

puts "🔍 调试抽奖不工作问题"
puts "=" * 50

# 1. 检查插件文件完整性
puts "\n📁 1. 检查插件文件完整性..."
required_files = {
  'plugin.rb' => '主配置文件',
  'assets/javascripts/discourse/initializers/lottery.js.es6' => 'JavaScript初始化器',
  'assets/stylesheets/common/lottery.scss' => '样式文件',
  'lib/lottery_plugin/parser.rb' => '解析器',
  'config/settings.yml' => '站点设置',
  'config/locales/client.zh_CN.yml' => '中文本地化',
  'config/locales/client.en.yml' => '英文本地化',
  'app/models/lottery_plugin/lottery.rb' => '抽奖模型',
  'db/migrate/20250515000000_create_lottery_plugin_tables.rb' => '数据库迁移'
}

missing_files = []
required_files.each do |file, desc|
  if File.exist?(file)
    puts "✅ #{desc}: #{file}"
  else
    puts "❌ #{desc}: #{file} - 缺失"
    missing_files << file
  end
end

# 2. 检查 plugin.rb 配置
puts "\n🔧 2. 检查 plugin.rb 配置..."
if File.exist?('plugin.rb')
  plugin_content = File.read('plugin.rb')
  
  # 检查关键配置
  configs = [
    ['enabled_site_setting :lottery_enabled', '站点设置启用'],
    ['register_asset.*lottery.scss', '样式文件注册'],
    ['register_asset.*lottery.js.es6', 'JavaScript文件注册'],
    ['after_initialize', '初始化块'],
    ['DiscourseEvent.on.*post_process_cooked', '帖子处理事件'],
    ['LotteryPlugin::Parser.parse', '解析器调用'],
    ['add_to_serializer.*lottery_data', '序列化器配置']
  ]
  
  configs.each do |pattern, desc|
    if plugin_content.match(/#{pattern}/)
      puts "✅ #{desc}"
    else
      puts "❌ #{desc} - 缺失或配置错误"
    end
  end
else
  puts "❌ plugin.rb 文件不存在"
end

# 3. 检查解析器逻辑
puts "\n📝 3. 检查解析器逻辑..."
if File.exist?('lib/lottery_plugin/parser.rb')
  parser_content = File.read('lib/lottery_plugin/parser.rb')
  
  # 检查解析器功能
  parser_checks = [
    ['在此创建抽奖', '简单触发文本'],
    ['lottery.*title.*prize', '自定义参数解析'],
    ['parse_lottery_params', '参数解析函数'],
    ['LotteryPlugin::Lottery.create', '抽奖创建逻辑']
  ]
  
  parser_checks.each do |pattern, desc|
    if parser_content.match(/#{pattern}/)
      puts "✅ #{desc}"
    else
      puts "❌ #{desc} - 可能缺失"
    end
  end
else
  puts "❌ 解析器文件不存在"
end

# 4. 检查 JavaScript 初始化器
puts "\n🎨 4. 检查 JavaScript 初始化器..."
if File.exist?('assets/javascripts/discourse/initializers/lottery.js.es6')
  js_content = File.read('assets/javascripts/discourse/initializers/lottery.js.es6')
  
  # 检查 JavaScript 功能
  js_checks = [
    ['apiInitializer', 'API初始化器'],
    ['decorateCookedElement', '元素装饰器'],
    ['lottery_data', '数据获取'],
    ['lottery-box', '抽奖容器创建'],
    ['join-lottery-btn', '参与按钮']
  ]
  
  js_checks.each do |pattern, desc|
    if js_content.include?(pattern)
      puts "✅ #{desc}"
    else
      puts "❌ #{desc} - 可能缺失"
    end
  end
else
  puts "❌ JavaScript 初始化器文件不存在"
end

# 5. 检查本地化文件
puts "\n🌍 5. 检查本地化文件..."
locale_files = ['config/locales/client.zh_CN.yml', 'config/locales/client.en.yml']

locale_files.each do |file|
  if File.exist?(file)
    content = File.read(file)
    if content.include?('lottery:')
      puts "✅ #{file} - 包含抽奖本地化"
    else
      puts "❌ #{file} - 缺少抽奖本地化"
    end
  else
    puts "❌ #{file} - 文件不存在"
  end
end

# 6. 生成调试建议
puts "\n" + "=" * 50
puts "🛠️ 调试建议和解决方案"
puts "=" * 50

if missing_files.empty?
  puts "\n✅ 所有必要文件都存在"
else
  puts "\n❌ 缺失文件:"
  missing_files.each { |file| puts "   - #{file}" }
end

puts "\n📋 请按以下步骤调试:"

puts "\n1️⃣ 检查插件是否启用:"
puts "   - 访问管理面板 → 插件"
puts "   - 查找 'discourse-lottery' 或 '抽奖插件'"
puts "   - 确保状态为 '已启用'"

puts "\n2️⃣ 检查站点设置:"
puts "   - 管理面板 → 设置 → 搜索 'lottery'"
puts "   - 确保 'lottery_enabled' 为 true"

puts "\n3️⃣ 检查帖子位置:"
puts "   - 必须在主题的第一个帖子中"
puts "   - 不能在回复中创建"

puts "\n4️⃣ 检查语法:"
puts "   - 使用: [lottery title=\"我的抽奖\" prize=\"iPhone 15\" cost=\"100\" max=\"50\"]"
puts "   - 或简单: [在此创建抽奖]"

puts "\n5️⃣ 检查浏览器控制台:"
puts "   - 按 F12 打开开发者工具"
puts "   - 查看 Console 标签是否有错误"

puts "\n6️⃣ 检查服务器日志:"
puts "   - ./launcher logs app | grep -i lottery"

puts "\n🔧 常见解决方案:"
puts "   - 重启 Discourse: ./launcher restart app"
puts "   - 清除浏览器缓存"
puts "   - 强制刷新页面 (Ctrl+F5)"
puts "   - 检查用户权限"

puts "\n📞 如果问题仍然存在，请提供:"
puts "   - 浏览器控制台错误信息"
puts "   - 服务器日志相关内容"
puts "   - 插件启用状态截图"
puts "   - 站点设置截图"

puts "\n" + "=" * 50
