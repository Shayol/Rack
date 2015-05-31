class Schema < ActiveRecord::Migration
  def change
    create_table :users, force: true do |t|
      t.string :name
      t.integer :attempts
      t.boolean :hintUsed
    end
    create_table :games, force: true do |t|
      t.string :guess
      t.string :hint
      t.string :won_lost
    end
  end
end