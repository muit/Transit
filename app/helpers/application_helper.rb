module ApplicationHelper

  def watch_error(condition, message)
    if(condition)
      results = [{message: message}]
      render :json => results
      puts message
    end
    condition
  end
end
