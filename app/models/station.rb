class Station < ActiveRecord::Base
  validates :real_id, uniqueness: true
  has_many :stop_times, primary_key: "real_id", foreign_key: "station_id"
end
