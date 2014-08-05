class StoptimeController < ApplicationController
  def index
    station_id = params[:station_id]
    stops = StopTime.where(station_id: station_id).where(arrival: params[:from]..params[:to])
    render :json => stops
  end
end