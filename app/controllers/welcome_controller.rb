class WelcomeController < ApplicationController
  def index
    if mobile_device?
      render 'mobile'
    else
      render 'desktop'
    end
  end
end