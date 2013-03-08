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
    if !params[:width].nil? && !params[:height].nil?
      @image.width = params[:width]
      @image.height = params[:height]
      @image.save
    end
    case request.method
    when "POST"
      img = Magick::Image.read(@image.full_path).first
      if !params[:w].nil? && !params[:h].nil?
        img = img.scale(params[:w].to_i, params[:h].to_i)
      end
      @image.generate!(img, params[:scale].to_i)
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
