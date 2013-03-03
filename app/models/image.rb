require 'RMagick'
class Image
  
  attr :obj, :bits, :path, :path_b, :rel_path, :rel_path_b, :rel_path_c, :weights
  
  def initialize(data, width, height)
    @bits = data
    @width = width
    @height = height
  end

  def save
    origName = @bits.original_filename
    baseName = File.basename(origName, ".*")
    extName = File.extname(origName).downcase
    upload_path = File.join("/upload/", Digest::MD5.hexdigest(baseName).to_s.upcase + "_" + Time.now.to_i.to_s + '_')
    
    #FileUtils.mkpath(upload_path) unless File.directory?(upload_path)
    
    @path = File.join("#{Rails.root}/public", upload_path + 'a' + extName)
    @path_b = File.join("#{Rails.root}/public", upload_path + 'b' + extName)
    @path_c = File.join("#{Rails.root}/public", upload_path + 'c' + extName)
    
    @rel_path = File.join(upload_path + 'a' + extName)
    @rel_path_b = File.join(upload_path + 'b' + extName)
    @rel_path_c = File.join(upload_path + 'c' + extName)
    
    File.open(@path, "wb") { |file|
      file.write(@bits.read)
    }
    
    render_c
    
    render_b
    
    @obj
  end
  
  def render_b
    chopped = @obj.crop(23, 81, 107, 139)
    @obj.write(@rel_path_c)
  end
  
  def render_c    
    @obj = Magick::Image.read(@path).first
    @obj.pixel_color(0, 0, "white")
    
    p = 160
    q = 120
    
    w = @obj.columns
    h = @obj.rows
    
    a = w / p
    b = h / q
    
    @max = cal_max_lu
    
    img_c = Magick::Image.new(w, h, Magick::HatchFill.new('white', 'black', a))
    
    @weights = []
    0.upto q-1 do |y|
      @weights[y] = []
      0.upto p-1 do |x|
        sx = a * x
        sy = b * y
        ex = a * (x + 1)
        ey = b * (y + 1)
        weight = cal_weight(sx, sy, ex, ey)
        @weights[y][x] = weight
        
        if weight != 0
          midx = sx + a/2
          midy = sy + b/2
          rdx = sx + (a/2 * weight) / 10
          
          Magick::Draw.new.circle(midx, midy, rdx, midy).draw(img_c)
        end
      end
    end
    
    img_c.write(@path_c)
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
  
  
  def cal_max_lu
    0.299 * 65535 + 0.587 * 65535 + 0.114 * 65535
  end
  
end