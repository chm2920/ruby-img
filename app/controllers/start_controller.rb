class StartController < ApplicationController
  
  def index
  end
  
  def upload
    @image = Rimage.upload(params[:imgfile], params[:width], params[:height])
    if @image && @image != 400 && @image != 500
      session[:image_id] = @image.id
      redirect_to "/crop"
    end    
  end
  
  def crop
    @image = Rimage.find(session[:image_id])
  end
  
  def generate
    @image = Rimage.find(session[:image_id])
    @image.generate!
  end
  
  def sample
    
  end
  
end
