class CreateTrips < ActiveRecord::Migration
  def change
    create_table :trips do |t|
      t.string :trip_id
      t.string :service_id
      t.integer :route_id
    end
  end
end
