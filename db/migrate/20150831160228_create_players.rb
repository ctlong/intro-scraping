class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.belongs_to :country, index: true, foreign_key: true
      t.string :name
      t.string :position
      t.date :dob

      t.timestamps null: false
    end
  end
end
