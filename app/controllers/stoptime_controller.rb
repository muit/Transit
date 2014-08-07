class StoptimeController < ApplicationController
  def get
    services = loadActualServices
    stoptimes = StopTime.where(station_id: params[:station_id]).where(arrival: params[:from]..params[:to])

    puts stoptimes.length
    results = []
    ActiveRecord::Base.transaction do
      stoptimes.each do |stoptime|
        trip = getTrip(stoptime.trip_id)
        results.push({arrival: stoptime.arrival, headsign: trip.headsign}) if containsCorrectService(trip, services)
      end
    end
    render :json => results
  end

  private
  def getTrip(trip_id)
    Trip.where(trip_id: trip_id).first
  end

  def loadActualServices
    today = Date.today
    Service.where("start < ? AND endd > ?",today, today).where(today.dayname.downcase.to_sym => true)
  end
  def containsCorrectService(trip, services)
    services.each do |service|
      return true if service.service_id == trip.service_id
    end
    return false
  end
end

class Date
  def dayname
     DAYNAMES[self.wday]
  end
end