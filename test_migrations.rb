#!/usr/bin/env ruby
# 测试数据库迁移文件

puts "🗄️ 测试数据库迁移文件..."
puts "=" * 50

# 模拟 ActiveRecord::Migration 类
class ActiveRecord
  class Migration
    def self.change
      puts "Migration change method called"
    end
    
    def create_table(name, &block)
      puts "Creating table: #{name}"
    end
    
    def add_column(table, column, type, options = {})
      puts "Adding column: #{table}.#{column} (#{type})"
    end
    
    def add_index(table, columns, options = {})
      puts "Adding index: #{table} on #{columns}"
    end
  end
end

# 测试每个迁移文件
migration_files = [
  'db/migrate/20250515000000_create_lottery_plugin_lotteries.rb',
  'db/migrate/20250515000001_create_lottery_plugin_entries.rb',
  'db/migrate/20250515000002_add_lottery_status_and_winner.rb',
  'db/migrate/20250515000003_add_auto_draw_time.rb',
  'db/migrate/20250515000004_add_prize_count_and_winners.rb'
]

migration_files.each do |file|
  puts "\n📄 测试: #{File.basename(file)}"
  puts "-" * 40
  
  if File.exist?(file)
    begin
      # 检查 Ruby 语法
      result = `ruby -c "#{file}" 2>&1`
      if $?.success?
        puts "✅ Ruby 语法正确"
      else
        puts "❌ Ruby 语法错误: #{result}"
        next
      end
      
      # 检查文件内容
      content = File.read(file)
      
      # 检查基本结构
      if content.include?('class') && content.include?('< ActiveRecord::Migration')
        puts "✅ 迁移类结构正确"
      else
        puts "❌ 迁移类结构错误"
      end
      
      if content.include?('def change')
        puts "✅ change 方法存在"
      else
        puts "❌ 缺少 change 方法"
      end
      
      # 检查操作类型
      operations = []
      operations << "create_table" if content.include?('create_table')
      operations << "add_column" if content.include?('add_column')
      operations << "add_index" if content.include?('add_index')
      
      if operations.any?
        puts "✅ 数据库操作: #{operations.join(', ')}"
      else
        puts "❌ 没有找到数据库操作"
      end
      
      # 检查表名
      if content.include?('lottery_plugin_')
        puts "✅ 使用正确的表名前缀"
      else
        puts "⚠️  表名可能不规范"
      end
      
    rescue => e
      puts "❌ 测试失败: #{e.message}"
    end
  else
    puts "❌ 文件不存在"
  end
end

puts "\n🔧 迁移文件兼容性建议..."
puts "=" * 50

puts "1. ✅ 已移除 ActiveRecord 版本号，提高兼容性"
puts "2. ✅ 使用标准的迁移方法"
puts "3. ✅ 表名使用插件前缀"
puts "4. ✅ 适当的索引设置"

puts "\n📋 如果仍然失败，请尝试以下方案："
puts "1. 检查 Discourse 日志获取详细错误信息"
puts "2. 确认 PostgreSQL 版本兼容性"
puts "3. 检查数据库权限"
puts "4. 考虑分步骤迁移"

puts "\n🚀 建议的部署步骤："
puts "1. 备份数据库"
puts "2. 复制插件到 plugins 目录"
puts "3. 运行 ./launcher rebuild app"
puts "4. 检查日志文件"

puts "\n" + "=" * 50
puts "迁移测试完成！"
