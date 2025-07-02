# plugins/discourse-lottery/db/migrate/20250702_add_auto_draw_enabled_to_lotteries.rb
class AddAutoDrawEnabledToLotteries < ActiveRecord::Migration[7.0]
  def change
    add_column :lottery_plugin_lotteries, :auto_draw_enabled, :boolean, default: false, null: false
  end
end
