class StationController < ApplicationController
  include StationHelper
  def near
    stations = Station.where(lat: params[:minLat]..params[:maxLat]).where(lon: params[:maxLon]..params[:minLon])
    puts "Stations found: #{stations.size}"
    results = stations.map{|station| {id: station.real_id, name: station.name, lat: station.lat, lon: station.lon}}
    render :json => results
  end
end
