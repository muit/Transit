class CreateTrips < ActiveRecord::Migration
  def change
    create_table :trips do |t|
      t.string :trip_id
      t.string :service_id
      t.string :headsign
    end
  end
end
