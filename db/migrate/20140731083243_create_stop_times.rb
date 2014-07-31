class CreateStopTimes < ActiveRecord::Migration
  def change
    create_table :stop_times do |t|
      t.integer :station_id
      t.string :trip_id
      t.time :arrival
      t.time :departure
    end
  end
end
