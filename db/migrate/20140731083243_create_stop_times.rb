class CreateStopTimes < ActiveRecord::Migration
  def change
    create_table :stop_times do |t|
      t.integer :station_id
      t.string :trip_id
      t.string :arrival
      t.string :departure
    end
  end
end
