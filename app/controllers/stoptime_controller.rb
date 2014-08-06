class StoptimeController < ApplicationController
  def get
    stops = StopTime.where(station_id: params[:station_id]).where(arrival: params[:from]..params[:to])
    results = stops.map{|stop| {arrival: stop.arrival, headsign: getTripName(stop.trip_id)}}
    render :json => stops
  end

  def getTripName(trip_id)
    Trip.where(trip_id: trip_id).first.headsign
  end
end