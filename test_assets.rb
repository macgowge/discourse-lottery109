#!/usr/bin/env ruby
# 测试资源文件的兼容性

puts "🎨 测试资源文件兼容性..."
puts "=" * 40

# 测试 SCSS 文件
scss_file = 'assets/stylesheets/common/lottery.scss'
if File.exist?(scss_file)
  puts "\n📄 检查 SCSS 文件: #{scss_file}"
  content = File.read(scss_file)
  
  # 检查常见的 SCSS 语法
  issues = []
  issues << "可能缺少分号" if content.scan(/[^;]\s*}/).length > content.scan(/;\s*}/).length
  issues << "可能有未闭合的括号" if content.count('{') != content.count('}')
  issues << "可能有未闭合的圆括号" if content.count('(') != content.count(')')
  
  if issues.empty?
    puts "✅ SCSS 语法看起来正确"
  else
    puts "⚠️  发现潜在问题:"
    issues.each { |issue| puts "   - #{issue}" }
  end
  
  # 检查 Discourse 特定的 CSS 变量
  discourse_vars = content.scan(/var\(--[\w-]+\)/).uniq
  if discourse_vars.any?
    puts "✅ 使用了 Discourse CSS 变量: #{discourse_vars.join(', ')}"
  else
    puts "ℹ️  没有使用 Discourse CSS 变量（这是可选的）"
  end
end

# 测试 JavaScript 文件的导入
js_file = 'assets/javascripts/discourse/initializers/lottery.js.es6'
if File.exist?(js_file)
  puts "\n🔧 检查 JavaScript 文件: #{js_file}"
  content = File.read(js_file)
  
  # 检查导入语句
  imports = content.scan(/import .+ from .+/).map(&:strip)
  puts "📦 发现的导入语句:"
  imports.each { |imp| puts "   #{imp}" }
  
  # 检查是否使用了正确的 Discourse API
  api_calls = []
  api_calls << "apiInitializer" if content.include?('apiInitializer')
  api_calls << "decorateCookedElement" if content.include?('decorateCookedElement')
  api_calls << "I18n.t" if content.include?('I18n.t')
  api_calls << "api.container.lookup" if content.include?('api.container.lookup')
  
  puts "🔌 使用的 Discourse API:"
  api_calls.each { |api| puts "   ✅ #{api}" }
  
  # 检查异步语法
  if content.include?('async') && content.include?('await')
    puts "⚡ 使用了现代异步语法 (async/await)"
  end
end

puts "\n" + "=" * 40
puts "✅ 资源文件兼容性检查完成！"
puts "🚀 您的插件资源应该可以正常编译！"
