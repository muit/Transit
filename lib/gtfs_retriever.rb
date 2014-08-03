require "gtfs"
require "fixnum"
require "activerecord-import/base"

class GtfsRetriever
  def self.updateData(stations = true, services = true, trips = true, stoptimes = true)
    setup

    @@count = 0
    emptyCache

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
        @@count = 0
        puts "\n*Stations..."
        puts "Clearing"
        Station.delete_all
        puts "Loading\n"
        source.each_stop  {|row| createStation(row)}
        insertStations
        emptyCache
      else
        puts "\n*Stations skipped"
      end

      if services
        @@count = 0
        puts "\n\n*Services..."
        puts "Clearing"
        Service.delete_all
        puts "Loading\n"
        source.each_calendar {|row| createService(row)}
        #calendar_dates {|row| createService(row)} <= This services are special
        insertServices
      emptyCache
      else
        puts "\n*Services skipped"
      end

      if trips
        @@count = 0
        puts "\n\n*Trips..."
        puts "Clearing"
        Trip.delete_all
        puts "Loading\n"
        source.each_trip {|row| createTrip(row)}
        insertTrips
        emptyCache
      else
        puts "\n*Services skipped"
      end
      if stoptimes
        @@count = 0
        puts "\n\n*Stop times..."
        puts "Clearing"
        StopTime.delete_all
        puts "Loading\n"
        source.each_stop_time {|row| createStoptime(row)}
        insertStoptimes
        emptyCache
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
    @@antiFreezeCount = nil
    @@count = nil
    #////

    puts "==All Gtfs Databases Imported=="

  end

  def self.createStation(row)
    #Station.create (stop_id, name, lat, lon)
    @@stationsInsertHash.push([row.id, row.name, row.lat, row.lon])
    print "\r"
    print "Station: #{@@count}"
    @@count += 1
    @@antiFreezeCount += 1

    if @@antiFreezeCount >= 100000
      insertStations
      emptyCache
      puts ""
    end
  end
  def self.insertStations
    puts "\nInserting\n"
    Station.import [:real_id, :name, :lat, :lon], @@stationsInsertHash, :validate => false
  end

  def self.createService(row)
    #Service.create (service_id, start, end, monday, tuesday, wednesday, thursday, friday, saturday, sunday )
    @@servicesInsertHash.push([
      row.service_id, 
      to_date(row.start_date), 
      to_date(row.end_date), 
      row.monday.to_i.to_bool, 
      row.tuesday.to_i.to_bool, 
      row.wednesday.to_i.to_bool, 
      row.thursday.to_i.to_bool, 
      row.friday.to_i.to_bool, 
      row.saturday.to_i.to_bool, 
      row.sunday.to_i.to_bool])
    print "\r"
    print "Service: #{@@count}"
    @@count += 1
    @@antiFreezeCount += 1

    if @@antiFreezeCount > 100000
      insertServices
      emptyCache
    end
  end
  def self.insertServices
    puts "\nInserting\n"
    Service.import [:service_id, :start, :endd, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday], @@servicesInsertHash, :validate => false
  end

  def self.createTrip(row)
    #trip.create (trip_id, service_id, route_id)
    @@tripsInsertHash.push([row.id, row.service_id, row.route_id.to_i])
    print "\r"
    print "Trip: #{@@count}"
    @@count += 1
    @@antiFreezeCount += 1

    if @@antiFreezeCount > 100000
      insertTrips
      emptyCache
    end
  end
  def self.insertTrips
    puts "\nInserting\n"
    Trip.import [:trip_id, :service_id, :route_id], @@tripsInsertHash, :validate => false

    #Associations killing performance. Temporarily disabled
    #lastTrip = Trip.first
    #service = Service.where(service_id: lastTrip.service_id).first

    #services = Service.all
    #trips = Trip.all
    #ActiveRecord::Base.transaction do
      #trips.each do |trip|
        #service = Service.select {|sv| sv["service_id"] == trip.service_id}.first if trip.service_id != lastTrip.service_id
        #Asotiation Service <= Trip
        #service.trips << trip
        #lastTrip = trip
      #end
    #end
  end

  def self.createStoptime(row)
    #Stop_times.create (station_id, trip_id, arrival, departure)
    @@stoptimesInsertHash.push([row.stop_id, row.trip_id, row.arrival_time, row.departure_time])
    print "\r"
    print "StopTime: #{@@count}"
    @@count += 1
    @@antiFreezeCount += 1

    if @@antiFreezeCount > 100000
      insertStoptimes
      emptyCache
    end
  end
  def self.insertStoptimes
    puts "\nInserting\n"
    StopTime.import [:station_id, :trip_id, :arrival, :departure], @@stoptimesInsertHash, :validate => false
    
    #Associations killing performance. Temporarily disabled
    #lastSt = Stoptime.first
    #station = Station.where(stop_id: lastSt.station_id).first
    #trip = Trip.where(trip_id: lastSt.trip_id).first
    #sts = Stoptime.all
    #ActiveRecord::Base.transaction do
      #sts.each do |st|
        #station = Station.where(stop_id: st.station_id).first if st.station_id != lastSt.station_id
        #trip = Trip.where(trip_id: st.trip_id).first if st.trip_id != lastSt.trip_id

        #Asotiation Station <= Stop_time
        #station.stop_times << st
        #Asotiation Trip <= Stop_time
        #trip.stop_times << st
        #lastSt = st
      #end
    #end
  end

  def self.setup
    ActiveRecord::Import.require_adapter( ActiveRecord::Base.configurations[Rails.env]["adapter"] )
  end

  def self.to_date(str)
    Date.strptime(str, "%Y%m%d")
  end

  def self.to_time(str)
    parse(str)
  end

  def self.parse(str, now=now)
    date_parts = Date._parse(str)
    return if date_parts.blank?
    time = Time.parse(str, now) rescue DateTime.parse(str)
    if date_parts[:offset].nil?
      ActiveSupport::TimeWithZone.new(nil, self, time)
    else
      time.in_time_zone(self)
    end
  end

  def self.emptyCache
    @@antiFreezeCount = 0
    @@stationsInsertHash = []
    @@servicesInsertHash = []
    @@tripsInsertHash = []
    @@stoptimesInsertHash = []
  end

  def self.newState
    @@count = 0
    @@antiFreezeCount = 0
  end
end

#hackfix
module GTFS
  module Model
    def initialize(attrs)
      attrs.each do |key, val|
        if(key == "trip_id")
          puts val
        end
        instance_variable_set("@#{key}", val)
      end
    end
  end
end