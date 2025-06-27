#!/usr/bin/env ruby
# 清理抽奖插件迁移的脚本

puts "🧹 清理抽奖插件迁移数据..."
puts "=" * 50

# 生成清理 SQL
cleanup_sql = <<~SQL
-- 清理抽奖插件的数据库残留
-- 请在 Discourse 数据库中执行

-- 1. 删除可能存在的表（按依赖关系顺序）
DROP TABLE IF EXISTS lottery_plugin_winners CASCADE;
DROP TABLE IF EXISTS lottery_plugin_entries CASCADE;
DROP TABLE IF EXISTS lottery_plugin_lotteries CASCADE;

-- 2. 删除可能存在的索引（如果表已删除，索引会自动删除）
-- 这里列出是为了确保完全清理
DROP INDEX IF EXISTS idx_lottery_post_id;
DROP INDEX IF EXISTS idx_lottery_topic_id;
DROP INDEX IF EXISTS idx_lottery_status;
DROP INDEX IF EXISTS idx_lottery_winner_id;
DROP INDEX IF EXISTS idx_lottery_end_time;
DROP INDEX IF EXISTS idx_lottery_auto_draw_at;
DROP INDEX IF EXISTS idx_lottery_auto_draw;
DROP INDEX IF EXISTS idx_lottery_prize_count;
DROP INDEX IF EXISTS idx_entry_user_lottery;
DROP INDEX IF EXISTS idx_entry_lottery_id;
DROP INDEX IF EXISTS idx_winner_lottery_id;
DROP INDEX IF EXISTS idx_winner_user_id;
DROP INDEX IF EXISTS idx_winner_lottery_rank;

-- 3. 清理迁移记录
DELETE FROM schema_migrations WHERE version = '20250515000000';

-- 4. 验证清理结果
SELECT 'Tables:' as type, table_name as name
FROM information_schema.tables 
WHERE table_name LIKE 'lottery_plugin_%'
UNION ALL
SELECT 'Indexes:' as type, indexname as name
FROM pg_indexes 
WHERE indexname LIKE 'idx_lottery_%' OR indexname LIKE 'idx_entry_%' OR indexname LIKE 'idx_winner_%'
UNION ALL
SELECT 'Migrations:' as type, version as name
FROM schema_migrations 
WHERE version = '20250515000000';

-- 如果上面的查询返回空结果，说明清理成功
SQL

# 保存清理 SQL 到文件
File.write('cleanup_lottery.sql', cleanup_sql)
puts "✅ 清理 SQL 已保存到 cleanup_lottery.sql"

puts "\n📋 清理步骤："
puts "1. 进入 Discourse 容器："
puts "   ./launcher enter app"
puts ""
puts "2. 进入数据库："
puts "   cd /var/www/discourse"
puts "   bundle exec rails dbconsole"
puts ""
puts "3. 执行清理 SQL："
puts "   复制 cleanup_lottery.sql 的内容并粘贴执行"
puts ""
puts "4. 退出数据库："
puts "   \\q"
puts ""
puts "5. 重新运行迁移："
puts "   bundle exec rake db:migrate"

# 生成简化的迁移文件
simple_migration = <<~RUBY
class CreateLotteryPluginTablesSimple < ActiveRecord::Migration
  def change
    # 最简单的迁移，只创建基础表结构
    
    create_table :lottery_plugin_lotteries do |t|
      t.integer :topic_id, null: false
      t.integer :post_id, null: false
      t.string  :title, null: false
      t.string  :prize_name, null: false
      t.integer :points_cost, default: 0, null: false
      t.integer :max_entries
      t.string  :status, default: 'active', null: false
      t.integer :winner_user_id
      t.datetime :drawn_at
      t.datetime :end_time
      t.datetime :auto_draw_at
      t.boolean :auto_draw_enabled, default: false, null: false
      t.integer :prize_count, default: 1, null: false
      t.timestamps null: false
    end

    create_table :lottery_plugin_entries do |t|
      t.integer :user_id, null: false
      t.integer :lottery_id, null: false
      t.timestamps null: false
    end

    create_table :lottery_plugin_winners do |t|
      t.integer :lottery_id, null: false
      t.integer :user_id, null: false
      t.integer :rank, null: false
      t.datetime :won_at, null: false
      t.timestamps null: false
    end

    # 只添加最重要的索引
    add_index :lottery_plugin_lotteries, :post_id, unique: true
    add_index :lottery_plugin_entries, [:user_id, :lottery_id], unique: true
    add_index :lottery_plugin_winners, :lottery_id
  end
end
RUBY

# 保存简化迁移文件
File.write('db/migrate/20250515000001_create_lottery_plugin_tables_simple.rb', simple_migration)
puts "✅ 简化迁移文件已创建: 20250515000001_create_lottery_plugin_tables_simple.rb"

puts "\n🔧 备用方案："
puts "如果复杂迁移仍然失败，可以："
puts "1. 删除当前迁移文件"
puts "2. 使用简化迁移文件"
puts "3. 后续手动添加其他索引"

puts "\n⚠️  注意事项："
puts "- 执行前请备份数据库"
puts "- 确保没有其他用户在使用系统"
puts "- 如果有重要数据，请谨慎操作"

puts "\n" + "=" * 50
puts "清理脚本生成完成！"
