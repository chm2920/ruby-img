class Image
  
  attr :bits, :path, :path_b, :rel_path, :rel_path_b
  
  def initialize(data)
    @bits = data
  end

  def save
    origName = @bits.original_filename
    baseName = File.basename(origName, ".*")
    extName = File.extname(origName).downcase
    upload_path = File.join("/upload/", Digest::MD5.hexdigest(baseName).to_s.upcase + "_" + Time.now.to_i.to_s + '_')
    
    #FileUtils.mkpath(upload_path) unless File.directory?(upload_path)
    
    @path = File.join("#{Rails.root}/public", upload_path + 'a' + extName)
    @path_b = File.join("#{Rails.root}/public", upload_path + 'b' + extName)
    
    @rel_path = File.join(upload_path + 'a' + extName)
    @rel_path_b = File.join(upload_path + 'b' + extName)
    File.open(@path, "wb") { |file|
      file.write(@bits.read)
    }
  end  
  
end