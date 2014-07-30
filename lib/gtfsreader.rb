class GtfsRetriever
  def initialize(id)
    #GtfsReader example
    GtfsReader.config do
      return_hashes true

      sources do
        sample do
          # https://servicios.emtmadrid.es:8443/gtfs/transitemt.zip
          url GtfsLocation.find(id).url
          before { |etag| puts "Processing source with tag #{etag}..." }
          handlers do
            #Data To DB code must be here.
            #agency {|row| puts "Read Agency: #{row[:agency_name]}" }
            #routes {|row| puts "Read Route: #{row[:route_long_name]}" }
          end
        end
      end
    end
    #Switch between that 2 options depending on the function arguments
    #GtfsReader.update :sample # or GtfsReader.update_all!
  end

  def reloadData
  end

end