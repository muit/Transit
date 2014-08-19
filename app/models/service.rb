class Service < ActiveRecord::Base
  validates :service_id, uniqueness: true
  has_many :trips, primary_key: "service_id", foreign_key: "service_id"

  def self.by_date(date)
    date = Date.today if(date == nil)
    where("start < ? AND endd > ?", date, date).where(date.dayname.downcase.to_sym => true)
  end
end

class Date
  def dayname
     DAYNAMES[self.wday]
  end
end