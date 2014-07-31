class CreateStations < ActiveRecord::Migration
  def change
    create_table :stations do |t|
      t.integer :real_id
      t.string :name
      t.float :lat
      t.float :lon
    end
  end
end
