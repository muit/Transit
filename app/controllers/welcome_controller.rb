class WelcomeController < ApplicationController
  include WelcomeHelper
  def index
    if mobile_device?
      render 'mobile'
    else
      render 'desktop'
    end
  end
end