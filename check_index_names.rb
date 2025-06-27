#!/usr/bin/env ruby
# 检查索引名称长度

puts "🔍 检查索引名称长度..."
puts "=" * 50

# PostgreSQL 索引名称长度限制
MAX_INDEX_NAME_LENGTH = 63

# 从迁移文件中提取索引名称
migration_file = 'db/migrate/20250515000000_create_lottery_plugin_tables.rb'

if File.exist?(migration_file)
  content = File.read(migration_file)
  
  # 提取所有 add_index 行
  index_lines = content.scan(/add_index.*?name: ['"]([^'"]+)['"]/)
  
  puts "📋 检查的索引名称:"
  puts "-" * 30
  
  all_valid = true
  
  index_lines.each do |match|
    index_name = match[0]
    length = index_name.length
    
    if length <= MAX_INDEX_NAME_LENGTH
      puts "✅ #{index_name} (#{length} 字符)"
    else
      puts "❌ #{index_name} (#{length} 字符) - 超过限制!"
      all_valid = false
    end
  end
  
  puts "\n" + "=" * 50
  
  if all_valid
    puts "🎉 所有索引名称长度都符合要求！"
    puts "✅ 最大长度限制: #{MAX_INDEX_NAME_LENGTH} 字符"
    puts "✅ 所有索引名称都在限制范围内"
  else
    puts "❌ 发现超长的索引名称，需要修复"
  end
  
  # 检查迁移文件语法
  puts "\n🔧 检查迁移文件语法..."
  result = `ruby -c "#{migration_file}" 2>&1`
  if $?.success?
    puts "✅ 迁移文件语法正确"
  else
    puts "❌ 迁移文件语法错误:"
    puts result
  end
  
else
  puts "❌ 迁移文件不存在: #{migration_file}"
end

puts "\n📋 索引名称设计原则:"
puts "- 使用简短但有意义的前缀 (如 idx_)"
puts "- 包含表名的简化版本"
puts "- 包含字段名的简化版本"
puts "- 总长度不超过 63 字符"

puts "\n🚀 修复后可以安全部署！"
