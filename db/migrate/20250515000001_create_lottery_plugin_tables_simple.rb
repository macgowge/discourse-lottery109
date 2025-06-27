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
