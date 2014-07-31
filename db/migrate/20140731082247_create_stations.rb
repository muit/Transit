class CreateStations < ActiveRecord::Migration
  def change
    create_table :stations do |t|
      t.integer :id
      t.string :name
      t.float :lat
      t.float :lon
      t.timestamps
    end
  end
end
