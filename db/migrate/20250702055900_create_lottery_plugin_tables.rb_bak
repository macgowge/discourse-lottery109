# frozen_string_literal: true

class CreateLotteryPluginTables < ActiveRecord::Migration[6.1]
  def change
    create_table :lottery_plugin_lotteries do |t|
      t.integer :post_id, null: false
      t.integer :topic_id, null: false
      t.string  :title, null: false
      t.string  :prize_name, null: false
      t.integer :points_cost, default: 0
      t.integer :max_entries
      t.integer :prize_count, null: false, default: 1
      t.string  :status, null: false, default: "active"
      t.boolean :auto_draw_enabled, default: false
      t.datetime :auto_draw_at
      t.datetime :drawn_at
      t.datetime :end_time
      t.integer :winner_user_id
      t.timestamps
    end

    add_index :lottery_plugin_lotteries, :post_id, unique: true
    add_index :lottery_plugin_lotteries, :topic_id

    create_table :lottery_plugin_lottery_entries do |t|
      t.integer :lottery_id, null: false
      t.integer :user_id, null: false
      t.datetime :joined_at, default: -> { 'CURRENT_TIMESTAMP' }
      t.timestamps
    end

    add_index :lottery_plugin_lottery_entries, [:lottery_id, :user_id], unique: true

    create_table :lottery_plugin_lottery_winners do |t|
      t.integer :lottery_id, null: false
      t.integer :user_id, null: false
      t.integer :rank, null: false
      t.datetime :won_at, default: -> { 'CURRENT_TIMESTAMP' }
      t.timestamps
    end

    add_index :lottery_plugin_lottery_winners, [:lottery_id, :rank], unique: true
    add_index :lottery_plugin_lottery_winners, [:lottery_id, :user_id], unique: true
  end
end
