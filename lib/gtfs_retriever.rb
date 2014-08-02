require "gtfs"
require "fixnum"

class GtfsRetriever
  def self.updateData
    @@stationsInsertHash = []
    @@servicesInsertHash = []
    @@tripsInsertHash = []
    @@stoptimesInsertHash = []

    puts "==All local gtfs databases will be reset=="
    resetDatabase
    puts "==Started importing Gtfs Databases=="
    puts ""

    #Bucle whit all databases in model GtfsLocations
      name = "madrid" #(GtfsLocations object).name
      puts "**Downloading #{name} Gtfs Zip..."
      source = GTFS::Source.build("https://servicios.emtmadrid.es:8443/gtfs/transitemt.zip", {strict: false})
      puts "#Extracting ..."
      #Data Exports To DB code must be here.
      puts "\n*Stations..."
      source.each_stop  {|row| createStation(row)}
      puts "Inserting\n"
      insertStations

      puts "\n\n*Services..."
      source.each_calendar {|row| createService(row)}
      #calendar_dates {|row| createService(row)} <= This services are special
      puts "Inserting\n"
      insertServices

      puts "\n\n*Trips..."
      source.each_trip {|row| createTrip(row)}
      puts "Inserting\n"
      insertTrips

      puts "\n\n*Stop times..."
      source.each_stop_time {|row| createStoptime(row)}
      puts "Inserting\n"
      insertStoptimes

      puts "#{name}imported."
      puts ""
    #End of bucle

    #////Secure variable reset
    @@stationsInsertHash = []
    @@servicesInsertHash = []
    @@tripsInsertHash = []
    @@stoptimesInsertHash = []
    #////

    puts "==All Gtfs Databases Imported=="
  end

  def self.resetDatabase
    Station.destroy_all
    Service.destroy_all
    Trip.destroy_all
    StopTime.destroy_all

    #Need to implement ID auto_increment reset
  end

  def self.createStation(row)
    #Station.create (stop_id, name, lat, lon)
    @@stationsInsertHash.push({real_id: row.id, name: row.name, lat: row.lat, lon: row.lon})
  end
  def self.insertStations
    Station.create(@@stationsInsertHash)
  end

  def self.createService(row)
    #Service.create (service_id, start, end, monday, tuesday, wednesday, thursday, friday, saturday, sunday )
    @@servicesInsertHash.push({
      service_id: row.service_id, 
      start: to_date(row.start_date), 
      endd: to_date(row.end_date), 
      monday: row.monday.to_i.to_bool, 
      tuesday: row.tuesday.to_i.to_bool, 
      wednesday: row.wednesday.to_i.to_bool, 
      thursday: row.thursday.to_i.to_bool, 
      friday: row.friday.to_i.to_bool, 
      saturday: row.saturday.to_i.to_bool, 
      sunday: row.sunday.to_i.to_bool})
  end
  def self.insertServices
    Service.create(@@servicesInsertHash)
  end

  def self.createTrip(row)
    #trip.create (trip_id, service_id, route_id)
    @@tripsInsertHash.push({trip_id: row.id, service_id: row.service_id, route_id: row.route_id})
  end
  def self.insertTrips
    trips = Trip.create(@@tripsInsertHash)

    trips.each do |trip|
      #Asotiation Service <= Trip
      Service.where(service_id: trip.service_id).first.trips << trip
    end
  end

  def self.createStoptime(row)
    #Stop_times.create (station_id, trip_id, arrival, departure)
    @@stoptimesInsertHash.push({station_id: row.stop_id, trip_id: row.trip_id, arrival: to_time(row.arrival_time), departure: to_time(row.departure_time)})
  end
  def self.insertStoptimes
    sts = StopTime.create(@@stoptimesInsertHash)

    sts.each do |st|
      #Asotiation Station <= Stop_time
      Station.where(stop_id: st.station_id).first.stop_times << st
      #Asotiation Trip <= Stop_time
      Trip.where(trip_id: st.trip_id).first.stop_times << st
    end
  end

  def self.to_date(str)
    Date.strptime(str, "%Y%m%d")
  end

  def self.to_time(str)
    Time.parse(str)
  end
end