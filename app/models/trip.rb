class Trip < ActiveRecord::Base
  has_many :stop_times, primary_key: "trip_id", foreign_key: "trip_id"
  belongs_to :service, primary_key: "service_id", foreign_key: "service_id"
end
