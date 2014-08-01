class Service < ActiveRecord::Base
  has_many :service, primary_key: "service_id", foreign_key: "service_id"
end
