class StoptimeController < ApplicationController
  def get

    results = []
    results.push({message: ""})

    return if watchError(Station.where(real_id: params[:station_id]).length <= 0, "An error ocurred on server (id: 104).", results)

    services = loadActualServices
    return if watchError(!services, "An error ocurred on server (id: 101).", results)

    stoptimes = []
    if(params[:from] > params[:to])
      stoptimes.concat(StopTime.where(station_id: params[:station_id]).where(arrival: params[:from].."11:59:59").order("arrival"))
      stoptimes.concat(StopTime.where(station_id: params[:station_id]).where(arrival: "00:00:00"..params[:to]).order("arrival"))
    else
      stoptimes.concat(StopTime.where(station_id: params[:station_id]).where(arrival: params[:from]..params[:to]).order("arrival"))
    end

    
    ActiveRecord::Base.transaction do
      stoptimes.each do |stoptime|
        trip = getTrip(stoptime.trip_id)
        
        return if watchError(!trip, "An error ocurred on server (id: 102).", results)
        results.push({arrival: stoptime.arrival, headsign: trip.headsign}) if containsCorrectService(trip, services)

      end
    end
    return if watchError(results.length-1 == 0, "Nothing stops here right now!", results)
    return if watchError(results.length-1 < 0, "An error ocurred on server (id: 103).", results)
    
    puts results.length-1
    render :json => results
  end

  private
  def watchError(condition, message, results)
    if(condition)
      results[0] = {message: message}
      render :json => results
      puts message
    end
    return condition
  end

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