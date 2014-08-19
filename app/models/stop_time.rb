class StopTime < ActiveRecord::Base
  validates :station_id, uniqueness: true
  belongs_to :trip, primary_key: "trip_id", foreign_key: "trip_id"
  belongs_to :station, primary_key: "real_id", foreign_key: "station_id"


  def self.by_id(station_id)
    where(station_id: station_id).first
  end
  def self.by_time(from, to)
    where(arrival: from..to).order("arrival")
  end
end