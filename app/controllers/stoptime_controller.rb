class StoptimeController < ApplicationController
  def get

    results = []
    results.push({message: ""})

    return if watchError(Station.where(real_id: params[:station_id]).length <= 0, "An error ocurred on server (id: 104).", results)

    if(params[:from] > params[:to])
      results += calculate(params[:station_id], params[:from], "11:59:59", Date.today)
      results += calculate(params[:station_id], "00:00:00", params[:to], Date.today+1.day)
    else
      results += calculate(params[:station_id], params[:from], params[:to], Date.today)
    end

    return if watchError(results.length-1 == 0, "Nothing stops here right now!")
    return if watchError(results.length-1 < 0, "An error ocurred on server (id: 103).")
    
    puts "#{results.length-1} stoptimes"
    render :json => results
  end

  private

  def calculate(station_id, from, to, date)
    results = []

    services = getServices(date)
    return if watchError(!services, "An error ocurred on server (id: 101).")
    stoptimes = StopTime.where(station_id: station_id).where(arrival: from..to).order("arrival")

    ActiveRecord::Base.transaction do
      stoptimes.each do |stoptime|
        trip = getTrip(stoptime.trip_id)
        return if watchError(!trip, "An error ocurred on server (id: 102).")
        
        if isCorrectService?(trip, services)
          results.push({arrival: stoptime.arrival, headsign: trip.headsign}) 
        end
      end
    end
    results
  end

  def watchError(condition, message)
    if(condition)
      results = [{message: message}]
      render :json => results
      puts message
    end
    return condition
  end

  def getTrip(trip_id)
    Trip.where(trip_id: trip_id).first
  end

  def getServices(date)
    date = Date.today if(date == nil)
    Service.where("start < ? AND endd > ?",today, today).where(date.dayname.downcase.to_sym => true)
  end
  def isCorrectService?(trip, services)
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