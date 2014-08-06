class StoptimeIndex < ActiveRecord::Migration
  def change
    add_index(:stop_times, [:station_id, :arrival])
    add_index(:stations, [:lat, :lon])
    add_index(:trips, :trip_id)
  end
end
