module StoptimeHelper
  def calculate(station_id, from, to, date)
    results = []

    services = Service.by_date(date)
    return if watch_error(services == [], "An error ocurred on server (id: 101).")

    ActiveRecord::Base.transaction do
      stoptimes = StopTime.by_id(station_id).by_time(from, to)
      stoptimes.each do |stoptime|
        trip = Trip.by_id(stoptime.trip_id)
        return if watch_error(!trip, "An error ocurred on server (id: 102).")
        
        if isCorrectService?(trip, services)
          results.push({arrival: stoptime.arrival, headsign: trip.headsign}) 
        end
      end
    end
    results
  end

  def isCorrectService?(trip, services)
    services.each do |service|
      return true if service.service_id == trip.service_id
    end
    return false
  end
end
