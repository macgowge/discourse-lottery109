# plugins/discourse-lottery/db/migrate/20250702_add_winner_user_id_to_lotteries.rb
class AddWinnerUserIdToLotteries < ActiveRecord::Migration[7.0]
  def change
    add_column :lottery_plugin_lotteries, :winner_user_id, :integer
  end
end
