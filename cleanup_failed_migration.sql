-- 清理失败的迁移（如果需要）
-- 在 Discourse 数据库中执行

-- 1. 删除可能已创建的表（按依赖关系顺序）
DROP TABLE IF EXISTS lottery_plugin_winners CASCADE;
DROP TABLE IF EXISTS lottery_plugin_entries CASCADE;
DROP TABLE IF EXISTS lottery_plugin_lotteries CASCADE;

-- 2. 删除可能已创建的索引（如果表被删除，索引会自动删除）
-- 这里列出是为了参考
/*
DROP INDEX IF EXISTS index_lottery_plugin_lotteries_on_auto_draw_enabled_and_auto_draw_at;
DROP INDEX IF EXISTS index_lottery_plugin_lotteries_on_post_id;
DROP INDEX IF EXISTS index_lottery_plugin_entries_on_user_id_and_lottery_id;
DROP INDEX IF EXISTS index_lottery_plugin_winners_on_lottery_id_and_rank;
*/

-- 3. 清理迁移记录（如果需要重新运行迁移）
DELETE FROM schema_migrations WHERE version = '20250515000000';

-- 4. 验证清理结果
SELECT table_name 
FROM information_schema.tables 
WHERE table_name LIKE 'lottery_plugin_%';

-- 应该返回空结果，表示所有相关表都已删除
