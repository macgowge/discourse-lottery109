class AddStatusToLotteryPluginLotteries < ActiveRecord::Migration[7.0]
  def change
    add_column :lottery_plugin_lotteries, :status, :string, default: "active", null: false
  end
end
