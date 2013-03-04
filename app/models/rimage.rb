require 'RMagick'
include Magick

class Rimage < ActiveRecord::Base
  
  attr_accessible :path, :extName, :width, :height, :scale, :total, :state
  
  def upload_path
    File.join("#{Rails.root}/public", self.path)
  end
  
  def full_path
    File.join(self.upload_path, 'a' + self.extName)
  end
  
  def full_path_b
    File.join(self.upload_path, 'b' + self.extName)
  end
  
  def full_path_c
    File.join(self.upload_path, 'c' + self.extName)
  end
  
  def full_path_m
    File.join(self.upload_path, 'm')
  end
  
  def rel_path
    File.join(self.path, 'a' + self.extName)
  end
  
  def rel_path_b
    File.join(self.path, 'b' + self.extName)
  end
  
  def rel_path_c
    File.join(self.path, 'c' + self.extName)
  end
  
  def rel_path_m
    File.join(self.path, 'm/')
  end
  
  def w
    self.width / 10
  end
  
  def h
    self.height / 10
  end
  
  def weights
    []
  end
  
  
  def self.upload(data, width, height)
    begin
      origName = data.original_filename
      baseName = File.basename(origName, ".*")
      
      rimage = Rimage.new
      rimage.path = File.join("/upload/", Digest::MD5.hexdigest(baseName).to_s.upcase + "_" + Time.now.to_i.to_s + '/')
      rimage.extName = File.extname(origName).downcase
      
      if rimage.extName != '.jpg' && rimage.extName != '.jpeg' && rimage.extName != '.gif' && rimage.extName != '.png' && rimage.extName != '.bmp' 
        500
      else         
        FileUtils.mkpath(rimage.upload_path) unless File.directory?(rimage.upload_path)
        
        File.open(rimage.full_path, "wb") { |file|
          file.write(data.read)
        }
        
        rimage.scale = 10
        rimage.width = width.to_i
        rimage.height = height.to_i
        rimage.total = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0].join('$')
        rimage.state = 1
        rimage.save
        rimage
      end
    rescue Exception => e
      400
    end
  end
  
  def check_size
    img = Magick::Image.read(self.full_path).first
    if img.columns > self.width || img.rows > self.height
      
    end
  end
  
  def generate!
    img = Magick::Image.read(self.full_path).first
    #@obj = @obj.scale(400, 300)
    img = img.crop(CenterGravity, self.width * self.scale, self.height * self.scale)
    #chopped = @obj.crop(23, 81, 107, 139)
    img.write(self.full_path_b)
    
      
    @obj = Magick::Image.read(self.full_path_b).first
    
    w = @obj.columns
    h = @obj.rows
    
    a = w / self.width
    b = h / self.height
    
    @max = 65535
    
    img_c = Magick::Image.new(w, h, Magick::HatchFill.new('white', 'black', a))
    
    weights = []
    0.upto self.height-1 do |y|
      weights[y] = []
      0.upto self.width-1 do |x|
        sx = a * x
        sy = b * y
        ex = a * (x + 1)
        ey = b * (y + 1)
        weight = cal_weight(sx, sy, ex, ey)        
        
        weights[y][x] = 10 - weight
        midx = sx + a/2
        midy = sy + b/2
        rdx = sx + (a/2 * weight) / 10
        
        Magick::Draw.new.circle(midx, midy, rdx, midy).draw(img_c)
      end
    end
    
    img_c.write(self.full_path_c)
    
       
    per = 50
    
    FileUtils.mkpath(self.full_path_m) unless File.directory?(self.full_path_m)
    
    text = Magick::Draw.new
    text.gravity = Magick::CenterGravity
    text.pointsize = 18
    text.font_weight = Magick::BoldWeight
        
    total = self.total.split('$')
    puts total
    i = 0
    0.upto self.h - 1 do |y|
      0.upto self.w - 1 do |x|
        i = i + 1
        img = Magick::Image.new(per * 10, per * 10, Magick::HatchFill.new('white', 'black', per))
        
        sx = x * self.scale
        sy = y * self.scale
        ex = (x + 1) * self.scale
        ey = (y + 1) * self.scale
        
        n = 0
        sy.upto ey-1 do |yy|
          m = 0
          sx.upto ex-1 do |xx|
            weight = weights[yy][xx]
            total[weight] = total[weight].to_i + 1
            text.annotate(img, per, per, m * per, n * per, weight.to_s)
            m = m + 1
          end
          n = n + 1
        end        
        
        path = File.join(self.full_path_m, 'M' + i.to_s + '.jpg')
        img.write(path)
      end
    end
    self.total = total.join('$')
  end
  
  def cal_lu(p_color)
    0.299 * p_color.red + 0.587 * p_color.green + 0.114 * p_color.blue
  end
  
  def cal_weight(sx, sy, ex, ey)
    sum = 0
    sy.upto ey-1 do |y|
      sx.upto ex-1 do |x|
        p_color = @obj.pixel_color(x, y)
        lu = cal_lu(p_color)
        sum =+ (lu * 10 / @max).to_i
      end
    end
    sum
  end
  
end
