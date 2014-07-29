class WelcomeController < ApplicationController
  def index
    puts helper_method :mobile_device?
    render 'index'
  end
end