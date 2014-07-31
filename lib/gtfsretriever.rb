class GtfsRetriever
  def self.updateData
    #Need to DEBUG!
    GtfsReader.config do
      return_hashes true

      sources do
        madrid do
          url "https://servicios.emtmadrid.es:8443/gtfs/transitemt.zip"
          before { |etag| puts "Processing source with tag #{etag}..." }
          handlers do
            #Data Exports To DB code must be here.
            stops  {|row| createStation(row)}
            calendar {|row| createService(row)}
            #calendar_dates {|row| createService(row)} <= This services are special
            trips {|row| createtrip(row)}
            stop_times {|row| createStoptime(row)}
          end
        end

      end
    end
    #Switch between that 2 options depending on the function arguments
    #GtfsReader.update :sample or 
    GtfsReader.update_all!
  end

  def createStation(row)
    #Station.create (id, name, lat, lon)
    Station.create(row[:stop_id], row[:stop_name], row[:stop_lat], row[:stop_lon])
  end
  def createService(row)
    #Service.create (service_id, start, end, monday, tuesday, wednesday, thursday, friday, saturday, sunday )
    Service.create (
      row[:service_id], 
      row[:start_date], 
      row[:end_date], 
      row[:monday].to_bool, 
      row[:tuesday].to_bool, 
      row[:wednesday].to_bool, 
      row[:thursday].to_bool, 
      row[:friday].to_bool, 
      row[:saturday].to_bool, 
      row[:sunday].to_bool)
  end
  def createTrip(row)
    #Need to DEBUG!
    #trip.create (trip_id, service_id, route_id)
    trip = Trip.create(row[:trip_id], row[:service_id], row[:route_id])

    #Asotiation Service <= Trip
    Service.where(service_id: row[:service_id]).trips << trip
  end
  def createStoptime(row)
    #Need to DEBUG!

    #Stop_times.create (station_id, trip_id, arrival, departure)
    st = Stop_time.create(row[:stop_id], row[:trip_id], row[:arrival_time], row[:departure_time])
    
    #Asotiation Station <= Stop_time
    Station.where(stop_id: row[:stop_id]).stop_times << st

    #Asotiation Trip <= Stop_time
    Trip.where(trip_id: row[:trip_id]).stop_times << st
  end
end