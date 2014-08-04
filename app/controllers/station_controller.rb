class StationController < ApplicationController
  def near
    stations = Station.where(lat: params[:minLat]..params[:maxLat]).where(lon: params[:maxLon]..params[:minLon])
    puts "Stations found: #{stations.size}"
    render :json => stations
  end
end
