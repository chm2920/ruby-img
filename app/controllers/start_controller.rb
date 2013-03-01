class StartController < ApplicationController
  
  def index
  end
  
  def upload
    require 'RMagick'
    @upload = params[:imgfile]
    @image = Image.new(@upload)
    @image.save
    
    @img = Magick::Image.read(@image.path).first
    
    p = 40
    q = 30
    
    w = @img.columns
    h = @img.rows
    
    a = w / p
    b = h / q
    
    # @test = @img.pixel_color(0, 0)
#     
    # 0.upto @img.columns do |x|
      # i = (x / a).to_i
      # 0.upto @img.rows do |y|
        # @test = @img.pixel_color(x, y)
        # 0.299*R + 0.587*G + 0.114*B
        # j = (y / b).to_i
        # if (i+j) % 2 == 0
          # @img.pixel_color(x, y, "white")
        # else
          # @img.pixel_color(x, y, "black")
        # end
      # end
    # end
    
    img_b = Magick::Image.new(w, h, Magick::HatchFill.new('white', 'black', a))
    
    Magick::Draw.new.circle(w/2, h/2, w/2 - 40, h/2).draw(img_b);
    
    img_b.write(@image.path_b)
  end
  
end
