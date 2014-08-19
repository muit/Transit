class Trip < ActiveRecord::Base
  validates :trip_id, uniqueness: true
  has_many :stop_times, primary_key: "trip_id", foreign_key: "trip_id"
  belongs_to :service, primary_key: "service_id", foreign_key: "service_id"

  def self.by_id(trip_id)
    where(trip_id: trip_id).first
  end
end
