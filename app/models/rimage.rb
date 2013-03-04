require 'RMagick'
include Magick

class Rimage
  
  attr :rel_path, :rel_path_b, :rel_path_c, :rel_path_m, :weights, :w, :h, :total
  
  def initialize(data, width, height)
    @bits = data
    @width = width.to_i
    @height = height.to_i
    @scale = 10
    @total = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  end

  def save
    origName = @bits.original_filename
    baseName = File.basename(origName, ".*")
    extName = File.extname(origName).downcase
    base_path = File.join("/upload/", Digest::MD5.hexdigest(baseName).to_s.upcase + "_" + Time.now.to_i.to_s + '/')
    upload_path = File.join("#{Rails.root}/public", base_path)
    
    FileUtils.mkpath(upload_path) unless File.directory?(upload_path)
    
    @path = File.join(upload_path, 'a' + extName)
    @path_b = File.join(upload_path, 'b' + extName)
    @path_c = File.join(upload_path, 'c' + extName)
    @path_m = File.join(upload_path, 'm')
    
    @rel_path = File.join(base_path, 'a' + extName)
    @rel_path_b = File.join(base_path, 'b' + extName)
    @rel_path_c = File.join(base_path, 'c' + extName)
    @rel_path_m = File.join(base_path, 'm/')
    
    File.open(@path, "wb") { |file|
      file.write(@bits.read)
    }
    
    render_b
    
    render_c
    
    generate_marr
    
    @obj
  end
  
  def render_b    
    @chopped = Magick::Image.read(@path).first
    #@obj = @obj.scale(400, 300)
    @chopped = @chopped.crop(CenterGravity, @width * @scale, @height * @scale)
    #chopped = @obj.crop(23, 81, 107, 139)
    @chopped.write(@path_b)
  end
  
  def render_c    
    @obj = Magick::Image.read(@path_b).first
    
    p = @width
    q = @height
    
    w = @obj.columns
    h = @obj.rows
    
    a = w / p
    b = h / q
    
    @max = 65535
    
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
        
        @weights[y][x] = 10 - weight
        midx = sx + a/2
        midy = sy + b/2
        rdx = sx + (a/2 * weight) / 10
        
        Magick::Draw.new.circle(midx, midy, rdx, midy).draw(img_c)
      end
    end
    
    img_c.write(@path_c)
  end
  
  def generate_marr
    @w = @width / 10
    @h = @height / 10
    
    per = 50
    
    FileUtils.mkpath(@path_m) unless File.directory?(@path_m)
    
    text = Magick::Draw.new
    text.gravity = Magick::CenterGravity
    text.pointsize = 18
    text.font_weight = Magick::BoldWeight
        
    i = 0
    0.upto @h - 1 do |y|
      0.upto @w - 1 do |x|
        i = i + 1
        img = Magick::Image.new(per * 10, per * 10, Magick::HatchFill.new('white', 'black', per))
        
        sx = x * @scale
        sy = y * @scale
        ex = (x + 1) * @scale
        ey = (y + 1) * @scale
        
        n = 0
        sy.upto ey-1 do |yy|
          m = 0
          sx.upto ex-1 do |xx|
            weight = @weights[yy][xx]
            @total[weight] = @total[weight] + 1
            text.annotate(img, per, per, m * per, n * per, weight.to_s)
            m = m + 1
          end
          n = n + 1
        end        
        
        path = File.join(@path_m, 'M' + i.to_s + '.jpg')
        img.write(path)
      end
    end
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