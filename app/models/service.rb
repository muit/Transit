class Service < ActiveRecord::Base
  validates :service_id, uniqueness: true
  has_many :trips, primary_key: "service_id", foreign_key: "service_id"
end
