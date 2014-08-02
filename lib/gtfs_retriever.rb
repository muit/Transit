require "gtfs"
require "fixnum"

class GtfsRetriever
  def self.updateData(stations = true, services = true, trips = true, stoptimes = true)
    @@stationsInsertHash = []
    @@servicesInsertHash = []
    @@tripsInsertHash = []
    @@stoptimesInsertHash = []

    puts "==All local gtfs databases will be reset=="
    puts "==Started importing Gtfs Databases=="
    puts ""

    #Bucle whit all databases in model GtfsLocations
      name = "madrid" #(GtfsLocations object).name
      puts "**Downloading #{name} Gtfs Zip..."
      source = GTFS::Source.build("https://servicios.emtmadrid.es:8443/gtfs/transitemt.zip", {strict: false})
      puts "#Extracting ..."
      #Data Exports To DB code must be here.
      if stations
        puts "\n*Stations..."
        puts "Clearing"
        Station.destroy_all

        source.each_stop  {|row| createStation(row)}
        puts "Inserting\n"
        insertStations
      else
        puts "\n*Stations skipped"
      end

      if services
        puts "\n\n*Services..."
        puts "Clearing"
        Service.destroy_all

        source.each_calendar {|row| createService(row)}
        #calendar_dates {|row| createService(row)} <= This services are special
        puts "Inserting\n"
        insertServices
      else
        puts "\n*Services skipped"
      end

      if trips
        puts "\n\n*Trips..."
        puts "Clearing"
        Trip.destroy_all

        source.each_trip {|row| createTrip(row)}
        puts "Inserting\n"
        insertTrips
      else
        puts "\n*Services skipped"
      end

      if stoptimes
        puts "\n\n*Stop times..."
        puts "Clearing"
        StopTime.destroy_all

        source.each_stop_time {|row| createStoptime(row)}
        puts "Inserting\n"
        insertStoptimes
      else
        puts "\n*Stop times skipped"
      end

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

  def self.createStation(row)
    #Station.create (stop_id, name, lat, lon)
    @@stationsInsertHash.push({real_id: row.id, name: row.name, lat: row.lat, lon: row.lon})
  end
  def self.insertStations
    ActiveRecord::Base.transaction do
      Station.create(@@stationsInsertHash)
    end
  end

  def self.createService(row)
    ActiveRecord::Base.transaction do
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
  end
  def self.insertServices
    ActiveRecord::Base.transaction do
      Service.create(@@servicesInsertHash)
    end
  end

  def self.createTrip(row)
    #trip.create (trip_id, service_id, route_id)
    @@tripsInsertHash.push({trip_id: row.id, service_id: row.service_id, route_id: row.route_id})
  end
  def self.insertTrips
    ActiveRecord::Base.transaction do
      trips = Trip.create(@@tripsInsertHash)

      lastTrip = trips.first
      service = Service.where(service_id: lastTrip.service_id).first

      trips.each do |trip|
        service = Service.where(service_id: trip.service_id).first if trip.service_id != lastTrip.service_id
        #Asotiation Service <= Trip
        service.trips << trip
        lastTrip = trip
      end
    end
  end

  def self.createStoptime(row)
    #Stop_times.create (station_id, trip_id, arrival, departure)
    @@stoptimesInsertHash.push({station_id: row.stop_id, trip_id: row.trip_id, arrival: to_time(row.arrival_time), departure: to_time(row.departure_time)})
  end
  def self.insertStoptimes
    ActiveRecord::Base.transaction do
      sts = StopTime.create(@@stoptimesInsertHash)

      lastSt = sts.first
      station = Station.where(stop_id: lastSt.station_id).first
      trip = Trip.where(trip_id: lastSt.trip_id).first

      sts.each do |st|
        station = Station.where(stop_id: st.station_id).first if st.station_id != lastSt.station_id
        trip = Trip.where(trip_id: st.trip_id).first if st.trip_id != lastSt.trip_id

        #Asotiation Station <= Stop_time
        station.stop_times << st
        #Asotiation Trip <= Stop_time
        trip.stop_times << st
        lastSt = st
      end
    end
  end

  def self.to_date(str)
    Date.strptime(str, "%Y%m%d")
  end

  def self.to_time(str)
    Time.parse(str)
  end
end