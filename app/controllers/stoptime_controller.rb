class StoptimeController < ApplicationController

  def get
    results = []
    results.push({message: ""})

    return if watch_error(Station.where(real_id: params[:station_id]).length <= 0, "An error ocurred on server (id: 104).", results)

    if(params[:from] > params[:to])
      results += calculate(params[:station_id], params[:from], "11:59:59", Date.today)
      results += calculate(params[:station_id], "00:00:00", params[:to], Date.today+1.day)
    else
      results += calculate(params[:station_id], params[:from], params[:to], Date.today)
    end

    return if watch_error(results.length-1 == 0, "Nothing stops here right now!")
    return if watch_error(results.length-1 < 0, "An error ocurred on server (id: 103).")
    
    puts "#{results.length-1} stoptimes"
    render :json => results
  end
end