require 'RMagick'
include Magick

class Rimage < ActiveRecord::Base
  
  attr_accessible :path, :extName, :width, :height, :scale, :weights, :total, :state, :extends
  
  before_destroy :remove_file
  
  def upload_path
    File.join("#{Rails.root}/public", self.path)
  end
  
  def full_path
    File.join(self.upload_path, 'or' + self.extName)
  end
  
  def full_path_a
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
    File.join(self.path, 'or' + self.extName)
  end
  
  def rel_path_a
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
    per_pixs = 4
    
    img = Magick::Image.read(self.full_path).first
    
    c = img.columns.to_i
    r = img.rows.to_i
    
    tw = self.width * per_pixs
    th = self.height * per_pixs
    
    if tw > c || th > r
      if c * self.height >= self.width * r #c / r > self.width / self.height
        scale = th.to_s + '-' + c.to_s + '-' + 'x'
        scale_x = tw
        scale_y = th * r / c
      else
        scale = tw.to_s + '-' + r.to_s + '-' + 'y'
        scale_x = (tw * c / r).to_i
        scale_y = th  
      end      
    else
      if c * self.height >= self.width * r
        scale = th.to_s + '-' + r.to_s + '-' + 'y'
        scale_x = (th * c / r).to_i
        scale_y = th
      else
        scale = tw.to_s + '-' + c.to_s + '-' + 'x'
        scale_x = tw
        scale_y = (tw * r / c).to_i
      end    
    end
    img = img.scale(scale_x, scale_y)
    img.write(self.full_path_a) 
    
    #img = img.crop(CenterGravity, cw, ch)
    img = img.crop(0, 0, tw, th)
    img.write(self.full_path_b)
    
    self.scale = scale
    s = scale.split('-')    
    iScale = s[1].to_i / s[0].to_i
    self.extends = [0, 0, tw * iScale, th * iScale].join('##')   
    
    self.generate!
  end
  
  def crop(x, y, w, h)
    img = img.crop(x, y, w, h)
    img.write(self.full_path_a)
    
    per_pixs = 4
    tw = self.width * per_pixs
    th = self.height * per_pixs
    img = img.scale(tw, th)
    img.write(self.full_path_b) 
    
    self.extends = [x, y, w, h].join('##')  
    
    self.generate!
  end
  
  def generate! 
    per_pixs = 4   
    cw = self.width * per_pixs
    ch = self.height * per_pixs
      
    @obj = Magick::Image.read(self.full_path_b).first
        
    img_c = Magick::Image.new(cw, ch, Magick::HatchFill.new('white', 'white', per_pixs))
    
    weights = []
    0.upto self.height - 1 do |y|
      weights[y] = []
      0.upto self.width - 1 do |x|
        sx = per_pixs * x
        sy = per_pixs * y
        ex = per_pixs * (x + 1)
        ey = per_pixs * (y + 1)
        weight = cal_weight(@obj, sx, sy, ex, ey)        
        
        weights[y][x] = 10 - weight
        midx = sx + per_pixs/2
        midy = sy + per_pixs/2
        rdx = sx + (per_pixs/2 * weight) / 10
        
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
    `rm -rf #{self.upload_path}`
  end
  
end
