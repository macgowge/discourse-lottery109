# plugins/discourse-lottery/db/migrate/202507020001_add_drawn_at_to_lotteries.rb
class AddDrawnAtToLotteries < ActiveRecord::Migration[7.0]
  def change
    add_column :lottery_plugin_lotteries, :drawn_at, :datetime
  end
end
