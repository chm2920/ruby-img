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
    if !params[:width].nil? && !params[:height].nil? && params[:width] != @image.width && params[:height] != @image.height
      @image.width = params[:width]
      @image.height = params[:height]
      @image.save
    end
    case request.method
    when "POST"
      if !params[:x].nil? && !params[:y].nil? && !params[:w].nil? && !params[:h].nil?
        @image.crop(params[:x], params[:y], params[:w], params[:h])
      end
    else
      if @image.state == 1
        @image.check_size
      end
    end
  end
  
  def generate_m
    @image = Rimage.find(session[:image_id])
    case request.method
    when "POST"
      @image.generate_m!
    end
  end
  
  def sample
    
  end
  
end
