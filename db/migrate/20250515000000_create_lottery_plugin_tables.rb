# frozen_string_literal: true

class CreateLotteryPluginTables < ActiveRecord::Migration[6.1]
  def up
    # 安全地创建抽奖表
    unless table_exists?(:lottery_plugin_lotteries)
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
    end

    # 安全地创建参与记录表
    unless table_exists?(:lottery_plugin_entries)
      create_table :lottery_plugin_entries do |t|
        t.integer :user_id, null: false
        t.integer :lottery_id, null: false

        t.timestamps null: false
      end
    end

    # 安全地创建获奖者表
    unless table_exists?(:lottery_plugin_winners)
      create_table :lottery_plugin_winners do |t|
        t.integer :lottery_id, null: false
        t.integer :user_id, null: false
        t.integer :rank, null: false
        t.datetime :won_at, null: false

        t.timestamps null: false
      end
    end

    # 安全地添加索引
    add_index_safely(:lottery_plugin_lotteries, :post_id, unique: true, name: 'idx_lottery_post_id')
    add_index_safely(:lottery_plugin_lotteries, :topic_id, name: 'idx_lottery_topic_id')
    add_index_safely(:lottery_plugin_lotteries, :status, name: 'idx_lottery_status')
    add_index_safely(:lottery_plugin_lotteries, :winner_user_id, name: 'idx_lottery_winner_id')
    add_index_safely(:lottery_plugin_lotteries, :end_time, name: 'idx_lottery_end_time')
    add_index_safely(:lottery_plugin_lotteries, :auto_draw_at, name: 'idx_lottery_auto_draw_at')
    add_index_safely(:lottery_plugin_lotteries, [:auto_draw_enabled, :auto_draw_at], name: 'idx_lottery_auto_draw')
    add_index_safely(:lottery_plugin_lotteries, :prize_count, name: 'idx_lottery_prize_count')

    add_index_safely(:lottery_plugin_entries, [:user_id, :lottery_id], unique: true, name: 'idx_entry_user_lottery')
    add_index_safely(:lottery_plugin_entries, :lottery_id, name: 'idx_entry_lottery_id')

    add_index_safely(:lottery_plugin_winners, :lottery_id, name: 'idx_winner_lottery_id')
    add_index_safely(:lottery_plugin_winners, :user_id, name: 'idx_winner_user_id')
    add_index_safely(:lottery_plugin_winners, [:lottery_id, :rank], unique: true, name: 'idx_winner_lottery_rank')
  end

  def down
    drop_table :lottery_plugin_winners if table_exists?(:lottery_plugin_winners)
    drop_table :lottery_plugin_entries if table_exists?(:lottery_plugin_entries)
    drop_table :lottery_plugin_lotteries if table_exists?(:lottery_plugin_lotteries)
  end

  private

  def add_index_safely(table, columns, options = {})
    index_name = options[:name]
    return if index_name && index_exists?(table, columns, options)

    add_index(table, columns, options)
  rescue => e
    puts "LotteryPlugin: Warning - Failed to add index #{index_name}: #{e.message}"
  end
end
