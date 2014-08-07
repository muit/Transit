class StoptimeController < ApplicationController
  def get
    @today = Date.today

    stops = StopTime.where(station_id: params[:station_id]).where(arrival: params[:from]..params[:to])
    puts stops.length
    results = []
    ActiveRecord::Base.transaction do
      results = stops.map{|stop| {arrival: stop.arrival, headsign: getTripName(stop.trip_id)}}
    end
    render :json => results
  end

  private
  def getTripName(trip_id)
    Trip.where(trip_id: trip_id).first.headsign
  end

  def todayServices
    weekday = @today.dayname
    dateServices = getActualServices
    dateServices.where('#{weekday} == ?', true)
  end
  def getActualServices
    Service.where('start_date < ? AND end_date > ?', @today,  @today)
  end
end