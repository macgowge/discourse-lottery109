# frozen_string_literal: true

class AddRankToLotteryPluginWinners < ActiveRecord::Migration[7.0]
  def change
    add_column :lottery_plugin_winners, :rank, :integer
  end
end
