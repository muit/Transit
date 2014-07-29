class WelcomeController < ApplicationController
  def index
    puts mobile_device?
    render 'index'
  end
end