class CreateStations < ActiveRecord::Migration
  def change
    create_table :stations do |t|

      t.timestamps
    end
  end
end
