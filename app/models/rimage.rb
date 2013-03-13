require 'RMagick'
include Magick

class Rimage < ActiveRecord::Base
  
  attr_accessible :path, :extName, :width, :height, :scale, :weights, :total, :state, :extends
  
  before_destroy :remove_file
  
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
  
  def per_blank
    10
  end
  
  def sx
    self.extends ? self.extends.split('##')[0] : ''
  end
  
  def sy
    self.extends ? self.extends.split('##')[1] : ''
  end
  
  def tw
    self.extends ? self.extends.split('##')[2] : ''
  end
  
  def th
    self.extends ? self.extends.split('##')[3] : ''
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
        
        rimage.scale = 4
        rimage.width = width.to_i
        rimage.height = height.to_i
        rimage.weights = ''
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
    scale = 4
    
    img = Magick::Image.read(self.full_path).first
    
    c = img.columns
    r = img.rows
    
    tw = self.width * scale
    th = self.height * scale
    
    if tw > c || th > r
      if c / r > self.width / self.height
        img = img.scale(tw, th * r / c)
      else
        img = img.scale((tw * c / r).to_i, th)     
      end
    else
      if c / r > self.width / self.height
        img = img.scale(r * self.width / self.height, r)
      else
        img = img.scale(c, c * self.height / self.width)
      end    
    end
    self.generate!(img)
  end
  
  def generate!(img) 
    scale = 4   
    self.scale = scale
    cw = self.width * scale
    ch = self.height * scale
    
    #@obj = @obj.scale(400, 300)
    img = img.crop(CenterGravity, cw, ch)
    #chopped = @obj.crop(23, 81, 107, 139)
    img.write(self.full_path_b)
    
      
    @obj = Magick::Image.read(self.full_path_b).first
        
    img_c = Magick::Image.new(cw, ch, Magick::HatchFill.new('white', 'white', scale))
    
    weights = []
    0.upto self.height - 1 do |y|
      weights[y] = []
      0.upto self.width - 1 do |x|
        sx = scale * x
        sy = scale * y
        ex = scale * (x + 1)
        ey = scale * (y + 1)
        weight = cal_weight(@obj, sx, sy, ex, ey)        
        
        weights[y][x] = 10 - weight
        midx = sx + scale/2
        midy = sy + scale/2
        rdx = sx + (scale/2 * weight) / 10
        
        Magick::Draw.new.circle(midx, midy, rdx, midy).draw(img_c)
      end
    end
    
    img_c.write(self.full_path_c)
    
    self.weights = weights.map{|t|t.join('$')}.join('#')
    self.state = 2
    self.save
  end
  
  def generate_m!
    per_pixels = 50
    
    FileUtils.mkpath(self.full_path_m) unless File.directory?(self.full_path_m)
    
    text = Magick::Draw.new
    text.gravity = Magick::CenterGravity
    text.pointsize = 18
    text.font_weight = Magick::BoldWeight
        
    total = self.total.split('$')
    weights = self.weights.split('#').map{|t|t.split('$')}
    i = 0
    t = (self.height / self.per_blank) * (self.width / self.per_blank)
    0.upto self.height / self.per_blank - 1 do |y|
      0.upto self.width / self.per_blank - 1 do |x|
        i = i + 1
        img = Magick::Image.new(per_pixels * per_blank, per_pixels * per_blank, Magick::HatchFill.new('white', 'black', per_pixels))
        
        sx = x * per_blank
        sy = y * per_blank
        ex = (x + 1) * per_blank
        ey = (y + 1) * per_blank
        
        n = 0
        sy.upto ey-1 do |yy|
          m = 0
          sx.upto ex-1 do |xx|
            weight = weights[yy][xx].to_i
            total[weight] = total[weight].to_i + 1
            text.annotate(img, per_pixels, per_pixels, m * per_pixels, n * per_pixels, weight.to_s)
            m = m + 1
          end
          n = n + 1
        end        
        
        path = File.join(self.full_path_m, 'M' + i.to_s + '.jpg')
        puts i.to_s + '/' + t.to_s
        img.write(path)
      end
    end
    self.total = total.join('$')
    self.state = 200
    self.save
  end
  
  def cal_lu(p_color)
    0.299 * p_color.red + 0.587 * p_color.green + 0.114 * p_color.blue
  end
  
  def cal_weight(obj, sx, sy, ex, ey)
    sum = 0
    sy.upto ey-1 do |y|
      sx.upto ex-1 do |x|
        p_color = obj.pixel_color(x, y)
        lu = cal_lu(p_color)
        sum =+ (lu * 10 / 65535).to_i
      end
    end
    if sum == 9
      sum = 8
    end
    sum
  end
  
  def remove_file
    puts 'remove file'
  end
  
end
