class StopTime < ActiveRecord::Base
  belongs_to :trip, primary_key: "trip_id", foreign_key: "trip_id"
  belongs_to :station, primary_key: "real_id", foreign_key: "station_id"
end
