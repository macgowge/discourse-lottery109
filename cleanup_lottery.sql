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
