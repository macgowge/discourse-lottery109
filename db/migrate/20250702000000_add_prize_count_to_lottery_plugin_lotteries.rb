# frozen_string_literal: true

class AddPrizeCountToLotteryPluginLotteries < ActiveRecord::Migration[6.1]
  def change
    unless column_exists?(:lottery_plugin_lotteries, :prize_count)
      add_column :lottery_plugin_lotteries, :prize_count, :integer, default: 1, null: false
    end

    unless index_exists?(:lottery_plugin_lotteries, :prize_count, name: 'idx_lottery_prize_count')
      add_index :lottery_plugin_lotteries, :prize_count, name: 'idx_lottery_prize_count'
    end
  end
end
