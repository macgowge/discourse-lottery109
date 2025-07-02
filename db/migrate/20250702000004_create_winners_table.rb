# plugins/discourse-lottery/db/migrate/20250702_create_winners_table.rb
class CreateWinnersTable < ActiveRecord::Migration[7.0]
  def change
    create_table :lottery_plugin_winners do |t|
      t.integer :lottery_id, null: false
      t.integer :user_id, null: false
      t.timestamps
    end

    add_index :lottery_plugin_winners, [:lottery_id, :user_id], unique: true
  end
end
