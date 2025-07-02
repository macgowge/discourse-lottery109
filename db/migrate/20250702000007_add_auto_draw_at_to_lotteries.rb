# plugins/discourse-lottery/db/migrate/20250702000007_add_auto_draw_at_to_lotteries.rb
class AddAutoDrawAtToLotteries < ActiveRecord::Migration[7.0]
  def change
    add_column :lottery_plugin_lotteries, :auto_draw_at, :datetime
  end
end
