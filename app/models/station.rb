class Station < ActiveRecord::Base
  has_many :stop_times, primary_key: "real_id", foreign_key: "station_id"
end
