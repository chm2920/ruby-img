class StartController < ApplicationController
  
  def index
  end
  
  def upload
    @image = Image.new(params[:imgfile], params[:width], params[:height])
    @img = @image.save
  end
  
  def sample
    
  end
  
end
