require "gtfs"

class GtfsRetriever
  def self.updateData
    puts "==All local gtfs databases will be reset=="
    resetDatabase
    puts "==Started importing Gtfs Databases=="
    puts ""

    #Bucle whit all databases in model GtfsLocations
      name = "madrid" #(GtfsLocations object).name
      puts "**Downloading #{name} Gtfs Zip..."
      source = GTFS::Source.build("https://servicios.emtmadrid.es:8443/gtfs/transitemt.zip", {strict: false})
      puts "**Extracting ..."
      #Data Exports To DB code must be here.
      puts "Stations..."
      source.each_stop  {|row| createStation(row)}

      puts "Services..."
      source.each_calendar {|row| createService(row)}
      #calendar_dates {|row| createService(row)} <= This services are special

      puts "Trips..."
      source.each_trip {|row| createtrip(row)}

      puts "Stations..."
      source.each_stop_time {|row| createStoptime(row)}

      puts "#{name}imported."
      puts ""
    #End of bucle

    puts "==All Gtfs Databases Imported=="
  end

  def self.resetDatabase
    Station.destroy_all
    Service.destroy_all
    Trip.destroy_all
    StopTime.destroy_all
  end

  def self.createStation(row)
    #Station.create (stop_id, name, lat, lon)
    Station.create({real_id: row.id, name: row.name, lat: row.lat, lon: row.lon})

  end
  def self.createService(row)
    #Service.create (service_id, start, end, monday, tuesday, wednesday, thursday, friday, saturday, sunday )
    Service.create({
      service_id: row.service_id, 
      start: to_date(row.start_date), 
      end: to_date(row.end_date), 
      monday: row.monday.to_bool, 
      tuesday: row.tuesday.to_bool, 
      wednesday: row.wednesday.to_bool, 
      thursday: row.thursday.to_bool, 
      fryday: row.friday.to_bool, 
      saturday: row.saturday.to_bool, 
      sunday: row.sunday.to_bool})
  end
  def self.createTrip(row)
    #Need to DEBUG!
    #trip.create (trip_id, service_id, route_id)
    trip = Trip.create({trip_id: row.trip_id, service_id: row.service_id, route_id: row.route_id})

    #Asotiation Service <= Trip
    Service.where(service_id: row.service_id).trips << trip
  end
  def self.createStoptime(row)
    #Need to DEBUG!

    #Stop_times.create (station_id, trip_id, arrival, departure)
    st = StopTime.create({station_id: row.id, trip_id: row.trip_id, arrival: to_time(row.arrival_time), departure: to_time(row.departure_time)})
    
    #Asotiation Station <= Stop_time
    Station.where(stop_id: row.id).stop_times << st

    #Asotiation Trip <= Stop_time
    Trip.where(trip_id: row.trip_id).stop_times << st
  end

  def to_date(str)
    Date.strptime(str, "%Y%m%d")
  end

  def to_time(str)
    Time.strptime(str, "%H:%M:%S")
  end
end