class StoptimeController < ApplicationController
  def get
    station_id = params[:station_id]
    stops = StopTime.where(station_id: station_id).where(arrival: params[:from]..params[:to])
    results = stops.map{|stop| {arrival: stop.arrival, headsign: getTripName(stop.trip_id)}}
    render :json => stops
  end

  def getTripName(trip_id)
    Trip.where(trip_id: trip_id).first.headsign
  end
end