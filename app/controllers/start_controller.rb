class StartController < ApplicationController
  
  def index
  end
  
  def upload
    @image = Image.new(params[:imgfile])
    @img = @image.save
    @test = @img.pixel_color(0, 0)
  end
  
end
